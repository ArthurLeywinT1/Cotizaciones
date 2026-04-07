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
  
  MaterialItem({
    required this.id, 
    this.nombre = '', 
    this.proveedor = '', 
    this.cantidad = 0
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
    this.fecha = ''
  });
}

class DesignTask {
  String id;
  String desc;
  
  DesignTask({required this.id, this.desc = ''});
}

// ==========================================
// 2. EL CONTROLADOR (El que maneja la lógica)
// ==========================================
class OrdenTrabajoController extends ChangeNotifier {
  String orderId = "OT-2026-001"; // El número de orden simulado

  // --- Visibilidad de Secciones (Los Checkboxes de arriba) ---
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
    'logistica': true,
  };

  void toggleSection(String section) {
    activeSections[section] = !activeSections[section]!;
    notifyListeners(); // Esto le avisa a la pantalla que se redibuje
  }

  // --- Datos Simuldados: Adquisiciones ---
  List<MaterialItem> materials = [
    MaterialItem(id: '1', nombre: 'Papel Couché 130g', proveedor: 'Proveedor A', cantidad: 5000)
  ];
  
  void addMaterial() {
    materials.add(MaterialItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }
  
  void removeMaterial(String id) {
    materials.removeWhere((m) => m.id == id);
    notifyListeners();
  }
  // --- Datos Simulados: Diseño ---
  List<DesignTask> designTasks = [
    DesignTask(id: '1', desc: 'Diseñar placas para offset')
  ];
  
  void addDesignTask() {
    designTasks.add(DesignTask(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }
  
  void removeDesignTask(String id) {
    designTasks.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  // --- Datos Simulados: Offset ---
  Map<String, dynamic> offsetData = {
    'frente': {'C': false, 'M': false, 'Y': false, 'K': false, 'especial': false, 'pantone': false, 'tinta_esp': ''},
    'vuelta': {'C': false, 'M': false, 'Y': false, 'K': false, 'especial': false, 'pantone': false, 'tinta_esp': ''},
  };
  
  void updateOffsetInk(String cara, String color, dynamic value) {
    offsetData[cara][color] = value;
    notifyListeners();
  }

  // --- Datos Simulados: Corte ---
  List<CutProcess> cuts = [
    CutProcess(id: '1', tipo: 'Volantes', desc: 'Refile inicial')
  ];
  
  void addCut() {
    cuts.add(CutProcess(id: DateTime.now().millisecondsSinceEpoch.toString()));
    notifyListeners();
  }
  
  void removeCut(String id) {
    cuts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // --- Datos Simulados: Serigrafía ---
  String serigrafiaModo = 'ninguno'; // Puede ser 'pantone' o 'directo'
  String serigrafiaPantoneCode = '';
  Color serigrafiaColorDirecto = Colors.black;

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
}

// ==========================================
// 3. EL PROVIDER DE RIVERPOD (El que exportamos)
// ==========================================
// Esto es lo que importas y lees con `ref.watch(ordenTrabajoProvider)` en tus pantallas
final ordenTrabajoProvider = ChangeNotifierProvider<OrdenTrabajoController>((ref) {
  return OrdenTrabajoController();
});