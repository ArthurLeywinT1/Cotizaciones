// cantidad_pliegos.dart
import 'package:flutter/material.dart';
import '../segmentacion.dart';
import 'datospapel_pliegos.dart'; 
import 'costoPapel_pliegos.dart';
import 'maquina_pliegos.dart';
import 'panel_acabados.dart'; 
import 'panel_laminados.dart'; 
import 'panel_grabado.dart';
import 'panel_serigrafia.dart';
import 'panel_acabados_especiales.dart';
import 'panel_suaje.dart';
import 'panel_costo_total_pliegos.dart';

class CantidadPliegos extends StatefulWidget {
  final int numeroDePliegos;
  final int piezasTotales;
  final List<Map<String, dynamic>>? datosIniciales;

  const CantidadPliegos({
    super.key,
    required this.numeroDePliegos,
    required this.piezasTotales,
    this.datosIniciales,
  });

  @override
  State<CantidadPliegos> createState() => CantidadPliegosState();
}

class CantidadPliegosState extends State<CantidadPliegos> {
  // --- CONTROLADORES GLOBALES DE COSTO ---
  final TextEditingController _costoGlobalProduccionCtrl = TextEditingController(text: '0.00');
  final TextEditingController _margenCtrl = TextEditingController(text: '0');
  final TextEditingController _descuentoGlobalCtrl = TextEditingController(text: '0');
  final TextEditingController _diasEntregaCtrl = TextEditingController(text: '0');
  final TextEditingController _precioUtilidadCtrl = TextEditingController(text: '0.00');
  final TextEditingController _precioDescuentoCtrl = TextEditingController(text: '0.00');
  final TextEditingController _precioUnitarioCtrl = TextEditingController(text: '0.00');
  final TextEditingController _ivaGlobalCtrl = TextEditingController(text: '0.00');
  final TextEditingController _precioConIvaCtrl = TextEditingController(text: '0.00');
  List<Map<String, dynamic>> datosPliegos = [];

  Map<String, dynamic> obtenerResumenParaGuardar() {
    _recalcularCostoTotal();

    final pliegos = prepararDatosParaBackend();

    return {
      'pliegos': pliegos,
      'costo_total_produccion': double.tryParse(_costoGlobalProduccionCtrl.text) ?? 0.0,
      'margen': double.tryParse(_margenCtrl.text) ?? 0.0,
      'descuento': double.tryParse(_descuentoGlobalCtrl.text) ?? 0.0,
      'dias_entrega': int.tryParse(_diasEntregaCtrl.text) ?? 0,
      'precio_utilidad': double.tryParse(_precioUtilidadCtrl.text) ?? 0.0,
      'precio_descuento': double.tryParse(_precioDescuentoCtrl.text) ?? 0.0,
      'precio_unitario': double.tryParse(_precioUnitarioCtrl.text) ?? 0.0,
      'iva': double.tryParse(_ivaGlobalCtrl.text) ?? 0.0,
      'precio_con_iva': double.tryParse(_precioConIvaCtrl.text) ?? 0.0,
    };
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  @override
  void initState() {
    super.initState();
    _inicializarDatos(); 
  }

  @override
  void didUpdateWidget(CantidadPliegos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numeroDePliegos != widget.numeroDePliegos || oldWidget.piezasTotales != widget.piezasTotales) {
      _limpiarControladores(); 
      _inicializarDatos();    
    }
  }

  void _limpiarControladores() {
    for (var pliego in datosPliegos) {
      pliego['anchoTrabajoCtrl']?.dispose();
      pliego['altoTrabajoCtrl']?.dispose();
      pliego['medianilCtrl']?.dispose();
      
      pliego['anchoPliegoCtrl']?.dispose();
      pliego['altoPliegoCtrl']?.dispose();
      pliego['orientacionCtrl']?.dispose();
      pliego['piezasController']?.dispose(); 
      
      pliego['cantidadOcuparCtrl']?.dispose();     
      pliego['cantidadTotalPliegoCtrl']?.dispose(); 
      pliego['pliegosExtraCtrl']?.dispose();
      pliego['cantidadPliegosCtrl']?.dispose();
      pliego['pliegosSobrantesCtrl']?.dispose();
      pliego['totalPliegosUtilizarCtrl']?.dispose();
      pliego['millaresImprimirCtrl']?.dispose();

      // Nuevos controladores para la funcionalidad de Revista/Interiores
      pliego['paginasInternasPiezaCtrl']?.dispose();
      pliego['paginasInternasTotalesCtrl']?.dispose();
      pliego['pliegosPorPiezaCtrl']?.dispose();

      pliego['nombrePapelCtrl']?.dispose();
      pliego['tipoPapelCtrl']?.dispose();
      pliego['anchoPapelCtrl']?.dispose();
      pliego['largoPapelCtrl']?.dispose();
      pliego['pesoPapelCtrl']?.dispose();
      pliego['proveedorPapelCtrl']?.dispose();
      pliego['costoMillarCtrl']?.dispose();
      pliego['totalPliegosCtrl']?.dispose();

      pliego['descuentoPapelCtrl']?.dispose();
      pliego['costoTotalPapelSinIvaCtrl']?.dispose();
      pliego['costoTotalPapelConIvaCtrl']?.dispose();

      pliego['nombreMaquinaCtrl']?.dispose();
      pliego['costoPlacaCtrl']?.dispose();
      pliego['tintasFteCtrl']?.dispose();
      pliego['tintasRevCtrl']?.dispose();
      pliego['costoUnitFteCtrl']?.dispose();
      pliego['costoTotalFteCtrl']?.dispose();
      pliego['costoUnitRevCtrl']?.dispose();
      pliego['costoTotalRevCtrl']?.dispose();
      pliego['costoGranTotalTintasCtrl']?.dispose();
      pliego['cantidadPlacasCtrl']?.dispose();
      pliego['costoBarnizCtrl']?.dispose();
      pliego['costoTotalPlacasCtrl']?.dispose();
      pliego['cantidadPlacas790Ctrl']?.dispose();
      pliego['costoPlaca790Ctrl']?.dispose();
      pliego['costoTotalPlacas790Ctrl']?.dispose();
      pliego['barnizFteCtrl']?.dispose();
      pliego['barnizRevCtrl']?.dispose();
      pliego['costoUnitBarnizFteCtrl']?.dispose();
      pliego['costoUnitBarnizRevCtrl']?.dispose();
      pliego['millaresCtrl']?.dispose();

      if (pliego['pruebasColor'] is Map) {
        (pliego['pruebasColor'] as Map).forEach((_, value) {
          value['cantidadController']?.dispose();
          value['precioController']?.dispose();
          value['totalController']?.dispose();
        });
      }

      pliego['anchoFinalCtrl']?.dispose();
      pliego['altoFinalCtrl']?.dispose();
      
      (pliego['acabadosCostoCm2Ctrl'] as Map<String, TextEditingController>?)?.values.forEach((c) => c.dispose());
      (pliego['acabadosCostoTotalCtrl'] as Map<String, TextEditingController>?)?.values.forEach((c) => c.dispose());
      
      (pliego['laminadosCostoCm2Ctrl'] as Map<String, TextEditingController>?)?.values.forEach((c) => c.dispose());
      (pliego['laminadosCostoTotalCtrl'] as Map<String, TextEditingController>?)?.values.forEach((c) => c.dispose());
      (pliego['grabadoCtrl'] as Map<String, TextEditingController>?)?.values.forEach((c) => c.dispose());
      
      final serigrafia = pliego['serigrafiaCtrl'] as Map<String, dynamic>;
      serigrafia['cantidadMarcos']?.dispose();
      serigrafia['totalMarcos']?.dispose();
      (serigrafia['anchoMarcos'] as List<TextEditingController>).forEach((c) => c.dispose());
      (serigrafia['altoMarcos'] as List<TextEditingController>).forEach((c) => c.dispose());
      (serigrafia['precioMarcos'] as List<TextEditingController>).forEach((c) => c.dispose());

      final ae = pliego['acabadosEspecialesCtrl'] as Map<String, dynamic>;
      (ae['descripcion'] as List<TextEditingController>).forEach((c) => c.dispose());
      (ae['costoMillar'] as List<TextEditingController>).forEach((c) => c.dispose());
      (ae['costoTotal'] as List<TextEditingController>).forEach((c) => c.dispose());

      final suaje = pliego['suajeCtrl'] as Map<String, dynamic>;
      suaje['tamanoSuaje']?.dispose();
      suaje['costoSuajeCm']?.dispose();
      suaje['costoTotalSuaje']?.dispose();
      suaje['costoArreglo']?.dispose();
      suaje['costoTotalSuajado']?.dispose();
      suaje['ancho']?.dispose();
      suaje['largo']?.dispose();
      suaje['pliegos']?.dispose();
      suaje['costoMillar']?.dispose();
    }
  }

  @override
  void dispose() {
    _limpiarControladores(); 
    super.dispose();
  }

