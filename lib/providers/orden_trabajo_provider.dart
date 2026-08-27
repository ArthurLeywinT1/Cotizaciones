// lib/providers/orden_trabajo_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cotizacion_model.dart';
import '../models/ordenTrabajo_model.dart';
import '../services/ordenTrabajo_service.dart';
import 'cotizacion_provider.dart';
import '../services/cotizacion_service.dart';

// ==========================================
// 1. MODELOS DE DATOS (Para estructurar la info)
// ==========================================
class MaterialItem {
  String id;
  String nombre;
  String proveedor;
  int cantidad;

  MaterialItem({
    required this.id,
    this.nombre = '',
    this.proveedor = '',
    this.cantidad = 0,
  });
}

class CutProcess {
  String id;
  String tipo;
  String desc;
  String despuesDe;
  String fecha;

  CutProcess({
    required this.id,
    this.tipo = '',
    this.desc = '',
    this.despuesDe = 'Offset',
    this.fecha = '',
  });
}

class DesignTask {
  String id;
  String desc;

  DesignTask({required this.id, this.desc = ''});
}
class PapelExtraItem {
  String id = DateTime.now().millisecondsSinceEpoch.toString();
  String nombrePapel = "";
  String piezas = "";
  String papelNecesario = "";
  String papelLlegara = "";
  Map<String, dynamic> tintas = {
    'frente': {'C': false, 'M': false, 'Y': false, 'K': false, 'especial': false, 'pantone': false, 'tinta_esp': ''},
    'vuelta': {'C': false, 'M': false, 'Y': false, 'K': false, 'especial': false, 'pantone': false, 'tinta_esp': ''}
  };
}

class AcabadoManualItem {
  String id;
  String desc;
  String piezas; // Piezas requeridas para este trabajo manual

  AcabadoManualItem({required this.id, this.desc = '', this.piezas = ''});
}

class TiempoProceso {
  String estatus;
  String? inicio;
  String? fin;

  TiempoProceso({this.estatus = 'Pendiente', this.inicio, this.fin});

  Map<String, dynamic> toJson() => {
    'estatus': estatus,
    'inicio': inicio,
    'fin': fin,
  };

  factory TiempoProceso.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TiempoProceso();
    return TiempoProceso(
      estatus: json['estatus'] ?? 'Pendiente',
      inicio: json['inicio'],
      fin: json['fin'],
    );
  }
}

// ==========================================
// 2. EL CONTROLADOR (El que maneja la lógica)
// ==========================================
class OrdenTrabajoController extends ChangeNotifier {
  final OrdenTrabajoService _service = OrdenTrabajoService();
  final _cotizacionService = CotizacionService();

  bool isLoading = false;
  String sessionKey = '';
  String orderId = "S/F"; // Número de orden simulado
  String currentCotizacionId = "";
  String? ordenTrabajoDbId;
  String tipoCotizacionActual = '';

  // --- Visibilidad de Secciones (Filtros superiores) ---
  Map<String, bool> activeSections = {
    'adquisiciones': true,
    'diseño': true,
    'offset': true,
    'corte': true,
    'laminados': true,
    'suaje': true,
    'grabado': true,
    'serigrafia': true,
    'acabado': true,
    'barniz': true,
    'embalaje': true,
    'logistica': true,
  };

  Map<String, TiempoProceso> tiempos = {
    'adquisiciones': TiempoProceso(),
    'diseno': TiempoProceso(),
    'offset': TiempoProceso(),
    'corte': TiempoProceso(),
    'laminados': TiempoProceso(),
    'suaje': TiempoProceso(),
    'grabado': TiempoProceso(),
    'serigrafia': TiempoProceso(),
    'acabado': TiempoProceso(),
    'barniz': TiempoProceso(),
    'embalaje': TiempoProceso(),
    'logistica': TiempoProceso(),
  };

  List<PapelExtraItem> papelesExtra = [];

  void agregarPapelExtra() {
    papelesExtra.add(PapelExtraItem());
    notifyListeners();
  }

