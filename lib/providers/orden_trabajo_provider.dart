// lib/providers/orden_trabajo_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cotizacion_model.dart';
import '../models/ordenTrabajo_model.dart';
import '../services/ordenTrabajo_service.dart';
import 'cotizacion_provider.dart';

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

  bool isLoading = false;
  String sessionKey = '';
  String orderId = "S/F"; // Número de orden simulado
  String currentCotizacionId = "";
  String? ordenTrabajoDbId;

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
    } catch (e) {
      orderId = "S/F";
      print(
        "⚠️ Aviso: No se encontró la cotización en memoria para extraer el folio.",
      );
    }
    final ordenGuardada = await _service.obtenerOrdenPorCotizacionId(id);

    if (ordenGuardada != null) {
      ordenTrabajoDbId = ordenGuardada.id;
      print("Orden existente encontrada en DB. Lista para actualizar.");
      _cargarDesdeBaseDeDatos(ordenGuardada.datosCompletos);
    } else {
      ordenTrabajoDbId = null;
      print("Orden nueva. Se creará un nuevo registro.");
      final cotizacionesState = ref.read(cotizacionesProvider);
      try {
        final cotizacion = cotizacionesState.cotizaciones.firstWhere(
          (c) => c.id == id,
        );
        cargarDatosDeCotizacion(cotizacion);
      } catch (e) {
        print("⚠️ Error: No se encontró la cotización con ID $id en memoria.");
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void _cargarDesdeBaseDeDatos(Map<String, dynamic> dbData) {
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
      if (dbData['offset']['tintas'] != null) {
        final tintasDb = dbData['offset']['tintas'] as Map<String, dynamic>;
        offsetData = {
          'frente': Map<String, dynamic>.from(tintasDb['frente'] ?? {}),
          'vuelta': Map<String, dynamic>.from(tintasDb['vuelta'] ?? {}),
        };
      }
    }

    if (dbData['corte'] != null) {
      corteNotas = dbData['corte']['notas'] ?? '';
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
    }
    if (dbData['grabado'] != null) {
      grabadoProyecto = dbData['grabado']['proyecto'] ?? '';
      grabadoPlacas = dbData['grabado']['placas'] ?? '';
      grabadoPiezas = dbData['grabado']['piezas'] ?? 0;
      grabadoEsRomosso = dbData['grabado']['esRomosso'] ?? false;
      grabadoEsMaquilador = dbData['grabado']['esMaquilador'] ?? false;
      grabadoNombreMaquila = dbData['grabado']['nombreMaquila'] ?? '';
      grabadoNotas = dbData['grabado']['notas'] ?? '';
    }
    if (dbData['barniz'] != null) {
      barnizProyecto = dbData['barniz']['proyecto'] ?? '';
      barnizPliegos =
          int.tryParse(dbData['barniz']['pliegos']?.toString() ?? '0') ?? 0;
      barnizEsRomosso = dbData['barniz']['esRomosso'] ?? true;
      barnizEsMaquilador = dbData['barniz']['esMaquilador'] ?? false;
      barnizNombreMaquila = dbData['barniz']['nombreMaquila'] ?? '';
      barnizNotas = dbData['barniz']['notas'] ?? '';
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
    }
    if (dbData['logistica'] != null) {
      logisticaFechaEntrega = dbData['logistica']['fechaEntrega'] ?? '';
      logisticaDireccion = dbData['logistica']['direccion'] ?? '';
      logisticaTransporte = dbData['logistica']['transporte'] ?? '';
      logisticaTotalEntregar = dbData['logistica']['totalEntregar'] ?? 0;
      logisticaNotas = dbData['logistica']['notas'] ?? '';
    }
  }

  void cargarDatosDeCotizacion(Cotizacion? cotizacion) {
    if (cotizacion == null) return;

    orderId = cotizacion.folio ?? "S/F";

    for (var key in tiempos.keys) {
      tiempos[key] = TiempoProceso();
    }

    materials.clear();
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
          if (pcInt["carta"]?["activo"] == true)
            agregarMaterial(
              'Prueba Color Carta (Interna)',
              int.tryParse(pcInt["carta"]["cantidad"]?.toString() ?? "0") ?? 0,
            );
          if (pcInt["tabloide"]?["activo"] == true)
            agregarMaterial(
              'Prueba Color Tabloide (Interna)',
              int.tryParse(pcInt["tabloide"]["cantidad"]?.toString() ?? "0") ??
                  0,
            );
          if (pcInt["mediaCarta"]?["activo"] == true)
            agregarMaterial(
              'Prueba Color Media Carta (Interna)',
              int.tryParse(
                    pcInt["mediaCarta"]["cantidad"]?.toString() ?? "0",
                  ) ??
                  0,
            );
        }
        if (cli["pruebaColorPortada"] == true) {
          final pcPort = cli["pruebaColorPortadaDetalles"];
          if (pcPort != null) {
            if (pcPort["carta"]?["activo"] == true)
              agregarMaterial(
                'Prueba Color Carta (Portada)',
                int.tryParse(pcPort["carta"]["cantidad"]?.toString() ?? "0") ??
                    0,
              );
            if (pcPort["tabloide"]?["activo"] == true)
              agregarMaterial(
                'Prueba Color Tabloide (Portada)',
                int.tryParse(
                      pcPort["tabloide"]["cantidad"]?.toString() ?? "0",
                    ) ??
                    0,
              );
            if (pcPort["mediaCarta"]?["activo"] == true)
              agregarMaterial(
                'Prueba Color Media Carta (Portada)',
                int.tryParse(
                      pcPort["mediaCarta"]["cantidad"]?.toString() ?? "0",
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
        final maqPort = cotizacion.configMaquina!["portada"];
        if (maqPort != null) {
          agregarMaterial(
            'Placas Offset 615x724 (Port)',
            int.tryParse(maqPort["cantidadPlacas"]?.toString() ?? "0") ?? 0,
          );
          agregarMaterial(
            'Placas Offset 790x724 (Port)',
            int.tryParse(maqPort["cantidadPlacas790"]?.toString() ?? "0") ?? 0,
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
        agregarMaterial(
          'Negativos Serigrafía',
          int.tryParse(sg["cantidadNegativos"]?.toString() ?? "0") ?? 0,
        );
        agregarMaterial(
          'Tintas Serigrafía',
          int.tryParse(sg["cantidadTintas"]?.toString() ?? "0") ?? 0,
        );
      }

      if (cotizacion.configGrabado != null &&
          cotizacion.configGrabado!["grabadoActivo"] == true) {
        agregarMaterial(
          'Placas Grabado',
          int.tryParse(
                cotizacion.configGrabado!["cantidadPlacas"]?.toString() ?? "0",
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

      disenoNotas = 'Revisar archivos para: ${cotizacion.descripcion}';

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
        if (totalPliegos == 0)
          totalPliegos =
              int.tryParse(pInt["totalPliegos"]?.toString() ?? "0") ?? 0;
      }

      offsetPapelNecesario = (cantidadPliegos + pliegosSobrantes).toString();
      offsetPapelLlegara = totalPliegos.toString();

      offsetNotas = '';
      offsetData = {
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

      laminadoProyecto = cotizacion.descripcion;
      laminadoAcabado = 'Brillante';
      laminadoPliegos = cotizacion.totalPliegos;
      if (cotizacion.configLaminado != null) {
        final lamInt = cotizacion.configLaminado!["interior"];
        if (lamInt != null && lamInt["laminadosActivo"] == true) {
          final detalles = lamInt["detalles"];
          if (detalles != null) {
            detalles.forEach((key, val) {
              if (val["frente"] == true) laminadoAplicacion['frente'] = true;
              if (val["vuelta"] == true) laminadoAplicacion['vuelta'] = true;
              if (val["frente"] == true || val["vuelta"] == true)
                laminadoNotas += "- $key\n";
            });
          }
        }
      }

      barnizProyecto = cotizacion.descripcion;
      barnizPliegos = cotizacion.totalPliegos;
      barnizEsRomosso = true;
      barnizEsMaquilador = false;
      barnizNombreMaquila = '';
      barnizNotas = '';
      barnizAplicacion = {'frente': false, 'vuelta': false};

      if (cotizacion.configAcabados != null) {
        final acInt = cotizacion.configAcabados!["interior"];
        if (acInt != null && acInt["barnizUV"] == true) {
          final detalles = acInt["detalles"];
          if (detalles != null) {
            detalles.forEach((key, val) {
              if (val["frente"] == true) barnizAplicacion['frente'] = true;
              if (val["vuelta"] == true) barnizAplicacion['vuelta'] = true;
              if (val["frente"] == true || val["vuelta"] == true)
                barnizNotas += "- $key\n";
            });
          }
        }
      }

      suajeProyecto = cotizacion.descripcion;
      if (cotizacion.configSuaje != null &&
          cotizacion.configSuaje!["suajeActivo"] == true) {
        final sj = cotizacion.configSuaje!;
        suajePliegos = int.tryParse(sj["pliegosSuaje"]?.toString() ?? "0") ?? 0;
        suajeMarcoExistente = sj["seCuentaConSuaje"] ?? false;
        suajeMarcoNuevo = !(sj["seCuentaConSuaje"] ?? false);
      }

      if (cotizacion.configSerigrafia != null &&
          cotizacion.configSerigrafia!["serigrafiaActivo"] == true) {
        final sg = cotizacion.configSerigrafia!;
        serigrafiaProyecto = cotizacion.descripcion;
        serigrafiaPiezas =
            int.tryParse(sg["numeroEntradas"]?.toString() ?? "0") ?? 0;
        serigrafiaMarcos = "${sg["cantidadMarcos"]?.toString() ?? '0'} Marcos";
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
      acabadoCantidad = 0;
      acabadoDescripcion = '';
      acabadosManuales.clear();

      if (cotizacion.configAcabadosEspeciales != null &&
          cotizacion.configAcabadosEspeciales!["activo"] == true) {
        final detallesAcabados =
            cotizacion.configAcabadosEspeciales!["detalles"] as List?;
        if (detallesAcabados != null) {
          for (var detalle in detallesAcabados) {
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

      logisticaFechaEntrega = '';
      logisticaDireccion = '';
      logisticaTransporte = '';
      logisticaTotalEntregar = cotizacion.cantidadImpresiones;
      logisticaNotas = '';
    } catch (e) {
      print("⚠️ Error al parsear los datos de la cotización: $e");
    }
  }

  // ==========================================
  // VARIABLES Y MÉTODOS POR DEPARTAMENTO
  // ==========================================

  // --- 1. ADQUISICIONES ---
  List<MaterialItem> materials = [];
  String adquisicionesNotas = '';

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
  }

  // --- 2. DISEÑO ---
  List<DesignTask> designTasks = [];
  String disenoNotas = '';

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
  }

  // --- 3. OFFSET ---
  String offsetTipoTrabajo = '';
  int offsetPiezasPedidas = 0;
  String offsetPapelNecesario = '';
  String offsetPapelLlegara = '';
  String offsetNotas = '';
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
  }

  // --- 4. CORTE ---
  List<CutProcess> cuts = [];
  String corteNotas = '';

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
  }

  // --- 5. LAMINADOS ---
  String laminadoProyecto = '';
  String laminadoAcabado = 'Brillante';
  int laminadoPliegos = 0;
  Map<String, bool> laminadoAplicacion = {'frente': false, 'vuelta': false};
  bool laminadoMaquinaChica = false;
  bool laminadoMaquinaGrande = false;
  String laminadoNotas = '';

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

  void updateSuaje(String campo, dynamic valor) {
    if (campo == 'proyecto') suajeProyecto = valor;
    if (campo == 'pliegos') suajePliegos = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'nombreMaquila') suajeNombreMaquila = valor;
    if (campo == 'notas') suajeNotas = valor;
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

  void updateSerigrafiaGeneral(String campo, dynamic valor) {
    if (campo == 'proyecto') serigrafiaProyecto = valor;
    if (campo == 'piezas')
      serigrafiaPiezas = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'marcos') serigrafiaMarcos = valor;
    if (campo == 'nombreMaquila') serigrafiaNombreMaquila = valor;
    if (campo == 'notas') serigrafiaNotas = valor;
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

  void updateGrabado(String campo, dynamic valor) {
    if (campo == 'proyecto') grabadoProyecto = valor;
    if (campo == 'placas') grabadoPlacas = valor;
    if (campo == 'piezas') grabadoPiezas = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'nombreMaquila') grabadoNombreMaquila = valor;
    if (campo == 'notas') grabadoNotas = valor;
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
  List<AcabadoManualItem> acabadosManuales = [];

  void updateAcabado(String campo, String valor) {
    if (campo == 'proyecto') acabadoProyecto = valor;
    if (campo == 'descripcion') acabadoDescripcion = valor;
    if (campo == 'cantidad') acabadoCantidad = int.tryParse(valor) ?? 0;
    if (campo == 'notas') acabadoNotas = valor;
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

  void updateBarnizGeneral(String campo, dynamic valor) {
    if (campo == 'proyecto') barnizProyecto = valor;
    if (campo == 'pliegos') barnizPliegos = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'nombreMaquila') barnizNombreMaquila = valor;
    if (campo == 'notas') barnizNotas = valor;
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

  void updateEmbalaje(String campo, String valor) {
    if (campo == 'tipo') embalajeTipo = valor;
    if (campo == 'cantidad') embalajeCantidadCajas = int.tryParse(valor) ?? 0;
    if (campo == 'notas') embalajeNotas = valor;
  }

  // --- 11. LOGÍSTICA ---
  String logisticaFechaEntrega = '';
  String logisticaDireccion = '';
  String logisticaTransporte = '';
  int logisticaTotalEntregar = 0;
  String logisticaNotas = '';

  void updateLogistica(String campo, String valor) {
    if (campo == 'fecha') logisticaFechaEntrega = valor;
    if (campo == 'direccion') logisticaDireccion = valor;
    if (campo == 'transporte') logisticaTransporte = valor;
    if (campo == 'total') logisticaTotalEntregar = int.tryParse(valor) ?? 0;
    if (campo == 'notas') logisticaNotas = valor;
    notifyListeners();
  }

  Future<bool> guardarOrdenTrabajo() async {
    if (currentCotizacionId.isEmpty) {
      print("Error: No hay cotización vinculada para guardar esta OT.");
      return false;
    }

    try {
      final datosCompletos = {
        "activeSections": activeSections,
        "adquisiciones": {
          "estatus": tiempos['adquisiciones']?.estatus,
          "inicio": tiempos['adquisiciones']?.inicio,
          "fin": tiempos['adquisiciones']?.fin,
          "notas": adquisicionesNotas,
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
        },
        "corte": {
          "estatus": tiempos['corte']?.estatus,
          "inicio": tiempos['corte']?.inicio,
          "fin": tiempos['corte']?.fin,
          "notas": corteNotas,
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
        },
        "acabado": {
          "estatus": tiempos['acabado']?.estatus,
          "inicio": tiempos['acabado']?.inicio,
          "fin": tiempos['acabado']?.fin,
          "proyecto": acabadoProyecto,
          "descripcionBD": acabadoDescripcion,
          "cantidadBD": acabadoCantidad,
          "notas": acabadoNotas,
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
        },
        "embalaje": {
          "estatus": tiempos['embalaje']?.estatus,
          "inicio": tiempos['embalaje']?.inicio,
          "fin": tiempos['embalaje']?.fin,
          "tipo": embalajeTipo,
          "cantidadCajas": embalajeCantidadCajas,
          "notas": embalajeNotas,
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