  void _inicializarDatos() {
    if (widget.datosIniciales != null && widget.datosIniciales!.isNotEmpty) {
      datosPliegos = widget.datosIniciales!.map((pliegoGuardado) {
        return _reconstruirPliegoDesdeJSON(pliegoGuardado);
      }).toList();
    } else {
      datosPliegos = List.generate(widget.numeroDePliegos, (index) {
        return {
          'titulo': 'Pliego ${index + 1}',
          'anchoTrabajoCtrl': TextEditingController(),
          'altoTrabajoCtrl': TextEditingController(),
          'medianilCtrl': TextEditingController(text: '0.50'),
          
          'anchoPliegoCtrl': TextEditingController(),
          'altoPliegoCtrl': TextEditingController(),
          'orientacionCtrl': TextEditingController(),
          'piezasController': TextEditingController(), 
          
          'cantidadOcuparCtrl': TextEditingController(text: '1'), 
          'cantidadTotalPliegoCtrl': TextEditingController(text: '0.00'),
          'pliegosExtraCtrl': TextEditingController(text: '150'),
          'cantidadPliegosCtrl': TextEditingController(text: '0'),
          'pliegosSobrantesCtrl': TextEditingController(text: '0'),
          'totalPliegosUtilizarCtrl': TextEditingController(text: '0'),
          'millaresImprimirCtrl': TextEditingController(text: '0.00'),

          'isPortada': false,
          'isInteriores': false,
          'multiploImpresion': 2,
          'paginasInternasPiezaCtrl': TextEditingController(text: '0'),
          'paginasInternasTotalesCtrl': TextEditingController(text: '0'),
          'pliegosPorPiezaCtrl': TextEditingController(text: '0.00'),

          'nombrePapelCtrl': TextEditingController(),
          'tipoPapelCtrl': TextEditingController(),
          'anchoPapelCtrl': TextEditingController(),
          'largoPapelCtrl': TextEditingController(),
          'pesoPapelCtrl': TextEditingController(),
          'proveedorPapelCtrl': TextEditingController(),
          'costoMillarCtrl': TextEditingController(),
          'totalPliegosCtrl': TextEditingController(),

          'descuentoPapelCtrl': TextEditingController(text: '0'),
          'costoTotalPapelSinIvaCtrl': TextEditingController(text: '0.00'),
          'costoTotalPapelConIvaCtrl': TextEditingController(text: '0.00'),
          
          'nombreMaquinaCtrl': TextEditingController(),
          'costoPlacaCtrl': TextEditingController(text: '0.00'),
          'tintasFteCtrl': TextEditingController(text: '0'),
          'tintasRevCtrl': TextEditingController(text: '0'),
          'costoUnitFteCtrl': TextEditingController(text: '0.00'),
          'costoTotalFteCtrl': TextEditingController(text: '0.00'),
          'costoUnitRevCtrl': TextEditingController(text: '0.00'),
          'costoTotalRevCtrl': TextEditingController(text: '0.00'),
          'costoGranTotalTintasCtrl': TextEditingController(text: '0.00'),
          'cantidadPlacasCtrl': TextEditingController(text: '0'),
          'costoBarnizCtrl': TextEditingController(text: '0.00'),
          'costoTotalPlacasCtrl': TextEditingController(text: '0.00'),
          'cantidadPlacas790Ctrl': TextEditingController(text: '0'),
          'costoPlaca790Ctrl': TextEditingController(text: '0.00'),
          'costoTotalPlacas790Ctrl': TextEditingController(text: '0.00'),
          'barnizFteCtrl': TextEditingController(text: '0.00'),
          'barnizRevCtrl': TextEditingController(text: '0.00'),
          'costoUnitBarnizFteCtrl': TextEditingController(text: '0.00'),
          'costoUnitBarnizRevCtrl': TextEditingController(text: '0.00'),
          'millaresCtrl': TextEditingController(text: '1'),

          'barnizMaquina': false,
          'cambiarPrecioPlaca': false,
          'cambiarPrecioTinta': false,
          'cambiarPrecioBarniz': false,
          'barnizFte': false,
          'barnizRev': false,
          'opcionesFrente': <String>[],
          'opcionesVuelta': <String>[],
          'configuracionFrente': null,
          'configuracionVuelta': null,

          'procesos': {
            'Offset': false,
            'Barniz UV': false,
            'Acabados Especiales': false,
            'Suaje': false,
            'Plastificado/Laminado': false,
            'Serigrafia': false,
            'Grabado': false,
          },
          
          'pruebasColor': {
            'Prueba de color carta': {
              'activo': false,
              'cantidadController': TextEditingController(),
              'precioController': TextEditingController(),
              'totalController': TextEditingController(text: '0.00'),
            },
            'Tabloide': {
              'activo': false,
              'cantidadController': TextEditingController(),
              'precioController': TextEditingController(),
              'totalController': TextEditingController(text: '0.00'),
            },
            'Media carta': {
              'activo': false,
              'cantidadController': TextEditingController(),
              'precioController': TextEditingController(),
              'totalController': TextEditingController(text: '0.00'),
            },
          },

          'anchoFinalCtrl': TextEditingController(text: '0.00'),
          'altoFinalCtrl': TextEditingController(text: '0.00'),
          'acabadosData': {
            'Barniz UV a Registro': {'frente': false, 'vuelta': false},
            'Barniz UV Brillante a Plasta': {'frente': false, 'vuelta': false},
            'Barniz UV Mate Plasta': {'frente': false, 'vuelta': false},
          },
          'acabadosCostoCm2Ctrl': {
            'Barniz UV a Registro': TextEditingController(),
            'Barniz UV Brillante a Plasta': TextEditingController(),
            'Barniz UV Mate Plasta': TextEditingController(),
          },
          'acabadosCostoTotalCtrl': {
            'Barniz UV a Registro': TextEditingController(text: '0.00'),
            'Barniz UV Brillante a Plasta': TextEditingController(text: '0.00'),
            'Barniz UV Mate Plasta': TextEditingController(text: '0.00'),
          },

          'laminadosData': {
            'Plastificado Brillante': {'frente': false, 'vuelta': false},
            'Plastificado Mate': {'frente': false, 'vuelta': false},
          },
          'laminadosCostoCm2Ctrl': {
            'Plastificado Brillante': TextEditingController(),
            'Plastificado Mate': TextEditingController(),
          },
          'laminadosCostoTotalCtrl': {
            'Plastificado Brillante': TextEditingController(text: '0.00'),
            'Plastificado Mate': TextEditingController(text: '0.00'),
          },
          'grabadoCtrl': {
            'cantidadPlacas': TextEditingController(text: '0'),
            'costoPlaca': TextEditingController(text: '0.00'),
            'costoTotalPlacas': TextEditingController(text: '0.00'),
            'costoEntrada': TextEditingController(text: '0.00'),
            'costoTotalEntrada': TextEditingController(text: '0.00'),
            'costoTotalGrabado': TextEditingController(text: '0.00'),
          },
          'serigrafiaCtrl': {
            'cantidadMarcos': TextEditingController(text: '0'),
            'totalMarcos': TextEditingController(text: '0.00'),
            'anchoMarcos': <TextEditingController>[],
            'altoMarcos': <TextEditingController>[],
            'precioMarcos': <TextEditingController>[],
            'cantidadNegativos': TextEditingController(text: '0'),
            'precioNegativo': TextEditingController(text: '0.00'),
            'totalNegativos': TextEditingController(text: '0.00'),
            'cantidadTintas': TextEditingController(text: '0'),
            'costoTintas': TextEditingController(text: '0.00'),
            'totalTintas': TextEditingController(text: '0.00'),
            'numeroEntradas': TextEditingController(text: '0'),
            'costoMillar': TextEditingController(text: '0.00'),
            'totalEntrada': TextEditingController(text: '0.00'),
          },
          'acabadosEspecialesCtrl': {
            'activos': List.generate(5, (_) => false),
            'descripcion': List.generate(5, (_) => TextEditingController()),
            'costoMillar': List.generate(5, (_) => TextEditingController()),
            'costoTotal': List.generate(5, (_) => TextEditingController(text: '0.00')),
          },
          'suajeCtrl': {
            'tamanoSuaje': TextEditingController(text: '0.00'),
            'costoSuajeCm': TextEditingController(text: '0.00'),
            'costoTotalSuaje': TextEditingController(text: '0.00'),
            'costoArreglo': TextEditingController(text: '0.00'),
            'costoTotalSuajado': TextEditingController(text: '0.00'),
            'ancho': TextEditingController(text: '0.00'),
            'largo': TextEditingController(text: '0.00'),
            'seCuentaConSuaje': false,
            'pliegos': TextEditingController(text: '0'),
            'costoMillar': TextEditingController(text: '0.00'),
          },
        };
      });
    }
  }

