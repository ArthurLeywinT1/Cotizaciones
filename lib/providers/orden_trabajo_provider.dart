// lib/providers/orden_trabajo_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cotizacion_model.dart';
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

// ==========================================
// 2. EL CONTROLADOR (El que maneja la lógica)
// ==========================================
class OrdenTrabajoController extends ChangeNotifier {
  String orderId = "S/F";

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
    'embalaje': true,
    'logistica': true,
  };

  void toggleSection(String section) {
    activeSections[section] = !activeSections[section]!;
    notifyListeners();
  }

  void cargarDatosPorId(String id, WidgetRef ref) {
    final cotizacionesState = ref.read(cotizacionesProvider);

    try {
      final cotizacion = cotizacionesState.cotizaciones.firstWhere(
        (c) => c.id == id,
      );
      cargarDatosDeCotizacion(cotizacion);
    } catch (e) {
      print(
        "⚠️ Error: No se encontró la cotización con ID $id en la base de datos.",
      );
    }
  }

  void cargarDatosDeCotizacion(Cotizacion? cotizacion) {
    if (cotizacion == null) {
      print(
        "⚠️ No se recibió ninguna cotización para cargar en Orden de Trabajo.",
      );
      return;
    }

    print("✅ Cargando datos de la cotización: ${cotizacion.folio ?? 'S/F'}");
    orderId = cotizacion.folio ?? "S/F";

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
        print("   -> Material agregado: $nombre ($cantidad)");
      }
    }

    try {
      if (cotizacion.configDatosPapel != null) {
        final dpInt = cotizacion.configDatosPapel!["interior"];
        if (dpInt != null &&
            dpInt["nombre"] != null &&
            dpInt["nombre"].toString().isNotEmpty) {
          agregarMaterial(
            'Papel Int: ${dpInt["nombre"]} - ${dpInt["peso"] ?? ""}',
            cotizacion.totalPliegos,
          );
        }
        final dpPort = cotizacion.configDatosPapel!["portada"];
        if (dpPort != null &&
            dpPort["nombre"] != null &&
            dpPort["nombre"].toString().isNotEmpty) {
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
        bool seCuentaConSuaje =
            cotizacion.configSuaje!["seCuentaConSuaje"] ?? false;
        if (!seCuentaConSuaje) {
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

        if (totalPliegos == 0) {
          totalPliegos =
              int.tryParse(pInt["totalPliegos"]?.toString() ?? "0") ?? 0;
        }
      }

      offsetPapelNecesario = (cantidadPliegos + pliegosSobrantes).toString();
      offsetPapelLlegara = totalPliegos.toString();

      if (cotizacion.configMaquina != null &&
          cotizacion.configMaquina!["interior"] != null) {
        final mq = cotizacion.configMaquina!["interior"];
        offsetNotas = "Máquina: ${mq['nombreMaquina'] ?? 'No especificada'}";

        int fte = int.tryParse(mq['tintasFte']?.toString() ?? '0') ?? 0;
        int rev = int.tryParse(mq['tintasRev']?.toString() ?? '0') ?? 0;

        offsetData['frente']?['K'] = fte > 0;
        offsetData['frente']?['C'] = fte > 1;
        offsetData['frente']?['M'] = fte > 2;
        offsetData['frente']?['Y'] = fte > 3;

        offsetData['vuelta']?['K'] = rev > 0;
        offsetData['vuelta']?['C'] = rev > 1;
        offsetData['vuelta']?['M'] = rev > 2;
        offsetData['vuelta']?['Y'] = rev > 3;
      }

      laminadoProyecto = cotizacion.descripcion;

      if (cotizacion.configLaminado != null) {
        final lamInt = cotizacion.configLaminado!["interior"];
        if (lamInt != null && lamInt["laminadosActivo"] == true) {
          final detalles = lamInt["detalles"];
          if (detalles != null) {
            detalles.forEach((key, val) {
              if (val["frente"] == true) laminadoAplicacion['frente'] = true;
              if (val["vuelta"] == true) laminadoAplicacion['vuelta'] = true;
              if (val["frente"] == true || val["vuelta"] == true) {
                laminadoNotas += "- $key\n";
              }
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

      List<String> descripcionesBD = [];
      if (cotizacion.configAcabados != null) {
        final acInt = cotizacion.configAcabados!["interior"];
        if (acInt != null && acInt["barnizUV"] == true) {
          descripcionesBD.add("Barniz UV Interior");
        }
        final acPort = cotizacion.configAcabados!["portada"];
        if (acPort != null && acPort["barnizUV"] == true) {
          descripcionesBD.add("Barniz UV Portada");
        }
      }
      acabadoDescripcion = descripcionesBD.join(" + ");

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

      if (cotizacion.configEmbalaje != null &&
          cotizacion.configEmbalaje!["embalajeActivo"] == true) {
        final em = cotizacion.configEmbalaje!["items"] as List?;
        if (em != null && em.isNotEmpty) {
          embalajeTipo = em.map((e) => e["item"].toString()).join(", ");
          int totalCajas = 0;
          for (var item in em) {
            totalCajas +=
                int.tryParse(item["cantidad"]?.toString() ?? "0") ?? 0;
          }
          embalajeCantidadCajas = totalCajas;
        }
      }
    } catch (e) {
      print("⚠️ Error al parsear los datos de la cotización: $e");
    }

    notifyListeners();
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

  void updateLaminadoGeneral(String campo, String valor) {
    if (campo == 'proyecto') laminadoProyecto = valor; // <--- Actualizar
    if (campo == 'notas') laminadoNotas = valor;
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
  }
}

// ==========================================
// 3. EL PROVIDER DE RIVERPOD
// ==========================================
final ordenTrabajoProvider = ChangeNotifierProvider<OrdenTrabajoController>((
  ref,
) {
  return OrdenTrabajoController();
});
