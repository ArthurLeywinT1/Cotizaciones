// lib/providers/orden_trabajo_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. MODELOS DE DATOS (Para estructurar la info)
// ==========================================
class MaterialItem {
  String id;
  String nombre;
  String proveedor;
  int cantidad;
  
  MaterialItem({required this.id, this.nombre = '', this.proveedor = '', this.cantidad = 0});
}

class CutProcess {
  String id;
  String tipo;
  String desc;
  String despuesDe;
  String fecha;
  
  CutProcess({required this.id, this.tipo = '', this.desc = '', this.despuesDe = 'Offset', this.fecha = ''});
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
  String orderId = "OT-2026-001"; // Número de orden simulado

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

  // ==========================================
  // VARIABLES Y MÉTODOS POR DEPARTAMENTO
  // ==========================================

  // --- 1. ADQUISICIONES ---
  List<MaterialItem> materials = [
    MaterialItem(id: '1', nombre: 'Papel Couché 130g', proveedor: 'Proveedor A', cantidad: 5000)
  ];
  String adquisicionesNotas = '';

  void addMaterial() {
    materials.add(MaterialItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
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
  List<DesignTask> designTasks = [
    DesignTask(id: '1', desc: 'Diseñar placas para offset')
  ];
  String disenoNotas = '';

  void addDesignTask() {
    designTasks.add(DesignTask(id: DateTime.now().millisecondsSinceEpoch.toString()));
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
    'frente': {'C': false, 'M': false, 'Y': false, 'K': false, 'especial': false, 'pantone': false, 'tinta_esp': ''},
    'vuelta': {'C': false, 'M': false, 'Y': false, 'K': false, 'especial': false, 'pantone': false, 'tinta_esp': ''},
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
  List<CutProcess> cuts = [
    CutProcess(id: '1', tipo: 'Volantes', desc: 'Refile inicial')
  ];
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

    if (campo == 'romosso') { suajeEsRomosso = valor; if (valor) suajeEsMaquilador = false; }
    if (campo == 'maquilador') { suajeEsMaquilador = valor; if (valor) suajeEsRomosso = false; }
    if (campo == 'existente') { suajeMarcoExistente = valor; if (valor) suajeMarcoNuevo = false; }
    if (campo == 'nuevo') { suajeMarcoNuevo = valor; if (valor) suajeMarcoExistente = false; }

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
    if (campo == 'piezas') serigrafiaPiezas = int.tryParse(valor.toString()) ?? 0;
    if (campo == 'marcos') serigrafiaMarcos = valor;
    if (campo == 'nombreMaquila') serigrafiaNombreMaquila = valor;
    if (campo == 'notas') serigrafiaNotas = valor;

    if (campo == 'marcoExistente') { serigrafiaMarcoExistente = valor; if (valor) serigrafiaMarcoNuevo = false; }
    if (campo == 'marcoNuevo') { serigrafiaMarcoNuevo = valor; if (valor) serigrafiaMarcoExistente = false; }
    if (campo == 'romosso') { serigrafiaEsRomosso = valor; if (valor) serigrafiaEsMaquilador = false; }
    if (campo == 'maquilador') { serigrafiaEsMaquilador = valor; if (valor) serigrafiaEsRomosso = false; }

    notifyListeners();
  }
  void updateSerigrafiaModo(String modo) { serigrafiaModo = modo; notifyListeners(); }
  void updateSerigrafiaPantone(String code) { serigrafiaPantoneCode = code; notifyListeners(); }
  void updateSerigrafiaColor(Color color) { serigrafiaColorDirecto = color; notifyListeners(); }

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
    
    if (campo == 'romosso') { grabadoEsRomosso = valor; if (valor) grabadoEsMaquilador = false; }
    if (campo == 'maquilador') { grabadoEsMaquilador = valor; if (valor) grabadoEsRomosso = false; }

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
    acabadosManuales.add(AcabadoManualItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
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
final ordenTrabajoProvider = ChangeNotifierProvider<OrdenTrabajoController>((ref) {
  return OrdenTrabajoController();
});