  Map<String, dynamic> _reconstruirPliegoDesdeJSON(Map<String, dynamic> pliegoGuardado) {
    final medidasTrabajo = _asMap(pliegoGuardado['medidas_trabajo']);
    final calculosImpresion = _asMap(pliegoGuardado['calculos_impresion']);
    final interioresConfig = _asMap(pliegoGuardado['interiores_config']);
    final offsetData = _asMap(pliegoGuardado['offset_data']);
    final papelData = _asMap(offsetData['papel_datos']);
    final maquinaData = _asMap(offsetData['maquina_datos']);
    final pruebasColorData = _asMap(offsetData['pruebas_color']);
    final barnizUVData = _asMap(pliegoGuardado['barniz_uv_data']);
    final laminadoData = _asMap(pliegoGuardado['laminado_data']);
    final grabadoData = _asMap(pliegoGuardado['grabado_data']);
    final serigrafiaData = _asMap(pliegoGuardado['serigrafia_data']);
    final acabadosEspecialesData = _asMap(pliegoGuardado['acabados_especiales_data']);
    final suajeData = _asMap(pliegoGuardado['suaje_data']);

    final pliego = {
      'titulo': pliegoGuardado['titulo'] ?? 'Pliego',
      'isPortada': pliegoGuardado['is_portada'] ?? false,
      'isInteriores': pliegoGuardado['is_interiores'] ?? false,
      'multiploImpresion': pliegoGuardado['multiplo_impresion'] ?? 2,

      'anchoTrabajoCtrl': TextEditingController(
        text: (medidasTrabajo['ancho_trabajo']?.toString() ?? '0'),
      ),
      'altoTrabajoCtrl': TextEditingController(
        text: (medidasTrabajo['alto_trabajo']?.toString() ?? '0'),
      ),
      'medianilCtrl': TextEditingController(
        text: (medidasTrabajo['medianil']?.toString() ?? '0.50'),
      ),
      'anchoFinalCtrl': TextEditingController(
        text: (medidasTrabajo['ancho_final']?.toString() ?? '0.00'),
      ),
      'altoFinalCtrl': TextEditingController(
        text: (medidasTrabajo['alto_final']?.toString() ?? '0.00'),
      ),
      'anchoPliegoCtrl': TextEditingController(
        text: (medidasTrabajo['ancho_pliego']?.toString() ?? '0'),
      ),
      'altoPliegoCtrl': TextEditingController(
        text: (medidasTrabajo['alto_pliego']?.toString() ?? '0'),
      ),
      'orientacionCtrl': TextEditingController(
        text: (medidasTrabajo['orientacion']?.toString() ?? ''),
      ),

      'cantidadOcuparCtrl': TextEditingController(
        text: (calculosImpresion['cantidad_ocupar_este_pliego']?.toString() ?? '1'),
      ),
      'cantidadTotalPliegoCtrl': TextEditingController(
        text: (calculosImpresion['cantidad_total_pliego']?.toString() ?? '0.00'),
      ),
      'pliegosExtraCtrl': TextEditingController(
        text: (calculosImpresion['pliegos_extra_merma']?.toString() ?? '150'),
      ),
      'cantidadPliegosCtrl': TextEditingController(
        text: (calculosImpresion['cantidad_pliegos_imprimir']?.toString() ?? '0'),
      ),
      'pliegosSobrantesCtrl': TextEditingController(
        text: (calculosImpresion['piezas_sobrantes']?.toString() ?? '0'),
      ),
      'totalPliegosUtilizarCtrl': TextEditingController(
        text: (calculosImpresion['total_pliegos_utilizar']?.toString() ?? '0'),
      ),
      'millaresImprimirCtrl': TextEditingController(
        text: (calculosImpresion['millares_imprimir']?.toString() ?? '0.00'),
      ),

      'piezasController': TextEditingController(
        text: (pliegoGuardado['piezas_por_pliego']?.toString() ?? '0'),
      ),

      'paginasInternasPiezaCtrl': TextEditingController(
        text: (interioresConfig['paginas_internas_pieza']?.toString() ?? '0'),
      ),
      'paginasInternasTotalesCtrl': TextEditingController(
        text: (interioresConfig['paginas_internas_totales']?.toString() ?? '0'),
      ),
      'pliegosPorPiezaCtrl': TextEditingController(
        text: (interioresConfig['pliegos_por_pieza']?.toString() ?? '0.00'),
      ),

      'nombrePapelCtrl': TextEditingController(
        text: (papelData['nombre']?.toString() ?? ''),
      ),
      'tipoPapelCtrl': TextEditingController(
        text: (papelData['tipo']?.toString() ?? ''),
      ),
      'anchoPapelCtrl': TextEditingController(
        text: (papelData['ancho']?.toString() ?? '0'),
      ),
      'largoPapelCtrl': TextEditingController(
        text: (papelData['largo']?.toString() ?? '0'),
      ),
      'pesoPapelCtrl': TextEditingController(
        text: (papelData['peso']?.toString() ?? ''),
      ),
      'proveedorPapelCtrl': TextEditingController(
        text: (papelData['proveedor']?.toString() ?? ''),
      ),
      'costoMillarCtrl': TextEditingController(
        text: (papelData['costo_millar']?.toString() ?? '0'),
      ),
      'totalPliegosCtrl': TextEditingController(
        text: (papelData['total_pliegos_asignados']?.toString() ?? '0'),
      ),
      'descuentoPapelCtrl': TextEditingController(
        text: (papelData['descuento_aplicado']?.toString() ?? '0'),
      ),
      'costoTotalPapelSinIvaCtrl': TextEditingController(
        text: (papelData['costo_total_sin_iva']?.toString() ?? '0.00'),
      ),
      'costoTotalPapelConIvaCtrl': TextEditingController(
        text: (papelData['costo_total_con_iva']?.toString() ?? '0.00'),
      ),

      'nombreMaquinaCtrl': TextEditingController(
        text: (maquinaData['nombre_maquina']?.toString() ?? ''),
      ),
      'tintasFteCtrl': TextEditingController(
        text: (maquinaData['tintas_frente']?.toString() ?? '0'),
      ),
      'tintasRevCtrl': TextEditingController(
        text: (maquinaData['tintas_reverso']?.toString() ?? '0'),
      ),
      'costoGranTotalTintasCtrl': TextEditingController(
        text: (maquinaData['costo_total_tintas']?.toString() ?? '0.00'),
      ),
      'costoTotalPlacasCtrl': TextEditingController(
        text: (maquinaData['costo_total_placas']?.toString() ?? '0.00'),
      ),
      'costoTotalPlacas790Ctrl': TextEditingController(
        text: (maquinaData['costo_total_placas_790']?.toString() ?? '0.00'),
      ),
      'costoBarnizCtrl': TextEditingController(
        text: (maquinaData['costo_barniz']?.toString() ?? '0.00'),
      ),
      'costoPlacaCtrl': TextEditingController(
        text: (maquinaData['costo_placa']?.toString() ?? '0.00'),
      ),
      'costoPlaca790Ctrl': TextEditingController(
        text: (maquinaData['costo_placa_790']?.toString() ?? '0.00'),
      ),
      'cantidadPlacasCtrl': TextEditingController(
        text: (maquinaData['cantidad_placas']?.toString() ?? '0'),
      ),
      'cantidadPlacas790Ctrl': TextEditingController(
        text: (maquinaData['cantidad_placas_790']?.toString() ?? '0'),
      ),
      'costoUnitFteCtrl': TextEditingController(
        text: (maquinaData['costo_unit_frente']?.toString() ?? '0.00'),
      ),
      'costoTotalFteCtrl': TextEditingController(
        text: (maquinaData['costo_total_frente']?.toString() ?? '0.00'),
      ),
      'costoUnitRevCtrl': TextEditingController(
        text: (maquinaData['costo_unit_reverso']?.toString() ?? '0.00'),
      ),
      'costoTotalRevCtrl': TextEditingController(
        text: (maquinaData['costo_total_reverso']?.toString() ?? '0.00'),
      ),
      'barnizFteCtrl': TextEditingController(
        text: (maquinaData['barniz_frente'] == true ? '1' : ''),
      ),
      'barnizRevCtrl': TextEditingController(
        text: (maquinaData['barniz_reverso'] == true ? '1' : ''),
      ),
      'costoUnitBarnizFteCtrl': TextEditingController(
        text: (maquinaData['costo_unit_barniz_frente']?.toString() ?? '0.00'),
      ),
      'costoUnitBarnizRevCtrl': TextEditingController(
        text: (maquinaData['costo_unit_barniz_reverso']?.toString() ?? '0.00'),
      ),
      'millaresCtrl': TextEditingController(
        text: (maquinaData['millares']?.toString() ?? '1'),
      ),
      'barnizFte': maquinaData['barniz_frente'] ?? false,
      'barnizRev': maquinaData['barniz_reverso'] ?? false,

      'configuracionFrente': maquinaData['configuracion_frente'],
      'configuracionVuelta': maquinaData['configuracion_vuelta'],
      'opcionesFrente': <String>[],
      'opcionesVuelta': <String>[],

      'procesos': _mapaProcesosSeguro(pliegoGuardado['procesos']),
      'pruebasColor': _mapaPruebasColorSeguro(pruebasColorData),

      'acabadosData': () {
        final seleccion = barnizUVData['seleccion'] as Map?;
        return {
          'Barniz UV a Registro': {
            'frente': (seleccion?['Barniz UV a Registro'] as Map?)?['frente'] == true,
            'vuelta': (seleccion?['Barniz UV a Registro'] as Map?)?['vuelta'] == true,
          },
          'Barniz UV Brillante a Plasta': {
            'frente': (seleccion?['Barniz UV Brillante a Plasta'] as Map?)?['frente'] == true,
            'vuelta': (seleccion?['Barniz UV Brillante a Plasta'] as Map?)?['vuelta'] == true,
          },
          'Barniz UV Mate Plasta': {
            'frente': (seleccion?['Barniz UV Mate Plasta'] as Map?)?['frente'] == true,
            'vuelta': (seleccion?['Barniz UV Mate Plasta'] as Map?)?['vuelta'] == true,
          },
        };
      }(),
      'acabadosCostoCm2Ctrl': () {
        final costos = barnizUVData['costos_cm2'] as Map? ?? {};
        return {
          'Barniz UV a Registro': TextEditingController(
            text: (costos['Barniz UV a Registro']?.toString() ?? '0'),
          ),
          'Barniz UV Brillante a Plasta': TextEditingController(
            text: (costos['Barniz UV Brillante a Plasta']?.toString() ?? '0'),
          ),
          'Barniz UV Mate Plasta': TextEditingController(
            text: (costos['Barniz UV Mate Plasta']?.toString() ?? '0'),
          ),
        };
      }(),
      'acabadosCostoTotalCtrl': () {
        final costos = barnizUVData['costos_totales'] as Map? ?? {};
        return {
          'Barniz UV a Registro': TextEditingController(
            text: (costos['Barniz UV a Registro']?.toString() ?? '0.00'),
          ),
          'Barniz UV Brillante a Plasta': TextEditingController(
            text: (costos['Barniz UV Brillante a Plasta']?.toString() ?? '0.00'),
          ),
          'Barniz UV Mate Plasta': TextEditingController(
            text: (costos['Barniz UV Mate Plasta']?.toString() ?? '0.00'),
          ),
        };
      }(),

      'laminadosData': () {
        final seleccion = laminadoData['seleccion'] as Map?;
        return {
          'Plastificado Brillante': {
            'frente': (seleccion?['Plastificado Brillante'] as Map?)?['frente'] == true,
            'vuelta': (seleccion?['Plastificado Brillante'] as Map?)?['vuelta'] == true,
          },
          'Plastificado Mate': {
            'frente': (seleccion?['Plastificado Mate'] as Map?)?['frente'] == true,
            'vuelta': (seleccion?['Plastificado Mate'] as Map?)?['vuelta'] == true,
          },
        };
      }(),
      'laminadosCostoCm2Ctrl': () {
        final costos = laminadoData['costos_cm2'] as Map? ?? {};
        return {
          'Plastificado Brillante': TextEditingController(
            text: (costos['Plastificado Brillante']?.toString() ?? '0'),
          ),
          'Plastificado Mate': TextEditingController(
            text: (costos['Plastificado Mate']?.toString() ?? '0'),
          ),
        };
      }(),
      'laminadosCostoTotalCtrl': () {
        final costos = laminadoData['costos_totales'] as Map? ?? {};
        return {
          'Plastificado Brillante': TextEditingController(
            text: (costos['Plastificado Brillante']?.toString() ?? '0.00'),
          ),
          'Plastificado Mate': TextEditingController(
            text: (costos['Plastificado Mate']?.toString() ?? '0.00'),
          ),
        };
      }(),

      'grabadoCtrl': {
        'cantidadPlacas': TextEditingController(
          text: (grabadoData['cantidad_placas']?.toString() ?? '0'),
        ),
        'costoPlaca': TextEditingController(
          text: (grabadoData['costo_placa']?.toString() ?? '0.00'),
        ),
        'costoTotalPlacas': TextEditingController(
          text: (grabadoData['costo_total_placas']?.toString() ?? '0.00'),
        ),
        'costoEntrada': TextEditingController(
          text: (grabadoData['costo_entrada']?.toString() ?? '0.00'),
        ),
        'costoTotalEntrada': TextEditingController(
          text: (grabadoData['costo_total_entrada']?.toString() ?? '0.00'),
        ),
        'costoTotalGrabado': TextEditingController(
          text: (grabadoData['costo_total_grabado']?.toString() ?? '0.00'),
        ),
      },

      'serigrafiaCtrl': {
        'cantidadMarcos': TextEditingController(
          text: (serigrafiaData['cantidad_marcos']?.toString() ?? '0'),
        ),
        'totalMarcos': TextEditingController(
          text: (serigrafiaData['total_marcos']?.toString() ?? '0.00'),
        ),
        'cantidadNegativos': TextEditingController(
          text: (serigrafiaData['cantidad_negativos']?.toString() ?? '0'),
        ),
        'precioNegativo': TextEditingController(
          text: (serigrafiaData['precio_negativo']?.toString() ?? '0.00'),
        ),
        'totalNegativos': TextEditingController(
          text: (serigrafiaData['total_negativos']?.toString() ?? '0.00'),
        ),
        'cantidadTintas': TextEditingController(
          text: (serigrafiaData['cantidad_tintas']?.toString() ?? '0'),
        ),
        'costoTintas': TextEditingController(
          text: (serigrafiaData['costo_tintas']?.toString() ?? '0.00'),
        ),
        'totalTintas': TextEditingController(
          text: (serigrafiaData['total_tintas']?.toString() ?? '0.00'),
        ),
        'numeroEntradas': TextEditingController(
          text: (serigrafiaData['numero_entradas']?.toString() ?? '0'),
        ),
        'costoMillar': TextEditingController(
          text: (serigrafiaData['costo_millar']?.toString() ?? '0.00'),
        ),
        'totalEntrada': TextEditingController(
          text: (serigrafiaData['total_entrada']?.toString() ?? '0.00'),
        ),
        'anchoMarcos': (serigrafiaData['ancho_marcos'] as List?)
                ?.map((v) => TextEditingController(text: v.toString()))
                .toList() ??
            <TextEditingController>[],
        'altoMarcos': (serigrafiaData['alto_marcos'] as List?)
                ?.map((v) => TextEditingController(text: v.toString()))
                .toList() ??
            <TextEditingController>[],
        'precioMarcos': (serigrafiaData['precio_marcos'] as List?)
                ?.map((v) => TextEditingController(text: v.toString()))
                .toList() ??
            <TextEditingController>[],
      },

      'acabadosEspecialesCtrl': () {
        final items = (acabadosEspecialesData['items'] as List?) ?? [];
        final activos = List.generate(5, (i) => i < items.length && (items[i]['activo'] == true));
        final descripcion = List.generate(
          5,
          (i) => TextEditingController(
            text: i < items.length ? (items[i]['descripcion']?.toString() ?? '') : '',
          ),
        );
        final costoMillar = List.generate(
          5,
          (i) => TextEditingController(
            text: i < items.length ? (items[i]['costo_millar']?.toString() ?? '0') : '0',
          ),
        );
        final costoTotal = List.generate(
          5,
          (i) => TextEditingController(
            text: i < items.length ? (items[i]['costo_total']?.toString() ?? '0.00') : '0.00',
          ),
        );
        return {
          'activos': activos,
          'descripcion': descripcion,
          'costoMillar': costoMillar,
          'costoTotal': costoTotal,
        };
      }(),

      // Suaje
      'suajeCtrl': {
        'tamanoSuaje': TextEditingController(
          text: (suajeData['tamano_suaje']?.toString() ?? '0.00'),
        ),
        'costoSuajeCm': TextEditingController(
          text: (suajeData['costo_suaje_cm']?.toString() ?? '0.00'),
        ),
        'costoTotalSuaje': TextEditingController(
          text: (suajeData['costo_total_suaje']?.toString() ?? '0.00'),
        ),
        'costoArreglo': TextEditingController(
          text: (suajeData['costo_arreglo']?.toString() ?? '0.00'),
        ),
        'costoTotalSuajado': TextEditingController(
          text: (suajeData['costo_total_suajado']?.toString() ?? '0.00'),
        ),
        'ancho': TextEditingController(
          text: (suajeData['ancho']?.toString() ?? '0.00'),
        ),
        'largo': TextEditingController(
          text: (suajeData['largo']?.toString() ?? '0.00'),
        ),
        'seCuentaConSuaje': suajeData['se_cuenta_con_suaje'] ?? false,
        'pliegos': TextEditingController(
          text: (suajeData['pliegos']?.toString() ?? '0'),
        ),
        'costoMillar': TextEditingController(
          text: (suajeData['costo_millar']?.toString() ?? '0.00'),
        ),
      },

      'cambiarPrecioPlaca': false,
      'cambiarPrecioTinta': false,
      'cambiarPrecioBarniz': false,
      'barnizMaquina': false,
    };

    return pliego;
  }