  void eliminarPapelExtra(String id) {
    papelesExtra.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updatePapelExtra(int index, String campo, String valor) {
    if (index < papelesExtra.length) {
      if (campo == 'nombre') papelesExtra[index].nombrePapel = valor;
      if (campo == 'piezas') papelesExtra[index].piezas = valor;
      if (campo == 'necesario') papelesExtra[index].papelNecesario = valor;
      if (campo == 'llegara') papelesExtra[index].papelLlegara = valor;
      notifyListeners();
    }
  }

  void updatePapelExtraInk(int index, String cara, String color, dynamic valor) {
    if (index < papelesExtra.length) {
      papelesExtra[index].tintas[cara][color] = valor;
      notifyListeners();
    }
  }

  void toggleSection(String section) {
    activeSections[section] = !activeSections[section]!;
    notifyListeners();
  }

  String _normalizarKey(String seccion) {
    String s = seccion.toLowerCase().trim();
    if (s == 'diseño' || s == 'pre-prensa') return 'diseno';
    return s;
  }

  Future<void> iniciarProceso(String seccion) async {
    final key = _normalizarKey(seccion);
    if (tiempos.containsKey(key)) {
      tiempos[key]!.estatus = 'Inicio';
      tiempos[key]!.inicio ??= DateTime.now().toIso8601String();
      notifyListeners();
      await guardarOrdenTrabajo();
    }
  }

  Future<void> terminarProceso(String seccion) async {
    final key = _normalizarKey(seccion);
    if (tiempos.containsKey(key)) {
      tiempos[key]!.estatus = 'Fin';
      tiempos[key]!.fin = DateTime.now().toIso8601String();
      notifyListeners();
      await guardarOrdenTrabajo();
    }
  }

  Future<void> marcarIncidenteProceso(String seccion) async {
    final key = _normalizarKey(seccion);
    if (tiempos.containsKey(key)) {
      tiempos[key]!.estatus = 'Incidente';
      notifyListeners();
      await guardarOrdenTrabajo();
    }
  }

  Future<void> cargarDatosPorId(String id, WidgetRef ref) async {
    sessionKey = DateTime.now().millisecondsSinceEpoch.toString();
    isLoading = true;
    notifyListeners();

    currentCotizacionId = id;
    
    try {
      final cotizacion = ref
          .read(cotizacionesProvider)
          .cotizaciones
          .firstWhere((c) => c.id == id);
      orderId = cotizacion.folio ?? "S/F";
      tipoCotizacionActual = cotizacion.tipoCotizacion ?? 'P';
    } catch (e) {
      orderId = "S/F";
      print("⚠️ Aviso: No se encontró la cotización en memoria para extraer el folio.");
    }

    final ordenGuardada = await _service.obtenerOrdenPorCotizacionId(id);
    if (ordenGuardada != null) {
      ordenTrabajoDbId = ordenGuardada.id;
      print("Orden existente encontrada en DB. Lista para actualizar.");
      _cargarDesdeBaseDeDatos(ordenGuardada.datosCompletos);
    } else {
      ordenTrabajoDbId = null;
      print("Orden nueva. Se creará un nuevo registro.");

      Cotizacion? cotizacion;
      try {
        cotizacion = ref
            .read(cotizacionesProvider)
            .cotizaciones
            .firstWhere((c) => c.id == id);
      } catch (e) {
        cotizacion = null;
      }

      if (cotizacion == null) {
        try {
          cotizacion = await _cotizacionService.obtenerCotizacionPorId(id);
        } catch (e) {
          print("❌ Error al cargar cotización desde servicio: $e");
        }
      }

      if (cotizacion != null) {
        orderId = cotizacion.folio ?? "S/F";
        tipoCotizacionActual = cotizacion.tipoCotizacion ?? 'P';
        cargarDatosDeCotizacion(cotizacion);
      } else {
        print("❌ No se pudo obtener la cotización con ID $id");
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void _cargarDesdeBaseDeDatos(Map<String, dynamic> dbData) {
    tipoCotizacionActual = dbData['tipoCotizacion'] ?? 'P';

    if (dbData['activeSections'] != null) {
      activeSections = Map<String, bool>.from(dbData['activeSections']);
    }

    final seccionesKeys = tiempos.keys.toList();
    for (var key in seccionesKeys) {
      if (dbData[key] != null) {
        tiempos[key] = TiempoProceso.fromJson(dbData[key]);
      }
    }

    if (dbData['adquisiciones'] != null) {
      adquisicionesNotas = dbData['adquisiciones']['notas'] ?? '';
      adquisicionesNotasTaller = dbData['adquisiciones']['notasTaller'] ?? '';
      materials.clear();
      for (var m in (dbData['adquisiciones']['materiales'] as List? ?? [])) {
        materials.add(
          MaterialItem(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                m.hashCode.toString(),
            nombre: m['nombre'] ?? '',
            proveedor: m['proveedor'] ?? '',
            cantidad: m['cantidad'] ?? 0,
          ),
        );
      }
    }
    if (dbData['diseno'] != null) {
      disenoNotas = dbData['diseno']['notas'] ?? '';
      disenoNotasTaller = dbData['diseno']['notasTaller'] ?? '';
      designTasks.clear();
      for (var t in (dbData['diseno']['tareas'] as List? ?? [])) {
        designTasks.add(
          DesignTask(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                t.hashCode.toString(),
            desc: t['desc'] ?? '',
          ),
        );
      }
    }

  if (dbData['offset'] != null) {
      offsetTipoTrabajo = dbData['offset']['tipoTrabajo'] ?? '';
      offsetPiezasPedidas = dbData['offset']['piezasPedidas'] ?? 0;
      offsetPapelNecesario = dbData['offset']['papelNecesario'] ?? '';
      offsetPapelLlegara = dbData['offset']['papelLlegara'] ?? '';
      offsetNotas = dbData['offset']['notas'] ?? '';
      offsetNotasTaller = dbData['offset']['notasTaller'] ?? '';
      if (dbData['offset']['tintas'] != null) {
        final tintasDb = dbData['offset']['tintas'] as Map<String, dynamic>;
        offsetData = {
          'frente': Map<String, dynamic>.from(tintasDb['frente'] ?? {}),
          'vuelta': Map<String, dynamic>.from(tintasDb['vuelta'] ?? {}),
        };
      }
      
      // >>> CARGAR PAPELES EXTRA DE LA BD EN MEMORIA <<<
      papelesExtra.clear();
      if (dbData['offset']['papelesExtra'] != null) {
        for (var p in (dbData['offset']['papelesExtra'] as List? ?? [])) {
          final item = PapelExtraItem();
          item.id = p['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
          item.nombrePapel = p['nombrePapel'] ?? '';
          item.piezas = p['piezas']?.toString() ?? '';
          item.papelNecesario = p['papelNecesario']?.toString() ?? '';
          item.papelLlegara = p['papelLlegara']?.toString() ?? '';
          if (p['tintas'] != null) {
            item.tintas = Map<String, dynamic>.from(p['tintas']);
          }
          papelesExtra.add(item);
        }
      }
    }

    if (dbData['corte'] != null) {
      corteNotas = dbData['corte']['notas'] ?? '';
      corteNotasTaller = dbData['corte']['notasTaller'] ?? '';
      cuts.clear();
      for (var c in (dbData['corte']['procesos'] as List? ?? [])) {
        cuts.add(
          CutProcess(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                c.hashCode.toString(),
            tipo: c['tipo'] ?? '',
            desc: c['desc'] ?? '',
            despuesDe: c['despuesDe'] ?? 'Offset',
            fecha: c['fecha'] ?? '',
          ),
        );
      }
    }
    if (dbData['laminados'] != null) {
      laminadoProyecto = dbData['laminados']['proyecto'] ?? '';
      laminadoAcabado = dbData['laminados']['acabado'] ?? 'Brillante';
      laminadoPliegos =
          int.tryParse(dbData['laminados']['pliegos']?.toString() ?? '0') ?? 0;
      laminadoMaquinaChica = dbData['laminados']['maquinaChica'] ?? false;
      laminadoMaquinaGrande = dbData['laminados']['maquinaGrande'] ?? false;
      laminadoNotas = dbData['laminados']['notas'] ?? '';
      laminadoNotasTaller = dbData['laminados']['notasTaller'] ?? '';
      if (dbData['laminados']['aplicacion'] != null) {
        laminadoAplicacion = Map<String, bool>.from(
          dbData['laminados']['aplicacion'],
        );
      }
    }
    if (dbData['suaje'] != null) {
      suajeProyecto = dbData['suaje']['proyecto'] ?? '';
      suajePliegos = dbData['suaje']['pliegos'] ?? 0;
      suajeEsRomosso = dbData['suaje']['esRomosso'] ?? false;
      suajeEsMaquilador = dbData['suaje']['esMaquilador'] ?? false;
      suajeNombreMaquila = dbData['suaje']['nombreMaquila'] ?? '';
      suajeMarcoExistente = dbData['suaje']['marcoExistente'] ?? false;
      suajeMarcoNuevo = dbData['suaje']['marcoNuevo'] ?? false;
      suajeNotas = dbData['suaje']['notas'] ?? '';
      suajeNotasTaller = dbData['suaje']['notasTaller'] ?? '';
    }
    if (dbData['serigrafia'] != null) {
      serigrafiaProyecto = dbData['serigrafia']['proyecto'] ?? '';
      serigrafiaPiezas = dbData['serigrafia']['piezas'] ?? 0;
      serigrafiaMarcos = dbData['serigrafia']['marcos'] ?? '';
      serigrafiaMarcoExistente =
          dbData['serigrafia']['marcoExistente'] ?? false;
      serigrafiaMarcoNuevo = dbData['serigrafia']['marcoNuevo'] ?? false;
      serigrafiaEsRomosso = dbData['serigrafia']['esRomosso'] ?? false;
      serigrafiaEsMaquilador = dbData['serigrafia']['esMaquilador'] ?? false;
      serigrafiaNombreMaquila = dbData['serigrafia']['nombreMaquila'] ?? '';
      serigrafiaModo = dbData['serigrafia']['modoColor'] ?? 'pantone';
      serigrafiaPantoneCode = dbData['serigrafia']['pantoneCode'] ?? '';
      if (dbData['serigrafia']['colorDirecto'] != null) {
        serigrafiaColorDirecto = Color(dbData['serigrafia']['colorDirecto']);
      }
      serigrafiaNotas = dbData['serigrafia']['notas'] ?? '';
      serigrafiaNotasTaller = dbData['serigrafia']['notasTaller'] ?? '';
    }
    if (dbData['grabado'] != null) {
      grabadoProyecto = dbData['grabado']['proyecto'] ?? '';
      grabadoPlacas = dbData['grabado']['placas'] ?? '';
      grabadoPiezas = dbData['grabado']['piezas'] ?? 0;
      grabadoEsRomosso = dbData['grabado']['esRomosso'] ?? false;
      grabadoEsMaquilador = dbData['grabado']['esMaquilador'] ?? false;
      grabadoNombreMaquila = dbData['grabado']['nombreMaquila'] ?? '';
      grabadoNotas = dbData['grabado']['notas'] ?? '';
      grabadoNotasTaller = dbData['grabado']['notasTaller'] ?? '';
    }
    if (dbData['barniz'] != null) {
      barnizProyecto = dbData['barniz']['proyecto'] ?? '';
      barnizPliegos =
          int.tryParse(dbData['barniz']['pliegos']?.toString() ?? '0') ?? 0;
      barnizEsRomosso = dbData['barniz']['esRomosso'] ?? true;
      barnizEsMaquilador = dbData['barniz']['esMaquilador'] ?? false;
      barnizNombreMaquila = dbData['barniz']['nombreMaquila'] ?? '';
      barnizNotas = dbData['barniz']['notas'] ?? '';
      barnizNotasTaller = dbData['barniz']['notasTaller'] ?? '';
      if (dbData['barniz']['aplicacion'] != null) {
        barnizAplicacion = Map<String, bool>.from(
          dbData['barniz']['aplicacion'],
        );
      }
    }
    if (dbData['acabado'] != null) {
      acabadoProyecto = dbData['acabado']['proyecto'] ?? '';
      acabadoDescripcion = dbData['acabado']['descripcionBD'] ?? '';
      acabadoCantidad = dbData['acabado']['cantidadBD'] ?? 0;
      acabadoNotas = dbData['acabado']['notas'] ?? '';
      acabadoNotasTaller = dbData['acabado']['notasTaller'] ?? '';
      acabadosManuales.clear();
      for (var a in (dbData['acabado']['manuales'] as List? ?? [])) {
        acabadosManuales.add(
          AcabadoManualItem(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                a.hashCode.toString(),
            desc: a['desc'] ?? '',
            piezas: a['piezas']?.toString() ?? '',
          ),
        );
      }
    }
    if (dbData['embalaje'] != null) {
      embalajeTipo = dbData['embalaje']['tipo'] ?? '';
      embalajeCantidadCajas = dbData['embalaje']['cantidadCajas'] ?? 0;
      embalajeNotas = dbData['embalaje']['notas'] ?? '';
      embalajeNotasTaller = dbData['embalaje']['notasTaller'] ?? '';
    }
    if (dbData['logistica'] != null) {
      logisticaFechaEntrega = dbData['logistica']['fechaEntrega'] ?? '';
      logisticaDireccion = dbData['logistica']['direccion'] ?? '';
      logisticaTransporte = dbData['logistica']['transporte'] ?? '';
      logisticaTotalEntregar = dbData['logistica']['totalEntregar'] ?? 0;
      logisticaNotas = dbData['logistica']['notas'] ?? '';
      logisticaNotasTaller = dbData['logistica']['notasTaller'] ?? '';
    }
  }

  void cargarDatosDeCotizacion(Cotizacion? cotizacion) {
    if (cotizacion == null) return;

    orderId = cotizacion.folio ?? "S/F";

    for (var key in tiempos.keys) {
      tiempos[key] = TiempoProceso();
    }
    materials.clear();
    papelesExtra.clear();
    designTasks.clear();
    cuts.clear();
    acabadosManuales.clear();

    int matIdCounter = 0;
    void agregarMaterial(String nombre, int cantidad) {
      if (cantidad > 0) {
        materials.add(
          MaterialItem(
            id: 'mat_${matIdCounter++}_${DateTime.now().millisecondsSinceEpoch}',
            nombre: nombre,
            cantidad: cantidad,
          ),
        );
      }
    }

    try {
      final esRevista = cotizacion.tipoCotizacion == 'R';
      adquisicionesNotas = '';
      adquisicionesNotasTaller = '';
      disenoNotas = '';
      disenoNotasTaller = '';
      offsetNotas = '';
      offsetNotasTaller = '';
      corteNotas = '';
      corteNotasTaller = '';
      laminadoNotas = '';
      laminadoNotasTaller = '';
      suajeNotas = '';
      suajeNotasTaller = '';
      serigrafiaNotas = '';
      serigrafiaNotasTaller = '';
      grabadoNotas = '';
      grabadoNotasTaller = '';
      acabadoNotas = '';
      acabadoNotasTaller = '';
      barnizNotas = '';
      barnizNotasTaller = '';
      embalajeNotas = '';
      embalajeNotasTaller = '';
      logisticaNotas = '';
      logisticaNotasTaller = '';

      if (esRevista) {
        final detallePliegos =
            cotizacion.configPliegos?["detalle_pliegos"] as List? ?? [];

        offsetTipoTrabajo = cotizacion.descripcion;
        offsetPiezasPedidas = cotizacion.cantidadImpresiones;

        List<String> notasLaminadoList = [];
        List<String> notasBarnizList = [];

        for (int i = 0; i < detallePliegos.length; i++) {
          final pliego = detallePliegos[i] as Map<String, dynamic>;
          final titulo = pliego["titulo"] ?? "Pliego ${i + 1}";
          final procesos = pliego["procesos"] as Map<String, dynamic>? ?? {};

          final offsetData = pliego["offset_data"] as Map<String, dynamic>?;
          if (offsetData != null) {
            final papelDatos =
                offsetData["papel_datos"] as Map<String, dynamic>?;
            if (papelDatos != null &&
                papelDatos["nombre"]?.toString().isNotEmpty == true) {
              final pliegosAsignados =
                  int.tryParse(
                    papelDatos["total_pliegos_asignados"]?.toString() ?? "0",
                  ) ??
                  0;
              agregarMaterial(
                '$titulo: Papel ${papelDatos["nombre"]} - ${papelDatos["peso"] ?? ""}',
                pliegosAsignados > 0 ? pliegosAsignados : cotizacion.totalPliegos,
              );
            }

            final pruebasColor =
                offsetData["pruebas_color"] as Map<String, dynamic>?;
            if (pruebasColor != null) {
              pruebasColor.forEach((key, val) {
                if (val is Map && val["activo"] == true) {
                  final cant =
                      int.tryParse(val["cantidad"]?.toString() ?? "0") ?? 0;
                  if (cant > 0) {
                    agregarMaterial('$titulo: Prueba de Color $key', cant);
                  }
                }
              });
            }

            final maquinaDatos =
                offsetData["maquina_datos"] as Map<String, dynamic>?;
            if (maquinaDatos != null) {
              final cantPlacas =
                  int.tryParse(
                    maquinaDatos["cantidad_placas"]?.toString() ?? "0",
                  ) ??
                  0;
              final cantPlacas790 =
                  int.tryParse(
                    maquinaDatos["cantidad_placas_790"]?.toString() ?? "0",
                  ) ??
                  0;
              if (cantPlacas > 0) {
                agregarMaterial(
                  '$titulo: Placas Offset (Chicas)',
                  cantPlacas,
                );
              }
              if (cantPlacas790 > 0) {
                agregarMaterial(
                  '$titulo: Placas Offset (Grandes 790)',
                  cantPlacas790,
                );
              }
            }
          }

          final calculosImpresion =
              pliego["calculos_impresion"] as Map<String, dynamic>?;
          final int pliegosAImprimir =
              int.tryParse(
                calculosImpresion?["cantidad_pliegos_imprimir"]?.toString() ??
                    "0",
              ) ??
              0;
          final int pliegosTotales =
              int.tryParse(
                calculosImpresion?["total_pliegos_utilizar"]?.toString() ??
                    "0",
              ) ??
              0;

          if (i == 0) {
            offsetPapelNecesario = pliegosAImprimir.toString();
            offsetPapelLlegara = pliegosTotales.toString();
          } else {
            final extra = PapelExtraItem();
            final papelDatos = offsetData?["papel_datos"];
            extra.nombrePapel = "$titulo: ${papelDatos?["nombre"] ?? ""}";
            extra.piezas = cotizacion.cantidadImpresiones.toString();
            extra.papelNecesario = pliegosAImprimir.toString();
            extra.papelLlegara = pliegosTotales.toString();
            papelesExtra.add(extra);
          }

          if (procesos["Plastificado/Laminado"] == true) {
            final laminadoData =
                pliego["laminado_data"] as Map<String, dynamic>?;
            final seleccion =
                laminadoData?["seleccion"] as Map<String, dynamic>?;
            if (seleccion != null) {
              seleccion.forEach((nombre, caras) {
                if (caras is Map) {
                  if (caras["frente"] == true) {
                    laminadoAplicacion['frente'] = true;
                    notasLaminadoList.add("$titulo - $nombre (Frente)");
                  }
                  if (caras["vuelta"] == true) {
                    laminadoAplicacion['vuelta'] = true;
                    notasLaminadoList.add("$titulo - $nombre (Vuelta)");
                  }
                }
              });
            }
          }

          if (procesos["Barniz UV"] == true) {
            final barnizData =
                pliego["barniz_uv_data"] as Map<String, dynamic>?;
            final seleccion = barnizData?["seleccion"] as Map<String, dynamic>?;
            if (seleccion != null) {
              seleccion.forEach((nombre, caras) {
                if (caras is Map) {
                  if (caras["frente"] == true) {
                    barnizAplicacion['frente'] = true;
                    notasBarnizList.add("$titulo - $nombre (Frente)");
                  }
                  if (caras["vuelta"] == true) {
                    barnizAplicacion['vuelta'] = true;
                    notasBarnizList.add("$titulo - $nombre (Vuelta)");
                  }
                }
              });
            }
          }

          if (procesos["Suaje"] == true) {
            final suajeData = pliego["suaje_data"] as Map<String, dynamic>?;
            if (suajeData != null) {
              suajePliegos +=
                  int.tryParse(suajeData["pliegos"]?.toString() ?? "0") ?? 0;
              if (suajeData["se_cuenta_con_suaje"] == false) {
                agregarMaterial('$titulo: Suaje Nuevo', 1);
                suajeMarcoNuevo = true;
              } else {
                suajeMarcoExistente = true;
              }
            }
          }

          if (procesos["Serigrafia"] == true) {
            final serigrafiaData =
                pliego["serigrafia_data"] as Map<String, dynamic>?;
            if (serigrafiaData != null) {
              final marcos =
                  int.tryParse(
                    serigrafiaData["cantidad_marcos"]?.toString() ?? "0",
                  ) ??
                  0;
              if (marcos > 0) {
                agregarMaterial('$titulo: Marcos Serigrafía', marcos);
              }
            }
          }

          if (procesos["Grabado"] == true) {
            final grabadoData = pliego["grabado_data"] as Map<String, dynamic>?;
            if (grabadoData != null) {
              final placas =
                  int.tryParse(
                    grabadoData["cantidad_placas"]?.toString() ?? "0",
                  ) ??
                  0;
              if (placas > 0) {
                agregarMaterial('$titulo: Placas Grabado', placas);
              }
            }
          }

          if (procesos["Acabados Especiales"] == true) {
            final acabadosData =
                pliego["acabados_especiales_data"] as Map<String, dynamic>?;
            final items = acabadosData?["items"] as List?;
            if (items != null) {
              for (var item in items) {
                if (item is Map && item["activo"] == true) {
                  final desc = item["descripcion"] ?? "";
                  if (desc.toString().trim().isNotEmpty) {
                    acabadosManuales.add(
                      AcabadoManualItem(
                        id:
                            DateTime.now().millisecondsSinceEpoch.toString() +
                            item.hashCode.toString(),
                        desc: "$titulo: $desc",
                        piezas: cotizacion.cantidadImpresiones.toString(),
                      ),
                    );
                  }
                }
              }
            }
          }
        }

        laminadoProyecto = cotizacion.descripcion;
        laminadoPliegos = cotizacion.totalPliegos;

        barnizProyecto = cotizacion.descripcion;
        barnizPliegos = cotizacion.totalPliegos;

        suajeProyecto = cotizacion.descripcion;
        serigrafiaProyecto = cotizacion.descripcion;
        grabadoProyecto = cotizacion.descripcion;
        grabadoPiezas = cotizacion.cantidadImpresiones;
        acabadoProyecto = cotizacion.descripcion;
      } else {
        if (cotizacion.configDatosPapel != null) {
          final dpInt = cotizacion.configDatosPapel!["interior"];
          if (dpInt != null && dpInt["nombre"]?.toString().isNotEmpty == true) {
            agregarMaterial(
              'Papel Int: ${dpInt["nombre"]} - ${dpInt["peso"] ?? ""}',
              cotizacion.totalPliegos,
            );
          }
          final dpPort = cotizacion.configDatosPapel!["portada"];
          if (dpPort != null && dpPort["nombre"]?.toString().isNotEmpty == true) {
            final pliegosPortada =
                int.tryParse(
                  cotizacion.configPliegos?["portada"]?["totalPliegos"]
                          ?.toString() ??
                      "0",
                ) ??
                0;
            agregarMaterial(
              'Papel Portada: ${dpPort["nombre"]} - ${dpPort["peso"] ?? ""}',
              pliegosPortada,
            );
          }
        }

        if (cotizacion.configClientes != null) {
          final cli = cotizacion.configClientes!;
          final pcInt = cli["pruebaColorInternasDetalles"];
          if (pcInt != null) {
            if (pcInt["carta"]?["activo"] == true) {
              agregarMaterial(
                'Prueba Color Carta (Interna)',
                int.tryParse(pcInt["carta"]["cantidad"]?.toString() ?? "0") ??
                    0,
              );
            }
            if (pcInt["tabloide"]?["activo"] == true) {
              agregarMaterial(
                'Prueba Color Tabloide (Interna)',
                int.tryParse(
                      pcInt["tabloide"]["cantidad"]?.toString() ?? "0",
                    ) ??
                    0,
              );
            }
            if (pcInt["mediaCarta"]?["activo"] == true) {
              agregarMaterial(
                'Prueba Color Media Carta (Interna)',
                int.tryParse(
                      pcInt["mediaCarta"]["cantidad"]?.toString() ?? "0",
                    ) ??
                    0,
              );
            }
          }
        }

        if (cotizacion.configMaquina != null &&
            cotizacion.configMaquina!["offsetActivo"] == true) {
          final maqInt = cotizacion.configMaquina!["interior"];
          if (maqInt != null) {
            agregarMaterial(
              'Placas Offset 615x724 (Int)',
              int.tryParse(maqInt["cantidadPlacas"]?.toString() ?? "0") ?? 0,
            );
            agregarMaterial(
              'Placas Offset 790x724 (Int)',
              int.tryParse(maqInt["cantidadPlacas790"]?.toString() ?? "0") ?? 0,
            );
          }
        }

        if (cotizacion.configSuaje != null &&
            cotizacion.configSuaje!["suajeActivo"] == true) {
          if (!(cotizacion.configSuaje!["seCuentaConSuaje"] ?? false)) {
            agregarMaterial(
              'Fabricación de Suaje Nuevo (${cotizacion.configSuaje!["tamanoSuaje"] ?? "S/M"})',
              1,
            );
          }
        }

        if (cotizacion.configSerigrafia != null &&
            cotizacion.configSerigrafia!["serigrafiaActivo"] == true) {
          final sg = cotizacion.configSerigrafia!;
          agregarMaterial(
            'Marcos Serigrafía',
            int.tryParse(sg["cantidadMarcos"]?.toString() ?? "0") ?? 0,
          );
        }

        if (cotizacion.configGrabado != null &&
            cotizacion.configGrabado!["grabadoActivo"] == true) {
          agregarMaterial(
            'Placas Grabado',
            int.tryParse(
                  cotizacion.configGrabado!["cantidadPlacas"]?.toString() ??
                      "0",
                ) ??
                0,
          );
        }

        if (cotizacion.configEmbalaje != null &&
            cotizacion.configEmbalaje!["embalajeActivo"] == true) {
          final items = cotizacion.configEmbalaje!["items"] as List?;
          if (items != null) {
            for (var item in items) {
              agregarMaterial(
                'Embalaje: ${item["item"]}',
                int.tryParse(item["cantidad"]?.toString() ?? "0") ?? 0,
              );
            }
          }
        }

        offsetTipoTrabajo = cotizacion.descripcion;
        offsetPiezasPedidas = cotizacion.cantidadImpresiones;

        int cantidadPliegos = 0;
        int pliegosSobrantes = 0;
        int totalPliegos = cotizacion.totalPliegos;

        if (cotizacion.configPliegos != null &&
            cotizacion.configPliegos!["interior"] != null) {
          final pInt = cotizacion.configPliegos!["interior"];
          cantidadPliegos =
              int.tryParse(pInt["cantidadPliegos"]?.toString() ?? "0") ?? 0;
          pliegosSobrantes =
              int.tryParse(pInt["pliegosSobrantes"]?.toString() ?? "0") ?? 0;
          if (totalPliegos == 0) {
            totalPliegos =
                int.tryParse(pInt["totalPliegos"]?.toString() ?? "0") ?? 0;
          }
        }

        offsetPapelNecesario = (cantidadPliegos + pliegosSobrantes).toString();
        offsetPapelLlegara = totalPliegos.toString();

        laminadoProyecto = cotizacion.descripcion;
        laminadoPliegos = cotizacion.totalPliegos;
        if (cotizacion.configLaminado != null) {
          final lamInt = cotizacion.configLaminado!["interior"];
          if (lamInt != null && lamInt["laminadosActivo"] == true) {
            final detalles = lamInt["detalles"];
            if (detalles != null && detalles is Map) {
              detalles.forEach((key, val) {
                if (val["frente"] == true) laminadoAplicacion['frente'] = true;
                if (val["vuelta"] == true) laminadoAplicacion['vuelta'] = true;
              });
            }
          }
        }

        barnizProyecto = cotizacion.descripcion;
        barnizPliegos = cotizacion.totalPliegos;
        if (cotizacion.configAcabados != null) {
          final acInt = cotizacion.configAcabados!["interior"];
          if (acInt != null && acInt["barnizUV"] == true) {
            final detalles = acInt["detalles"];
            if (detalles != null && detalles is Map) {
              detalles.forEach((key, val) {
                if (val["frente"] == true) barnizAplicacion['frente'] = true;
                if (val["vuelta"] == true) barnizAplicacion['vuelta'] = true;
              });
            }
          }
        }

        suajeProyecto = cotizacion.descripcion;
        if (cotizacion.configSuaje != null &&
            cotizacion.configSuaje!["suajeActivo"] == true) {
          final sj = cotizacion.configSuaje!;
          suajePliegos =
              int.tryParse(sj["pliegosSuaje"]?.toString() ?? "0") ?? 0;
          suajeMarcoExistente = sj["seCuentaConSuaje"] ?? false;
          suajeMarcoNuevo = !(sj["seCuentaConSuaje"] ?? false);
        }

        if (cotizacion.configSerigrafia != null &&
            cotizacion.configSerigrafia!["serigrafiaActivo"] == true) {
          final sg = cotizacion.configSerigrafia!;
          serigrafiaProyecto = cotizacion.descripcion;
          serigrafiaPiezas =
              int.tryParse(sg["numeroEntradas"]?.toString() ?? "0") ?? 0;
          serigrafiaMarcos =
              "${sg["cantidadMarcos"]?.toString() ?? '0'} Marcos";
          serigrafiaPantoneCode =
              "${sg["cantidadTintas"]?.toString() ?? '0'} Tintas";
        }

        grabadoProyecto = cotizacion.descripcion;
        grabadoPiezas = cotizacion.cantidadImpresiones;
        if (cotizacion.configGrabado != null &&
            cotizacion.configGrabado!["grabadoActivo"] == true) {
          final gr = cotizacion.configGrabado!;
          grabadoPlacas = gr["cantidadPlacas"]?.toString() ?? "0";
        }

        acabadoProyecto = cotizacion.descripcion;
        if (cotizacion.configAcabadosEspeciales != null &&
            cotizacion.configAcabadosEspeciales!["activo"] == true) {
          final detallesAcabados =
              cotizacion.configAcabadosEspeciales!["detalles"] as List?;
          if (detallesAcabados != null) {
            for (var detalle in detallesAcabados) {
              if (detalle is Map) {
                acabadosManuales.add(
                  AcabadoManualItem(
                    id:
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        detalle.hashCode.toString(),
                    desc: detalle["descripcion"] ?? '',
                    piezas: cotizacion.cantidadImpresiones.toString(),
                  ),
                );
              }
            }
          }
        }
      }

      logisticaFechaEntrega = '';
      logisticaDireccion = '';
      logisticaTransporte = '';
      logisticaTotalEntregar = cotizacion.cantidadImpresiones;
      logisticaNotas = '';
      logisticaNotasTaller = '';
    } catch (e, stack) {
      print("⚠️ Error al parsear los datos de la cotización: $e\n$stack");
    }
  }

  // ==========================================
  // VARIABLES Y MÉTODOS POR DEPARTAMENTO
  // ==========================================

  // --- 1. ADQUISICIONES ---
  List<MaterialItem> materials = [];
  String adquisicionesNotas = '';
  String adquisicionesNotasTaller = '';

  void addMaterial() {
    materials.add(
      MaterialItem(id: DateTime.now().millisecondsSinceEpoch.toString()),
    );
    notifyListeners();
  }

  void removeMaterial(String id) {
    materials.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void updateAdquisiciones(String campo, String valor) {
    if (campo == 'notas') adquisicionesNotas = valor;
    if (campo == 'notasTaller') adquisicionesNotasTaller = valor;
    notifyListeners();
  }

  // --- 2. DISEÑO ---
  List<DesignTask> designTasks = [];
  String disenoNotas = '';
  String disenoNotasTaller = '';

  void addDesignTask() {
    designTasks.add(
      DesignTask(id: DateTime.now().millisecondsSinceEpoch.toString()),
    );
    notifyListeners();
  }

  void removeDesignTask(String id) {
    designTasks.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void updateDiseno(String campo, String valor) {
    if (campo == 'notas') disenoNotas = valor;
    if (campo == 'notasTaller') disenoNotasTaller = valor;
    notifyListeners();
  }

  // --- 3. OFFSET ---
  
  String offsetTipoTrabajo = '';
  String offsetNombrePapel = ''; // <--- Añade esto para que el getter exista
  int offsetPiezasPedidas = 0;
  String offsetPapelNecesario = '';
  String offsetPapelLlegara = '';
  String offsetNotas = '';
  String offsetNotasTaller = '';
  Map<String, dynamic> offsetData = {
    'frente': {
      'C': false,
      'M': false,
      'Y': false,
      'K': false,
      'especial': false,
      'pantone': false,
      'tinta_esp': '',
    },
    'vuelta': {
      'C': false,
      'M': false,
      'Y': false,
      'K': false,
      'especial': false,
      'pantone': false,
      'tinta_esp': '',
    },
  };

  void updateOffsetInk(String cara, String color, dynamic value) {
    offsetData[cara][color] = value;
    notifyListeners();
  }

  void updateOffsetTexto(String campo, String valor) {
    if (campo == 'tipo') offsetTipoTrabajo = valor;
    if (campo == 'piezas') offsetPiezasPedidas = int.tryParse(valor) ?? 0;
    if (campo == 'necesario') offsetPapelNecesario = valor;
    if (campo == 'llegara') offsetPapelLlegara = valor;
    if (campo == 'notas') offsetNotas = valor;
    if (campo == 'notasTaller') offsetNotasTaller = valor;
    notifyListeners();
  }

  // --- 4. CORTE ---
  List<CutProcess> cuts = [];
  String corteNotas = '';
  String corteNotasTaller = '';

  void addCut() {
    cuts.add(CutProcess(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }

  void removeCut(String id) {
    cuts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void updateCorte(String campo, String valor) {
    if (campo == 'notas') corteNotas = valor;
    if (campo == 'notasTaller') corteNotasTaller = valor;
    notifyListeners();
  }

  // --- 5. LAMINADOS ---
  String laminadoProyecto = '';
  String laminadoAcabado = 'Brillante';
  int laminadoPliegos = 0;
  Map<String, bool> laminadoAplicacion = {'frente': false, 'vuelta': false};
  bool laminadoMaquinaChica = false;
  bool laminadoMaquinaGrande = false;
  String laminadoNotas = '';
  String laminadoNotasTaller = '';

  void updateLaminadoAplicacion(String cara, bool value) {
    laminadoAplicacion[cara] = value;
    notifyListeners();
  }

  void updateMaquinaLaminado(String tipo, bool value) {
    if (tipo == 'chica') laminadoMaquinaChica = value;
    if (tipo == 'grande') laminadoMaquinaGrande = value;
    notifyListeners();
  }

  void updateLaminadoGeneral(String campo, dynamic valor) {
    if (campo == 'proyecto') laminadoProyecto = valor;
    if (campo == 'acabado') laminadoAcabado = valor;
    if (campo == 'pliegos')
      laminadoPliegos = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'notas') laminadoNotas = valor;
    if (campo == 'notasTaller') laminadoNotasTaller = valor;
    notifyListeners();
  }

  // --- 6. SUAJE ---
  String suajeProyecto = '';
  int suajePliegos = 0;
  bool suajeEsRomosso = false;
  bool suajeEsMaquilador = false;
  String suajeNombreMaquila = '';
  bool suajeMarcoExistente = false;
  bool suajeMarcoNuevo = false;
  String suajeNotas = '';
  String suajeNotasTaller = '';

  void updateSuaje(String campo, dynamic valor) {
    if (campo == 'proyecto') suajeProyecto = valor;
    if (campo == 'pliegos') suajePliegos = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'nombreMaquila') suajeNombreMaquila = valor;
    if (campo == 'notas') suajeNotas = valor;
    if (campo == 'notasTaller') suajeNotasTaller = valor;
    if (campo == 'romosso') {
      suajeEsRomosso = valor;
      if (valor) suajeEsMaquilador = false;
    }
    if (campo == 'maquilador') {
      suajeEsMaquilador = valor;
      if (valor) suajeEsRomosso = false;
    }
    if (campo == 'existente') {
      suajeMarcoExistente = valor;
      if (valor) suajeMarcoNuevo = false;
    }
    if (campo == 'nuevo') {
      suajeMarcoNuevo = valor;
      if (valor) suajeMarcoExistente = false;
    }
    notifyListeners();
  }

  // --- 7. SERIGRAFÍA ---
  String serigrafiaProyecto = '';
  int serigrafiaPiezas = 0;
  String serigrafiaMarcos = '';
  bool serigrafiaMarcoExistente = false;
  bool serigrafiaMarcoNuevo = false;
  bool serigrafiaEsRomosso = false;
  bool serigrafiaEsMaquilador = false;
  String serigrafiaNombreMaquila = '';
  String serigrafiaModo = 'pantone';
  String serigrafiaPantoneCode = '';
  Color serigrafiaColorDirecto = Colors.blue;
  String serigrafiaNotas = '';
  String serigrafiaNotasTaller = '';

  void updateSerigrafiaGeneral(String campo, dynamic valor) {
    if (campo == 'proyecto') serigrafiaProyecto = valor;
    if (campo == 'piezas')
      serigrafiaPiezas = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'marcos') serigrafiaMarcos = valor;
    if (campo == 'nombreMaquila') serigrafiaNombreMaquila = valor;
    if (campo == 'notas') serigrafiaNotas = valor;
    if (campo == 'notasTaller') serigrafiaNotasTaller = valor;
    if (campo == 'marcoExistente') {
      serigrafiaMarcoExistente = valor;
      if (valor) serigrafiaMarcoNuevo = false;
    }
    if (campo == 'marcoNuevo') {
      serigrafiaMarcoNuevo = valor;
      if (valor) serigrafiaMarcoExistente = false;
    }
    if (campo == 'romosso') {
      serigrafiaEsRomosso = valor;
      if (valor) serigrafiaEsMaquilador = false;
    }
    if (campo == 'maquilador') {
      serigrafiaEsMaquilador = valor;
      if (valor) serigrafiaEsRomosso = false;
    }
    notifyListeners();
  }

  void updateSerigrafiaModo(String modo) {
    serigrafiaModo = modo;
    notifyListeners();
  }

  void updateSerigrafiaPantone(String code) {
    serigrafiaPantoneCode = code;
    notifyListeners();
  }

  void updateSerigrafiaColor(Color color) {
    serigrafiaColorDirecto = color;
    notifyListeners();
  }

  // --- 8. GRABADO ---
  String grabadoProyecto = '';
  String grabadoPlacas = '';
  int grabadoPiezas = 0;
  bool grabadoEsRomosso = false;
  bool grabadoEsMaquilador = false;
  String grabadoNombreMaquila = '';
  String grabadoNotas = '';
  String grabadoNotasTaller = '';

  void updateGrabado(String campo, dynamic valor) {
    if (campo == 'proyecto') grabadoProyecto = valor;
    if (campo == 'placas') grabadoPlacas = valor;
    if (campo == 'piezas') grabadoPiezas = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'nombreMaquila') grabadoNombreMaquila = valor;
    if (campo == 'notas') grabadoNotas = valor;
    if (campo == 'notasTaller') grabadoNotasTaller = valor;
    if (campo == 'romosso') {
      grabadoEsRomosso = valor;
      if (valor) grabadoEsMaquilador = false;
    }
    if (campo == 'maquilador') {
      grabadoEsMaquilador = valor;
      if (valor) grabadoEsRomosso = false;
    }
    notifyListeners();
  }

  // --- 9. ACABADO ---
  String acabadoProyecto = '';
  String acabadoDescripcion = '';
  int acabadoCantidad = 0;
  String acabadoNotas = '';
  String acabadoNotasTaller = '';
  List<AcabadoManualItem> acabadosManuales = [];

  void updateAcabado(String campo, String valor) {
    if (campo == 'proyecto') acabadoProyecto = valor;
    if (campo == 'descripcion') acabadoDescripcion = valor;
    if (campo == 'cantidad') acabadoCantidad = int.tryParse(valor) ?? 0;
    if (campo == 'notas') acabadoNotas = valor;
    if (campo == 'notasTaller') acabadoNotasTaller = valor;
    notifyListeners();
  }

  void addAcabadoManual() {
    acabadosManuales.add(
      AcabadoManualItem(id: DateTime.now().millisecondsSinceEpoch.toString()),
    );
    notifyListeners();
  }

  void removeAcabadoManual(String id) {
    acabadosManuales.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // --- 10. BARNIZ UV ---
  String barnizProyecto = '';
  int barnizPliegos = 0;
  Map<String, bool> barnizAplicacion = {'frente': false, 'vuelta': false};
  bool barnizEsRomosso = true;
  bool barnizEsMaquilador = false;
  String barnizNombreMaquila = '';
  String barnizNotas = '';
  String barnizNotasTaller = '';

  void updateBarnizGeneral(String campo, dynamic valor) {
    if (campo == 'proyecto') barnizProyecto = valor;
    if (campo == 'pliegos') barnizPliegos = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'nombreMaquila') barnizNombreMaquila = valor;
    if (campo == 'notas') barnizNotas = valor;
    if (campo == 'notasTaller') barnizNotasTaller = valor;
    if (campo == 'romosso') {
      barnizEsRomosso = valor;
      if (valor) barnizEsMaquilador = false;
    }
    if (campo == 'maquilador') {
      barnizEsMaquilador = valor;
      if (valor) barnizEsRomosso = false;
    }
    notifyListeners();
  }

  void updateBarnizAplicacion(String cara, bool value) {
    barnizAplicacion[cara] = value;
    notifyListeners();
  }

  // --- 10. EMBALAJE ---
  String embalajeTipo = '';
  int embalajeCantidadCajas = 0;
  String embalajeNotas = '';
  String embalajeNotasTaller = '';

  void updateEmbalaje(String campo, String valor) {
    if (campo == 'tipo') embalajeTipo = valor;
    if (campo == 'cantidad') embalajeCantidadCajas = int.tryParse(valor) ?? 0;
    if (campo == 'notas') embalajeNotas = valor;
    if (campo == 'notasTaller') embalajeNotasTaller = valor;
    notifyListeners();
  }

  // --- 11. LOGÍSTICA ---
  String logisticaFechaEntrega = '';
  String logisticaDireccion = '';
  String logisticaTransporte = '';
  int logisticaTotalEntregar = 0;
  String logisticaNotas = '';
  String logisticaNotasTaller = '';

  void updateLogistica(String campo, String valor) {
    if (campo == 'fecha') logisticaFechaEntrega = valor;
    if (campo == 'direccion') logisticaDireccion = valor;
    if (campo == 'transporte') logisticaTransporte = valor;
    if (campo == 'total') logisticaTotalEntregar = int.tryParse(valor) ?? 0;
    if (campo == 'notas') logisticaNotas = valor;
    if (campo == 'notasTaller') logisticaNotasTaller = valor;
    notifyListeners();
  }

  Future<bool> guardarOrdenTrabajo() async {
    if (currentCotizacionId.isEmpty) {
      print("Error: No hay cotización vinculada para guardar esta OT.");
      return false;
    }

    try {
      final datosCompletos = {
        "tipoCotizacion": tipoCotizacionActual,
        "activeSections": activeSections,
        "adquisiciones": {
          "estatus": tiempos['adquisiciones']?.estatus,
          "inicio": tiempos['adquisiciones']?.inicio,
          "fin": tiempos['adquisiciones']?.fin,
          "notas": adquisicionesNotas,
          "notasTaller": adquisicionesNotasTaller,
          "materiales": materials
              .map(
                (m) => {
                  "nombre": m.nombre,
                  "proveedor": m.proveedor,
                  "cantidad": m.cantidad,
                },
              )
              .toList(),
        },
        "diseno": {
          "estatus": tiempos['diseno']?.estatus,
          "inicio": tiempos['diseno']?.inicio,
          "fin": tiempos['diseno']?.fin,
          "notas": disenoNotas,
          "notasTaller": disenoNotasTaller,
          "tareas": designTasks.map((t) => {"desc": t.desc}).toList(),
        },
          "offset": {
          "estatus": tiempos['offset']?.estatus,
          "inicio": tiempos['offset']?.inicio,
          "fin": tiempos['offset']?.fin,
          "tipoTrabajo": offsetTipoTrabajo,
          "piezasPedidas": offsetPiezasPedidas,
          "papelNecesario": offsetPapelNecesario,
          "papelLlegara": offsetPapelLlegara,
          "tintas": offsetData,
          "notas": offsetNotas,
          "notasTaller": offsetNotasTaller,
          // >>> MAPEAR LOS SETS ADICIONALES CON SUS TINTAS PARA GUARDAR EN POSTGRES <<<
          "papelesExtra": papelesExtra.map((p) => {
            "id": p.id,
            "nombrePapel": p.nombrePapel,
            "piezas": p.piezas,
            "papelNecesario": p.papelNecesario,
            "papelLlegara": p.papelLlegara,
            "tintas": p.tintas,
            }).toList(),
        },
        "corte": {
          "estatus": tiempos['corte']?.estatus,
          "inicio": tiempos['corte']?.inicio,
          "fin": tiempos['corte']?.fin,
          "notas": corteNotas,
          "notasTaller": corteNotasTaller,
          "procesos": cuts
              .map(
                (c) => {
                  "tipo": c.tipo,
                  "desc": c.desc,
                  "despuesDe": c.despuesDe,
                  "fecha": c.fecha,
                },
              )
              .toList(),
        },
        "laminados": {
          "estatus": tiempos['laminados']?.estatus,
          "inicio": tiempos['laminados']?.inicio,
          "fin": tiempos['laminados']?.fin,
          "proyecto": laminadoProyecto,
          "acabado": laminadoAcabado,
          "pliegos": laminadoPliegos,
          "aplicacion": laminadoAplicacion,
          "maquinaChica": laminadoMaquinaChica,
          "maquinaGrande": laminadoMaquinaGrande,
          "notas": laminadoNotas,
          "notasTaller": laminadoNotasTaller,
        },
        "suaje": {
          "estatus": tiempos['suaje']?.estatus,
          "inicio": tiempos['suaje']?.inicio,
          "fin": tiempos['suaje']?.fin,
          "proyecto": suajeProyecto,
          "pliegos": suajePliegos,
          "esRomosso": suajeEsRomosso,
          "esMaquilador": suajeEsMaquilador,
          "nombreMaquila": suajeNombreMaquila,
          "marcoExistente": suajeMarcoExistente,
          "marcoNuevo": suajeMarcoNuevo,
          "notas": suajeNotas,
          "notasTaller": suajeNotasTaller,
        },
        "serigrafia": {
          "estatus": tiempos['serigrafia']?.estatus,
          "inicio": tiempos['serigrafia']?.inicio,
          "fin": tiempos['serigrafia']?.fin,
          "proyecto": serigrafiaProyecto,
          "piezas": serigrafiaPiezas,
          "marcos": serigrafiaMarcos,
          "marcoExistente": serigrafiaMarcoExistente,
          "marcoNuevo": serigrafiaMarcoNuevo,
          "esRomosso": serigrafiaEsRomosso,
          "esMaquilador": serigrafiaEsMaquilador,
          "nombreMaquila": serigrafiaNombreMaquila,
          "modoColor": serigrafiaModo,
          "pantoneCode": serigrafiaPantoneCode,
          "colorDirecto": serigrafiaColorDirecto.value,
          "notas": serigrafiaNotas,
          "notasTaller": serigrafiaNotasTaller,
        },
        "grabado": {
          "estatus": tiempos['grabado']?.estatus,
          "inicio": tiempos['grabado']?.inicio,
          "fin": tiempos['grabado']?.fin,
          "proyecto": grabadoProyecto,
          "placas": grabadoPlacas,
          "piezas": grabadoPiezas,
          "esRomosso": grabadoEsRomosso,
          "esMaquilador": grabadoEsMaquilador,
          "nombreMaquila": grabadoNombreMaquila,
          "notas": grabadoNotas,
          "notasTaller": grabadoNotasTaller,
        },
        "acabado": {
          "estatus": tiempos['acabado']?.estatus,
          "inicio": tiempos['acabado']?.inicio,
          "fin": tiempos['acabado']?.fin,
          "proyecto": acabadoProyecto,
          "descripcionBD": acabadoDescripcion,
          "cantidadBD": acabadoCantidad,
          "notas": acabadoNotas,
          "notasTaller": acabadoNotasTaller,
          "manuales": acabadosManuales
              .map((a) => {"desc": a.desc, "piezas": a.piezas})
              .toList(),
        },
        "barniz": {
          "estatus": tiempos['barniz']?.estatus,
          "inicio": tiempos['barniz']?.inicio,
          "fin": tiempos['barniz']?.fin,
          "proyecto": barnizProyecto,
          "pliegos": barnizPliegos,
          "aplicacion": barnizAplicacion,
          "esRomosso": barnizEsRomosso,
          "esMaquilador": barnizEsMaquilador,
          "nombreMaquila": barnizNombreMaquila,
          "notas": barnizNotas,
          "notasTaller": barnizNotasTaller,
        },
        "embalaje": {
          "estatus": tiempos['embalaje']?.estatus,
          "inicio": tiempos['embalaje']?.inicio,
          "fin": tiempos['embalaje']?.fin,
          "tipo": embalajeTipo,
          "cantidadCajas": embalajeCantidadCajas,
          "notas": embalajeNotas,
          "notasTaller": embalajeNotasTaller,
        },
        "logistica": {
          "estatus": tiempos['logistica']?.estatus,
          "inicio": tiempos['logistica']?.inicio,
          "fin": tiempos['logistica']?.fin,
          "fechaEntrega": logisticaFechaEntrega,
          "direccion": logisticaDireccion,
          "transporte": logisticaTransporte,
          "totalEntregar": logisticaTotalEntregar,
          "notas": logisticaNotas,
          "notasTaller": logisticaNotasTaller,
        },
      };

      DateTime? fechaEntregaNativa;
      if (logisticaFechaEntrega.isNotEmpty) {
        try {
          final partes = logisticaFechaEntrega.split('/');
          if (partes.length == 3) {
            int dia = int.parse(partes[0]);
            int mes = int.parse(partes[1]);
            int anio = int.parse(partes[2]);
            fechaEntregaNativa = DateTime(anio, mes, dia);
          }
        } catch (e) {
          print("Aviso: No se pudo parsear la fecha de entrega a DateTime: $e");
        }
      }

      final orden = OrdenTrabajo(
        id: ordenTrabajoDbId,
        cotizacionId: currentCotizacionId,
        estatus: 'En Proceso',
        datosCompletos: datosCompletos,
        fechaEntrega: fechaEntregaNativa,
      );

      bool exito;
      if (ordenTrabajoDbId == null) {
        exito = await _service.crearOrden(orden);
      } else {
        exito = await _service.actualizarOrden(orden);
      }

      return exito;
    } catch (e) {
      print("Error Crítico al intentar guardar la Orden de Trabajo: $e");
      return false;
    }
  }
}

// ==========================================
// 3. EL PROVIDER DE RIVERPOD
// ==========================================
final ordenTrabajoProvider =
    ChangeNotifierProvider.autoDispose<OrdenTrabajoController>((ref) {
      return OrdenTrabajoController();
    });