  Map<String, bool> _mapaProcesosSeguro(dynamic value) {
    if (value == null) return {
      'Offset': false,
      'Barniz UV': false,
      'Acabados Especiales': false,
      'Suaje': false,
      'Plastificado/Laminado': false,
      'Serigrafia': false,
      'Grabado': false,
    };

    final map = value is Map ? value : <dynamic, dynamic>{};
    return {
      'Offset': map['Offset'] as bool? ?? false,
      'Barniz UV': map['Barniz UV'] as bool? ?? false,
      'Acabados Especiales': map['Acabados Especiales'] as bool? ?? false,
      'Suaje': map['Suaje'] as bool? ?? false,
      'Plastificado/Laminado': map['Plastificado/Laminado'] as bool? ?? false,
      'Serigrafia': map['Serigrafia'] as bool? ?? false,
      'Grabado': map['Grabado'] as bool? ?? false,
    };
  }

  Map<String, dynamic> _mapaPruebasColorSeguro(dynamic value) {
    final map = value is Map ? value : <dynamic, dynamic>{};

    Map<String, dynamic> buildItem(dynamic item) {
      final m = item is Map ? item : <dynamic, dynamic>{};
      return {
        'activo': m['activo'] as bool? ?? false,
        'cantidadController': TextEditingController(text: m['cantidad']?.toString() ?? ''),
        'precioController': TextEditingController(text: m['precio']?.toString() ?? ''),
        'totalController': TextEditingController(text: m['total']?.toString() ?? '0.00'),
      };
    }

    return {
      'Prueba de color carta': buildItem(map['Prueba de color carta']),
      'Tabloide': buildItem(map['Tabloide']),
      'Media carta': buildItem(map['Media carta']),
    };
  }


  void _ejecutarCalculosProduccion(Map<String, dynamic> pliego) {
    int piezasTotalesSolicitadas = widget.piezasTotales;
    int cantidadOcupar = int.tryParse(pliego['cantidadOcuparCtrl'].text) ?? 0;
    int piezasPorPliegoOriginal = int.tryParse(pliego['piezasController'].text) ?? 0;
    int pliegosExtra = int.tryParse(pliego['pliegosExtraCtrl'].text) ?? 0;

    bool isInteriores = pliego['isInteriores'] == true;

    // 1. Manejo dinámico de Piezas/Páginas por pliego (frente y vuelta si es interiores)
    int piezasPorPliego = piezasPorPliegoOriginal;
    if (isInteriores && piezasPorPliegoOriginal > 0) {
      piezasPorPliego = piezasPorPliegoOriginal * 2; 
    }

    // 2. Cálculos específicos de Interiores (Revistas)
    double pliegosPorPieza = 0.0;
    double pliegosPorPiezaRedondeado = 0.0;

    if (isInteriores) {
      int paginasInternasPieza = int.tryParse(pliego['paginasInternasPiezaCtrl'].text) ?? 0;
      int paginasTotales = paginasInternasPieza * piezasTotalesSolicitadas;
      pliego['paginasInternasTotalesCtrl'].text = paginasTotales.toString();

      if (piezasPorPliego > 0) {
        pliegosPorPieza = paginasInternasPieza / piezasPorPliego;
        pliego['pliegosPorPiezaCtrl'].text = pliegosPorPieza.toStringAsFixed(4);
        pliegosPorPiezaRedondeado = pliegosPorPieza.ceilToDouble();
      }
    }

    // 3. Cálculos estándar e influencia del factor revista
    if (piezasPorPliego > 0 && piezasTotalesSolicitadas > 0 && cantidadOcupar > 0) {
      double cantidadTotalPliego = (cantidadOcupar * piezasTotalesSolicitadas) / piezasPorPliego;
      pliego['cantidadTotalPliegoCtrl'].text = cantidadTotalPliego.toStringAsFixed(2);
      
      int cantidadPliegosBase = cantidadTotalPliego.ceil();
      
      // Aplicar lógica de compensación por decimales si es revista
      if (isInteriores && pliegosPorPieza > 0) {
        double residuoDecimal = pliegosPorPiezaRedondeado - pliegosPorPieza;
        if (residuoDecimal > 0) {
          double pliegosAdicionales = residuoDecimal * piezasTotalesSolicitadas;
          cantidadPliegosBase += pliegosAdicionales.ceil();
        }
      }

      pliego['cantidadPliegosCtrl'].text = cantidadPliegosBase.toString();
      int sobrantes = ((cantidadOcupar * piezasTotalesSolicitadas) % piezasPorPliego == 0) ? 0 : 1;
      pliego['pliegosSobrantesCtrl'].text = sobrantes.toString();
      
      int totalUtilizar = cantidadPliegosBase + pliegosExtra;
      pliego['totalPliegosUtilizarCtrl'].text = totalUtilizar.toString();
      pliego['totalPliegosCtrl'].text = totalUtilizar.toString();

      double millares = totalUtilizar / 1000.0;
      pliego['millaresImprimirCtrl'].text = millares.toStringAsFixed(2);
    } else {
      pliego['cantidadTotalPliegoCtrl'].text = '0.00';
      pliego['cantidadPliegosCtrl'].text = '0';
      pliego['pliegosSobrantesCtrl'].text = '0';
      pliego['totalPliegosUtilizarCtrl'].text = '0';
      pliego['totalPliegosCtrl'].text = '0';
      pliego['millaresImprimirCtrl'].text = '0.00';
      if (isInteriores) {
        pliego['paginasInternasTotalesCtrl'].text = '0';
        pliego['pliegosPorPiezaCtrl'].text = '0.00';
      }
    }
  }

  void _calcularTotalPrueba(Map<String, dynamic> pruebaData) {
    double cantidad = double.tryParse(pruebaData['cantidadController'].text) ?? 0.0;
    double precio = double.tryParse(pruebaData['precioController'].text) ?? 0.0;
    double total = cantidad * precio;
    pruebaData['totalController'].text = total.toStringAsFixed(2);
  }

void _recalcularCostoTotal() {
    double granTotalProduccion = 0.0;

    for (var pliego in datosPliegos) {
      granTotalProduccion += double.tryParse(pliego['costoTotalPapelConIvaCtrl']?.text ?? '0') ?? 0.0;
      
      if (pliego['procesos']['Offset'] == true) {
        // --- SE ELIMINA factorMultiplicador ---
        // Sumamos los costos directamente tal como se calcularon para este pliego:
        double costoTintas = double.tryParse(pliego['costoGranTotalTintasCtrl']?.text ?? '0') ?? 0.0;
        double costoPlacas = double.tryParse(pliego['costoTotalPlacasCtrl']?.text ?? '0') ?? 0.0;
        double costoPlacas790 = double.tryParse(pliego['costoTotalPlacas790Ctrl']?.text ?? '0') ?? 0.0;
        double costoBarniz = double.tryParse(pliego['costoBarnizCtrl']?.text ?? '0') ?? 0.0;

        granTotalProduccion += costoTintas;
        granTotalProduccion += costoPlacas;
        granTotalProduccion += costoPlacas790;
        granTotalProduccion += costoBarniz;
        
        var pruebas = pliego['pruebasColor'] as Map<String, dynamic>?;
        if (pruebas != null) {
          pruebas.forEach((_, data) {
            if (data['activo'] == true) {
              granTotalProduccion += double.tryParse(data['totalController']?.text ?? '0') ?? 0.0;
            }
          });
        }
      }


      if (pliego['procesos']['Barniz UV'] == true) {
        var uv = pliego['acabadosCostoTotalCtrl'] as Map<String, TextEditingController>?;
        uv?.values.forEach((ctrl) {
          granTotalProduccion += double.tryParse(ctrl.text) ?? 0.0;
        });
      }

      if (pliego['procesos']['Plastificado/Laminado'] == true) {
        var lam = pliego['laminadosCostoTotalCtrl'] as Map<String, TextEditingController>?;
        lam?.values.forEach((ctrl) {
          granTotalProduccion += double.tryParse(ctrl.text) ?? 0.0;
        });
      }

      if (pliego['procesos']['Grabado'] == true) {
        granTotalProduccion += double.tryParse(pliego['grabadoCtrl']['costoTotalGrabado']?.text ?? '0') ?? 0.0;
      }

      if (pliego['procesos']['Serigrafia'] == true) {
        granTotalProduccion += double.tryParse(pliego['serigrafiaCtrl']['totalMarcos']?.text ?? '0') ?? 0.0;
        granTotalProduccion += double.tryParse(pliego['serigrafiaCtrl']['totalNegativos']?.text ?? '0') ?? 0.0;
        granTotalProduccion += double.tryParse(pliego['serigrafiaCtrl']['totalTintas']?.text ?? '0') ?? 0.0;
        granTotalProduccion += double.tryParse(pliego['serigrafiaCtrl']['totalEntrada']?.text ?? '0') ?? 0.0;
      }

      if (pliego['procesos']['Acabados Especiales'] == true) {
        var aeActivos = pliego['acabadosEspecialesCtrl']['activos'] as List<bool>;
        var aeCostos = pliego['acabadosEspecialesCtrl']['costoTotal'] as List<TextEditingController>;
        for (int i = 0; i < 5; i++) {
          if (aeActivos[i]) {
            granTotalProduccion += double.tryParse(aeCostos[i].text) ?? 0.0;
          }
        }
      }

      if (pliego['procesos']['Suaje'] == true) {
        granTotalProduccion += double.tryParse(pliego['suajeCtrl']['costoTotalSuajado']?.text ?? '0') ?? 0.0;
      }
    }

    _costoGlobalProduccionCtrl.text = granTotalProduccion.toStringAsFixed(2);

    double margenPorcentaje = double.tryParse(_margenCtrl.text) ?? 0.0;
    double descuentoPorcentaje = double.tryParse(_descuentoGlobalCtrl.text) ?? 0.0;

    double divisorMargen = 1 - (margenPorcentaje / 100.0);
    double precioConUtilidad = divisorMargen > 0 ? (granTotalProduccion / divisorMargen) : granTotalProduccion;
    
    double cantidadDescuento = precioConUtilidad * (descuentoPorcentaje / 100.0);
    double precioConDescuento = precioConUtilidad - cantidadDescuento;

    double iva = precioConDescuento * 0.16;
    double granTotalFinal = precioConDescuento + iva;

    double precioUnitario = widget.piezasTotales > 0 
          ? (granTotalFinal / widget.piezasTotales) 
          : 0.0;

      setState(() {
        _precioUtilidadCtrl.text = precioConUtilidad.toStringAsFixed(2);
        _precioDescuentoCtrl.text = precioConDescuento.toStringAsFixed(2);
        _precioUnitarioCtrl.text = precioUnitario.toStringAsFixed(2);
        _ivaGlobalCtrl.text = iva.toStringAsFixed(2);
        _precioConIvaCtrl.text = granTotalFinal.toStringAsFixed(2);
      });
  }

  List<Map<String, dynamic>> prepararDatosParaBackend() {
    return datosPliegos.map((pliego) {
      final Map<String, bool> procesos = Map<String, bool>.from(pliego['procesos'] ?? {});
      
      return {
        'titulo': pliego['titulo'],
        'is_portada': pliego['isPortada'] ?? false,
        'is_interiores': pliego['isInteriores'] ?? false,
        'multiplo_impresion': pliego['multiploImpresion'] ?? 2,
        'piezas_por_pliego': int.tryParse(pliego['piezasController']?.text ?? '0') ?? 0,
        'procesos': procesos,

        'interiores_config': (pliego['isInteriores'] == true) ? {
          'paginas_internas_pieza': int.tryParse(pliego['paginasInternasPiezaCtrl']?.text ?? '0') ?? 0,
          'paginas_internas_totales': int.tryParse(pliego['paginasInternasTotalesCtrl']?.text ?? '0') ?? 0,
          'pliegos_por_pieza': double.tryParse(pliego['pliegosPorPiezaCtrl']?.text ?? '0') ?? 0.0,
        } : null,

        'medidas_trabajo': {
          'ancho_trabajo': double.tryParse(pliego['anchoTrabajoCtrl']?.text ?? '0') ?? 0.0,
          'alto_trabajo': double.tryParse(pliego['altoTrabajoCtrl']?.text ?? '0') ?? 0.0,
          'medianil': double.tryParse(pliego['medianilCtrl']?.text ?? '0') ?? 0.0,
          'ancho_final': double.tryParse(pliego['anchoFinalCtrl']?.text ?? '0') ?? 0.0,
          'alto_final': double.tryParse(pliego['altoFinalCtrl']?.text ?? '0') ?? 0.0,
          'ancho_pliego': double.tryParse(pliego['anchoPliegoCtrl']?.text ?? '0') ?? 0.0,
          'alto_pliego': double.tryParse(pliego['altoPliegoCtrl']?.text ?? '0') ?? 0.0,
          'orientacion': pliego['orientacionCtrl']?.text ?? '',
        },
        'calculos_impresion': {
          'cantidad_ocupar_este_pliego': int.tryParse(pliego['cantidadOcuparCtrl']?.text ?? '0') ?? 0,
          'cantidad_total_pliego': double.tryParse(pliego['cantidadTotalPliegoCtrl']?.text ?? '0') ?? 0.0,
          'pliegos_extra_merma': int.tryParse(pliego['pliegosExtraCtrl']?.text ?? '0') ?? 0,
          'cantidad_pliegos_imprimir': int.tryParse(pliego['cantidadPliegosCtrl']?.text ?? '0') ?? 0,
          'piezas_sobrantes': int.tryParse(pliego['pliegosSobrantesCtrl']?.text ?? '0') ?? 0,
          'total_pliegos_utilizar': int.tryParse(pliego['totalPliegosUtilizarCtrl']?.text ?? '0') ?? 0,
          'millares_imprimir': double.tryParse(pliego['millaresImprimirCtrl']?.text ?? '0') ?? 0.0,
        },

        'offset_data': (procesos['Offset'] == true) ? {
          'papel_datos': {
            'nombre': pliego['nombrePapelCtrl']?.text ?? '',
            'tipo': pliego['tipoPapelCtrl']?.text ?? '',
            'ancho': double.tryParse(pliego['anchoPapelCtrl']?.text ?? '0') ?? 0.0,
            'largo': double.tryParse(pliego['largoPapelCtrl']?.text ?? '0') ?? 0.0,
            'peso': pliego['pesoPapelCtrl']?.text ?? '',
            'proveedor': pliego['proveedorPapelCtrl']?.text ?? '',
            'costo_millar': double.tryParse(pliego['costoMillarCtrl']?.text ?? '0') ?? 0.0,
            'total_pliegos_asignados': int.tryParse(pliego['totalPliegosCtrl']?.text ?? '0') ?? 0,
            'descuento_aplicado': double.tryParse(pliego['descuentoPapelCtrl']?.text ?? '0') ?? 0.0,
            'costo_total_sin_iva': double.tryParse(pliego['costoTotalPapelSinIvaCtrl']?.text ?? '0') ?? 0.0,
            'costo_total_con_iva': double.tryParse(pliego['costoTotalPapelConIvaCtrl']?.text ?? '0') ?? 0.0,
          },
          'maquina_datos': {
            'nombre_maquina': pliego['nombreMaquinaCtrl']?.text ?? '',
            'tintas_frente': int.tryParse(pliego['tintasFteCtrl']?.text ?? '0') ?? 0,
            'tintas_reverso': int.tryParse(pliego['tintasRevCtrl']?.text ?? '0') ?? 0,
            'costo_total_tintas': double.tryParse(pliego['costoGranTotalTintasCtrl']?.text ?? '0') ?? 0.0,
            'costo_total_placas': double.tryParse(pliego['costoTotalPlacasCtrl']?.text ?? '0') ?? 0.0,
            'costo_total_placas_790': double.tryParse(pliego['costoTotalPlacas790Ctrl']?.text ?? '0') ?? 0.0,
            'costo_barniz': double.tryParse(pliego['costoBarnizCtrl']?.text ?? '0') ?? 0.0,
            'configuracion_frente': pliego['configuracionFrente'],
            'configuracion_vuelta': pliego['configuracionVuelta'],
            
            'costo_unit_frente': double.tryParse(pliego['costoUnitFteCtrl']?.text ?? '0') ?? 0.0,
            'costo_total_frente': double.tryParse(pliego['costoTotalFteCtrl']?.text ?? '0') ?? 0.0,
            'costo_unit_reverso': double.tryParse(pliego['costoUnitRevCtrl']?.text ?? '0') ?? 0.0,
            'costo_total_reverso': double.tryParse(pliego['costoTotalRevCtrl']?.text ?? '0') ?? 0.0,
            'cantidad_placas': int.tryParse(pliego['cantidadPlacasCtrl']?.text ?? '0') ?? 0,
            'cantidad_placas_790': int.tryParse(pliego['cantidadPlacas790Ctrl']?.text ?? '0') ?? 0,
            'costo_placa': double.tryParse(pliego['costoPlacaCtrl']?.text ?? '0') ?? 0.0,
            'costo_placa_790': double.tryParse(pliego['costoPlaca790Ctrl']?.text ?? '0') ?? 0.0,
            'barniz_frente': pliego['barnizFte'] ?? false,
            'barniz_reverso': pliego['barnizRev'] ?? false,
            'costo_unit_barniz_frente': double.tryParse(pliego['costoUnitBarnizFteCtrl']?.text ?? '0') ?? 0.0,
            'costo_unit_barniz_reverso': double.tryParse(pliego['costoUnitBarnizRevCtrl']?.text ?? '0') ?? 0.0,
            'millares': double.tryParse(pliego['millaresCtrl']?.text ?? '0') ?? 0.0,
          },
          'pruebas_color': (pliego['pruebasColor'] as Map<String, dynamic>?)?.map((key, value) {
            return MapEntry(key, {
              'activo': value['activo'] ?? false,
              'cantidad': int.tryParse(value['cantidadController']?.text ?? '0') ?? 0,
              'precio': double.tryParse(value['precioController']?.text ?? '0') ?? 0.0,
              'total': double.tryParse(value['totalController']?.text ?? '0') ?? 0.0,
            });
          }) ?? {},
        } : null,

        'barniz_uv_data': (procesos['Barniz UV'] == true) ? {
          'seleccion': pliego['acabadosData'],
          'costos_cm2': (pliego['acabadosCostoCm2Ctrl'] as Map<String, TextEditingController>?)?.map(
            (k, v) => MapEntry(k, double.tryParse(v.text) ?? 0.0),
          ) ?? {},
          'costos_totales': (pliego['acabadosCostoTotalCtrl'] as Map<String, TextEditingController>?)?.map(
            (k, v) => MapEntry(k, double.tryParse(v.text) ?? 0.0),
          ) ?? {},
        } : null,

        'laminado_data': (procesos['Plastificado/Laminado'] == true) ? {
          'seleccion': pliego['laminadosData'],
          'costos_cm2': (pliego['laminadosCostoCm2Ctrl'] as Map<String, TextEditingController>?)?.map(
            (k, v) => MapEntry(k, double.tryParse(v.text) ?? 0.0),
          ) ?? {},
          'costos_totales': (pliego['laminadosCostoTotalCtrl'] as Map<String, TextEditingController>?)?.map(
            (k, v) => MapEntry(k, double.tryParse(v.text) ?? 0.0),
          ) ?? {},
        } : null,

        'grabado_data': (procesos['Grabado'] == true) ? {
          'cantidad_placas': int.tryParse(pliego['grabadoCtrl']['cantidadPlacas']?.text ?? '0') ?? 0,
          'costo_placa': double.tryParse(pliego['grabadoCtrl']['costoPlaca']?.text ?? '0') ?? 0.0,
          'costo_total_placas': double.tryParse(pliego['grabadoCtrl']['costoTotalPlacas']?.text ?? '0') ?? 0.0,
          'costo_entrada': double.tryParse(pliego['grabadoCtrl']['costoEntrada']?.text ?? '0') ?? 0.0,
          'costo_total_entrada': double.tryParse(pliego['grabadoCtrl']['costoTotalEntrada']?.text ?? '0') ?? 0.0,
          'costo_total_grabado': double.tryParse(pliego['grabadoCtrl']['costoTotalGrabado']?.text ?? '0') ?? 0.0,
        } : null,

        'serigrafia_data': (procesos['Serigrafia'] == true) ? {
          'cantidad_marcos': int.tryParse(pliego['serigrafiaCtrl']['cantidadMarcos']?.text ?? '0') ?? 0,
          'total_marcos': double.tryParse(pliego['serigrafiaCtrl']['totalMarcos']?.text ?? '0') ?? 0.0,
          'cantidad_negativos': int.tryParse(pliego['serigrafiaCtrl']['cantidadNegativos']?.text ?? '0') ?? 0,
          'precio_negativo': double.tryParse(pliego['serigrafiaCtrl']['precioNegativo']?.text ?? '0') ?? 0.0,
          'total_negativos': double.tryParse(pliego['serigrafiaCtrl']['totalNegativos']?.text ?? '0') ?? 0.0,
          'cantidad_tintas': int.tryParse(pliego['serigrafiaCtrl']['cantidadTintas']?.text ?? '0') ?? 0,
          'costo_tintas': double.tryParse(pliego['serigrafiaCtrl']['costoTintas']?.text ?? '0') ?? 0.0,
          'total_tintas': double.tryParse(pliego['serigrafiaCtrl']['totalTintas']?.text ?? '0') ?? 0.0,
          'numero_entradas': int.tryParse(pliego['serigrafiaCtrl']['numeroEntradas']?.text ?? '0') ?? 0,
          'costo_millar': double.tryParse(pliego['serigrafiaCtrl']['costoMillar']?.text ?? '0') ?? 0.0,
          'total_entrada': double.tryParse(pliego['serigrafiaCtrl']['totalEntrada']?.text ?? '0') ?? 0.0,
          
          'ancho_marcos': (pliego['serigrafiaCtrl']['anchoMarcos'] as List<TextEditingController>?)
              ?.map((c) => double.tryParse(c.text) ?? 0.0).toList() ?? [],
          'alto_marcos': (pliego['serigrafiaCtrl']['altoMarcos'] as List<TextEditingController>?)
              ?.map((c) => double.tryParse(c.text) ?? 0.0).toList() ?? [],
          'precio_marcos': (pliego['serigrafiaCtrl']['precioMarcos'] as List<TextEditingController>?)
              ?.map((c) => double.tryParse(c.text) ?? 0.0).toList() ?? [],
        } : null,

        'acabados_especiales_data': (procesos['Acabados Especiales'] == true) ? {
          'items': List.generate(5, (i) {
            final ae = pliego['acabadosEspecialesCtrl'] as Map<String, dynamic>;
            return {
              'activo': (ae['activos'] as List<bool>? ?? [])[i],
              'descripcion': ((ae['descripcion'] as List<TextEditingController>?)?[i].text) ?? '',
              'costo_millar': double.tryParse((ae['costoMillar'] as List<TextEditingController>?)?[i].text ?? '0') ?? 0.0,
              'costo_total': double.tryParse((ae['costoTotal'] as List<TextEditingController>?)?[i].text ?? '0') ?? 0.0,
            };
          }),
        } : null,

        'suaje_data': (procesos['Suaje'] == true) ? {
          'tamano_suaje': double.tryParse(pliego['suajeCtrl']['tamanoSuaje']?.text ?? '0') ?? 0.0,
          'costo_suaje_cm': double.tryParse(pliego['suajeCtrl']['costoSuajeCm']?.text ?? '0') ?? 0.0,
          'costo_total_suaje': double.tryParse(pliego['suajeCtrl']['costoTotalSuaje']?.text ?? '0') ?? 0.0,
          'costo_arreglo': double.tryParse(pliego['suajeCtrl']['costoArreglo']?.text ?? '0') ?? 0.0,
          'costo_total_suajado': double.tryParse(pliego['suajeCtrl']['costoTotalSuajado']?.text ?? '0') ?? 0.0,
          'ancho': double.tryParse(pliego['suajeCtrl']['ancho']?.text ?? '0') ?? 0.0,
          'largo': double.tryParse(pliego['suajeCtrl']['largo']?.text ?? '0') ?? 0.0,
          'se_cuenta_con_suaje': pliego['suajeCtrl']['seCuentaConSuaje'] ?? false,
          'pliegos': int.tryParse(pliego['suajeCtrl']['pliegos']?.text ?? '0') ?? 0,
          'costo_millar': double.tryParse(pliego['suajeCtrl']['costoMillar']?.text ?? '0') ?? 0.0,
        } : null,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (datosPliegos.isEmpty) {
      return const SizedBox.shrink();
    }
    List<Widget> contenido = datosPliegos.map((pliego) => _buildCardPliego(pliego)).toList();
    contenido.add(
      PanelCostoTotalPliegos(
        piezasTotales: widget.piezasTotales,
        costoTotalController: _costoGlobalProduccionCtrl,
        margenController: _margenCtrl,
        descuentoController: _descuentoGlobalCtrl,
        diasEntregaController: _diasEntregaCtrl,
        precioUtilidadController: _precioUtilidadCtrl,
        precioDescuentoController: _precioDescuentoCtrl,
        precioUnitarioController: _precioUnitarioCtrl,
        ivaController: _ivaGlobalCtrl,
        precioConIvaController: _precioConIvaCtrl,
        onRecalcular: _recalcularCostoTotal, 
      )
    );

    return Column(children: contenido);
  }

  Widget _buildCardPliego(Map<String, dynamic> pliego) {
    bool esOffsetActivo = pliego['procesos']['Offset'] == true;
    bool esBarnizUVActivo = pliego['procesos']['Barniz UV'] == true;
    bool esLaminadoActivo = pliego['procesos']['Plastificado/Laminado'] == true;
    bool esGrabadoActivo = pliego['procesos']['Grabado'] == true;

    bool isInteriores = pliego['isInteriores'] == true;

    double anchoTrabajo = double.tryParse(pliego['anchoTrabajoCtrl'].text) ?? 0.0;
    double altoTrabajo = double.tryParse(pliego['altoTrabajoCtrl'].text) ?? 0.0;
    double medianil = double.tryParse(pliego['medianilCtrl'].text) ?? 0.0;

    double anchoFinal = anchoTrabajo + medianil;
    double altoFinal = altoTrabajo + medianil;
    
    pliego['anchoFinalCtrl'].text = anchoFinal.toStringAsFixed(2);
    pliego['altoFinalCtrl'].text = altoFinal.toStringAsFixed(2);

    _ejecutarCalculosProduccion(pliego);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pliego['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            
            const Text('Procesos de trabajo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              children: (pliego['procesos'] as Map<String, bool>).keys.map((nombreProceso) {
                return SizedBox(
                  width: 200,
                  child: CheckboxListTile(
                    title: Text(nombreProceso, style: const TextStyle(fontSize: 14)),
                    value: pliego['procesos'][nombreProceso] as bool? ?? false,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? valor) {
                      setState(() { 
                        pliego['procesos'][nombreProceso] = valor!; 
                        if (nombreProceso == 'Offset' && !valor) {
                          pliego['isPortada'] = false;
                          pliego['isInteriores'] = false;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            // Checkboxes adicionales dinámicos para Portada e Interiores
            if (esOffsetActivo) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Portada', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        value: pliego['isPortada'] as bool? ?? false,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setState(() {
                            pliego['isPortada'] = val ?? false;
                            if (val == true) pliego['isInteriores'] = false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Interiores', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        value: pliego['isInteriores'] as bool? ?? false,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setState(() {
                            pliego['isInteriores'] = val ?? false;
                            if (val == true) pliego['isPortada'] = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Contenedor dinámico si la opción "Interiores" está seleccionada
            if (esOffsetActivo && isInteriores) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Configuración de Interiores de Revista', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: pliego['multiploImpresion'],
                            decoration: const InputDecoration(labelText: 'Múltiplo', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 2, child: Text('2')),
                              DropdownMenuItem(value: 4, child: Text('4')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                pliego['multiploImpresion'] = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInput('Pág. Internas x Pieza', pliego['paginasInternasPiezaCtrl'], esNumerico: true,
                          onChangedExtra: (val) {
                          if (pliego['isInteriores'] == true) {
                            // Asigna en automático el valor al controlador de cantidad a ocupar
                            pliego['cantidadOcuparCtrl'].text = val;
                          }
                        },),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputResultado('Pág. Internas Totales', pliego['paginasInternasTotalesCtrl']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (esOffsetActivo) ...[
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              const Text('Medidas del Trabajo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _buildInput('Ancho Trabajo (cm)', pliego['anchoTrabajoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Alto Trabajo (cm)', pliego['altoTrabajoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Medianil (cm)', pliego['medianilCtrl'], esNumerico: true)),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Medida Final (Trabajo + Medianil):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text('Ancho Final: ${anchoFinal.toStringAsFixed(2)} cm   |   Alto Final: ${altoFinal.toStringAsFixed(2)} cm',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.search),
                      style: IconButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        final Map<String, dynamic>? resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SegmentacionPliegosScreen(
                              anchoTrabajo: anchoFinal,
                              altoTrabajo: altoFinal,
                            ),
                          ),
                        );

                        if (resultado != null) {
                          setState(() {
                            pliego['anchoPliegoCtrl'].text = resultado['ancho']?.toString() ?? '0';
                            pliego['altoPliegoCtrl'].text = resultado['alto']?.toString() ?? '0';
                            pliego['orientacionCtrl'].text = resultado['posicion']?.toString() ?? 'Normal';
                            pliego['piezasController'].text = resultado['piezasPorPliego']?.toString() ?? '0';
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Opciones de Prueba de Color:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 10),
              Column(
                children: (pliego['pruebasColor'] as Map<String, dynamic>).keys.map((nombrePrueba) {
                  var pruebaData = pliego['pruebasColor'][nombrePrueba];
                  bool estaActivo = pruebaData['activo'] as bool? ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(nombrePrueba, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          value: estaActivo,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (bool? valor) {
                            setState(() {
                              pruebaData['activo'] = valor!;
                              if (!valor) {
                                pruebaData['cantidadController']?.clear();
                                pruebaData['precioController'].clear();
                                pruebaData['totalController'].text = '0.00';
                              }
                            });
                          },
                        ),
                        if (estaActivo)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0, top: 4, bottom: 12),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: pruebaData['cantidadController'],
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() => _calcularTotalPrueba(pruebaData)),
                                    decoration: const InputDecoration(labelText: 'Cantidad', floatingLabelBehavior: FloatingLabelBehavior.always, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: TextFormField(
                                    controller: pruebaData['precioController'],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (_) => setState(() => _calcularTotalPrueba(pruebaData)),
                                    decoration: const InputDecoration(labelText: 'Precio \$', floatingLabelBehavior: FloatingLabelBehavior.always, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: TextFormField(
                                    controller: pruebaData['totalController'],
                                    readOnly: true, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    decoration: InputDecoration(labelText: 'Total \$', floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, fillColor: Theme.of(context).disabledColor.withOpacity(0.06), border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 15),

              const Text('Datos Técnicos del Pliego Seleccionado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildInput('Ancho Pliego', pliego['anchoPliegoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Alto Pliego', pliego['altoPliegoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Orientación', pliego['orientacionCtrl'])),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      isInteriores ? 'Páginas por pliego' : 'Piezas x Pliego plano', 
                      pliego['piezasController'], 
                      esNumerico: true
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Cantidad pliegos extra (Merma)', pliego['pliegosExtraCtrl'], esNumerico: true)),
                ],
              ),
              
              if (isInteriores) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputResultado('Cantidad de pliegos por pieza', pliego['pliegosPorPiezaCtrl']),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              const Text('Resultados de Operación e Impresión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildInput('Cantidad a ocupar de este pliego', pliego['cantidadOcuparCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputResultado('Cantidad Total del Pliego', pliego['cantidadTotalPliegoCtrl'])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInputResultado('Cantidad de Pliegos a Imprimir', pliego['cantidadPliegosCtrl'])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputResultado('Piezas Sobrantes', pliego['pliegosSobrantesCtrl'])),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputResultado('Total de Pliegos a Utilizar (Con Merma)', pliego['totalPliegosUtilizarCtrl']),
              const SizedBox(height: 12),
              _buildInputResultado('Millares a Imprimir', pliego['millaresImprimirCtrl']),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelDatosPapelPliego(
                nombrePapelController: pliego['nombrePapelCtrl'],
                tipoPapelController: pliego['tipoPapelCtrl'],
                anchoPapelController: pliego['anchoPapelCtrl'],
                largoPapelController: pliego['largoPapelCtrl'],
                pesoPapelController: pliego['pesoPapelCtrl'],
                proveedorPapelController: pliego['proveedorPapelCtrl'],
                costoMillarController: pliego['costoMillarCtrl'],
                totalPliegosController: pliego['totalPliegosCtrl'],
                minAnchoRequerido: anchoFinal,
                minAltoRequerido: altoFinal,
              ),
              PanelCostoPapelPliego(
                costoMillarController: pliego['costoMillarCtrl'],
                totalPliegosController: pliego['totalPliegosCtrl'],
                descuentoController: pliego['descuentoPapelCtrl'],
                costoTotalPapelController: pliego['costoTotalPapelSinIvaCtrl'],
                costoConIvaController: pliego['costoTotalPapelConIvaCtrl'],
              ),

              PanelMaquinaPliego(
                nombreMaquinaController: pliego['nombreMaquinaCtrl'],
                costoPlacaController: pliego['costoPlacaCtrl'],
                tintasFteController: pliego['tintasFteCtrl'],
                tintasRevController: pliego['tintasRevCtrl'],
                costoUnitFteController: pliego['costoUnitFteCtrl'],
                costoTotalFteController: pliego['costoTotalFteCtrl'],
                costoUnitRevController: pliego['costoUnitRevCtrl'],
                costoTotalRevController: pliego['costoTotalRevCtrl'],
                costoGranTotalTintasController: pliego['costoGranTotalTintasCtrl'],
                cantidadPlacasController: pliego['cantidadPlacasCtrl'],
                costoBarnizController: pliego['costoBarnizCtrl'],
                costoTotalPlacasController: pliego['costoTotalPlacasCtrl'],
                cantidadPlacas790Controller: pliego['cantidadPlacas790Ctrl'],
                costoPlaca790Controller: pliego['costoPlaca790Ctrl'],
                costoTotalPlacas790Controller: pliego['costoTotalPlacas790Ctrl'],
                barnizFteController: pliego['barnizFteCtrl'],
                barnizRevController: pliego['barnizRevCtrl'],
                costoUnitBarnizFteController: pliego['costoUnitBarnizFteCtrl'],
                costoUnitBarnizRevController: pliego['costoUnitBarnizRevCtrl'],
                millaresController: pliego['millaresCtrl'],
                totalHojasController: pliego['totalPliegosUtilizarCtrl'], 
                
                opcionesFrente: pliego['opcionesFrente'],
                opcionesVuelta: pliego['opcionesVuelta'],
                valorInicialFrente: pliego['configuracionFrente'],
                valorInicialVuelta: pliego['configuracionVuelta'],
                barnizFte: pliego['barnizFte'],
                barnizRev: pliego['barnizRev'],
                cambiarPrecioPlaca: pliego['cambiarPrecioPlaca'],
                cambiarPrecioTinta: pliego['cambiarPrecioTinta'],
                cambiarPrecioBarniz: pliego['cambiarPrecioBarniz'],
                onBarnizMaquinaChanged: (v) {
                  setState(() => pliego['barnizMaquina'] = v ?? false);
                },
                onBarnizFteChanged: (v) {
                  setState(() => pliego['barnizFte'] = v);
                },
                onBarnizRevChanged: (v) {
                  setState(() => pliego['barnizRev'] = v);
                },
                onCambiarPrecioPlacaChanged: (v) {
                  setState(() => pliego['cambiarPrecioPlaca'] = v ?? false);
                },
                onCambiarPrecioTintaChanged: (v) {
                  setState(() => pliego['cambiarPrecioTinta'] = v ?? false);
                },
                onCambiarPrecioBarnizChanged: (v) {
                  setState(() => pliego['cambiarPrecioBarniz'] = v ?? false);
                },
                onConfiguracionFrenteChanged: (v) {
                  setState(() => pliego['configuracionFrente'] = v);
                },
                onConfiguracionVueltaChanged: (v) {
                  setState(() => pliego['configuracionVuelta'] = v);
                },
              ),
            ],
            
            // ==========================================================
            // 🎨 PANELES CONDICIONALES DE ACABADOS Y LAMINADO
            // ==========================================================
            if (esBarnizUVActivo) ...[
              const SizedBox(height: 20),
              const Text('Configuración de Barniz UV', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelAcabados(
                read_Only: true, 
                acabados: pliego['acabadosData'],
                pliegoAnchoController: pliego['anchoPliegoCtrl'], 
                pliegoAltoController: pliego['altoPliegoCtrl'],   
                totalPliegosController: pliego['totalPliegosUtilizarCtrl'],
                controllersCostoCm2: pliego['acabadosCostoCm2Ctrl'],
                controllersCostoTotal: pliego['acabadosCostoTotalCtrl'],
                cantidadImpresionController: pliego['cantidadTotalPliegoCtrl'], 
                isOffset: true, 
                onAcabadoChanged: (nombre, lado, valor) {
                  setState(() {
                    pliego['acabadosData'][nombre]![lado] = valor;
                  });
                },
              ),
            ],

            if (esLaminadoActivo) ...[
              const SizedBox(height: 20),
              const Text('Configuración de Plastificado / Laminado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelLaminados(
                readOnly: true, 
                laminados: pliego['laminadosData'],
                pliegoAnchoController: pliego['anchoPliegoCtrl'],
                pliegoAltoController: pliego['altoPliegoCtrl'],
                totalPliegosController: pliego['totalPliegosUtilizarCtrl'],
                controllersCostoCm2: pliego['laminadosCostoCm2Ctrl'],
                controllersCostoTotal: pliego['laminadosCostoTotalCtrl'],
                cantidadImpresionController: pliego['cantidadTotalPliegoCtrl'],
                isOffset: true,
                onLaminadoChanged: (nombre, lado, valor) {
                  setState(() {
                    pliego['laminadosData'][nombre]![lado] = valor;
                  });
                },
              ),
            ],

            if (esGrabadoActivo) ...[
              const SizedBox(height: 20),
              const Text('Configuración de Grabado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelGrabado(
                enabled: true,
                piezasTotalesController: TextEditingController(text: widget.piezasTotales.toString()), 
                cantidadPlacasController: pliego['grabadoCtrl']['cantidadPlacas'],
                costoPlacaController: pliego['grabadoCtrl']['costoPlaca'],
                costoTotalPlacasController: pliego['grabadoCtrl']['costoTotalPlacas'],
                costoEntradaController: pliego['grabadoCtrl']['costoEntrada'],
                costoTotalEntradaController: pliego['grabadoCtrl']['costoTotalEntrada'],
                costoTotalGrabadoController: pliego['grabadoCtrl']['costoTotalGrabado'],
                onChanged: _recalcularCostoTotal,
              ),
            ],

            if (pliego['procesos']['Serigrafia'] == true) ...[
              const SizedBox(height: 20),
              const Text('Configuración de Serigrafía', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelSerigrafia(
                enabled: true,
                piezasTotalesController: TextEditingController(text: widget.piezasTotales.toString()),
                cantidadMarcosController: pliego['serigrafiaCtrl']['cantidadMarcos'],
                totalMarcosController: pliego['serigrafiaCtrl']['totalMarcos'],
                anchoMarcos: pliego['serigrafiaCtrl']['anchoMarcos'],
                altoMarcos: pliego['serigrafiaCtrl']['altoMarcos'],
                precioMarcos: pliego['serigrafiaCtrl']['precioMarcos'],
                cantidadNegativosController: pliego['serigrafiaCtrl']['cantidadNegativos'],
                precioNegativoController: pliego['serigrafiaCtrl']['precioNegativo'],
                totalNegativosController: pliego['serigrafiaCtrl']['totalNegativos'],
                cantidadTintasController: pliego['serigrafiaCtrl']['cantidadTintas'],
                costoTintasController: pliego['serigrafiaCtrl']['costoTintas'],
                totalTintasController: pliego['serigrafiaCtrl']['totalTintas'],
                numeroEntradasController: pliego['serigrafiaCtrl']['numeroEntradas'],
                costoMillarController: pliego['serigrafiaCtrl']['costoMillar'],
                totalEntradaController: pliego['serigrafiaCtrl']['totalEntrada'],
              ),
            ],

            if (pliego['procesos']['Acabados Especiales'] == true) ...[
              const SizedBox(height: 20),
              const Text('Configuración de Acabados Especiales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelAcabadosEspeciales(
                enabled: true,
                cantidadImpresionController: TextEditingController(text: widget.piezasTotales.toString()),
                activos: pliego['acabadosEspecialesCtrl']['activos'],
                descripcionControllers: pliego['acabadosEspecialesCtrl']['descripcion'],
                costoMillarControllers: pliego['acabadosEspecialesCtrl']['costoMillar'],
                costoTotalControllers: pliego['acabadosEspecialesCtrl']['costoTotal'],
                onChangedActivo: (index, value) {
                  setState(() => pliego['acabadosEspecialesCtrl']['activos'][index] = value);
                },
                onCalcularCosto: (index) {
                  setState(() {}); 
                },
              ),
            ],

            if (pliego['procesos']['Suaje'] == true) ...[
              const SizedBox(height: 20),
              const Text('Configuración de Suaje y Suajado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelSuaje(
                enabled: true,
                tamanoSuajeController: pliego['suajeCtrl']['tamanoSuaje'],
                costoSuajeCmController: pliego['suajeCtrl']['costoSuajeCm'],
                costoTotalSuajeController: pliego['suajeCtrl']['costoTotalSuaje'],
                costoArregloSuajeController: pliego['suajeCtrl']['costoArreglo'],
                costoTotalSuajadoController: pliego['suajeCtrl']['costoTotalSuajado'],
                anchoSuajeController: pliego['suajeCtrl']['ancho'],
                largoSuajeController: pliego['suajeCtrl']['largo'],
                seCuentaConSuaje: pliego['suajeCtrl']['seCuentaConSuaje'],
                onSeCuentaConSuajeChanged: (v) => setState(() => pliego['suajeCtrl']['seCuentaConSuaje'] = v ?? false),
                pliegosSuajeController: pliego['totalPliegosUtilizarCtrl'], 
                costoMillarSuajeController: pliego['suajeCtrl']['costoMillar'],
              ),
            ],
          ],
        ),
      ),
    );
  }

Widget _buildInput(
  String label, 
  TextEditingController controller, {
  bool esNumerico = false, 
  Function(String)? onChangedExtra, // 👈 Se agrega este callback opcional
}) {
  return TextFormField(
    controller: controller,
    keyboardType: esNumerico ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    onChanged: (val) {
      if (onChangedExtra != null) {
        onChangedExtra(val); 
      }
      setState(() {}); 
    }, 
    style: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F)),
    decoration: InputDecoration(
      labelText: label, 
      labelStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 13),
      floatingLabelBehavior: FloatingLabelBehavior.always, 
      filled: true,
      fillColor: const Color(0xFFF4F2F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.5), borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E), width: 1), borderRadius: BorderRadius.circular(4)),
    ),
  );
}

  Widget _buildInputResultado(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true, 
      style: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: const Color(0xFFE6E1E5).withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E)), borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E)), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}