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

  const CantidadPliegos({super.key, required this.numeroDePliegos, required this.piezasTotales});

  @override
  State<CantidadPliegos> createState() => _CantidadPliegosState();
}

class _CantidadPliegosState extends State<CantidadPliegos> {
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
    datosPliegos = List.generate(widget.numeroDePliegos, (index) {
      return {
        'titulo': 'Pliego ${index + 1}',
        'anchoTrabajoCtrl': TextEditingController(),
        'altoTrabajoCtrl': TextEditingController(),
        'medianilCtrl': TextEditingController(),
        
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

        // Estados y controladores para la opción de Revista
        'isPortada': false,
        'isInteriores': false,
        'multiploImpresion': 2, // 2 o 4
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
        'barnizFteCtrl': TextEditingController(),
        'barnizRevCtrl': TextEditingController(),
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
        double totalPliegosPieza = double.tryParse(pliego['pliegosPorPiezaCtrl']?.text ?? '1.0') ?? 1.0;
        double factorMultiplicador = pliego['isInteriores'] == true ? totalPliegosPieza.ceilToDouble() : 1.0;

        // Multiplicamos costos de máquina y placas por la cantidad de pliegos por pieza si es revista
        double costoTintas = double.tryParse(pliego['costoGranTotalTintasCtrl']?.text ?? '0') ?? 0.0;
        double costoPlacas = double.tryParse(pliego['costoTotalPlacasCtrl']?.text ?? '0') ?? 0.0;
        double costoPlacas790 = double.tryParse(pliego['costoTotalPlacas790Ctrl']?.text ?? '0') ?? 0.0;
        double costoBarniz = double.tryParse(pliego['costoBarnizCtrl']?.text ?? '0') ?? 0.0;

        granTotalProduccion += costoTintas * factorMultiplicador;
        granTotalProduccion += costoPlacas * factorMultiplicador;
        granTotalProduccion += costoPlacas790 * factorMultiplicador;
        granTotalProduccion += costoBarniz * factorMultiplicador;
        
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
        if (pliego['suajeCtrl']['seCuentaConSuaje'] == false) {
           granTotalProduccion += double.tryParse(pliego['suajeCtrl']['costoTotalSuaje']?.text ?? '0') ?? 0.0;
        }
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

    double precioUnitario = widget.piezasTotales > 0 ? (precioConDescuento / widget.piezasTotales) : 0.0;

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
      final bool tieneOffset = pliego['procesos']['Offset'] ?? false;
      return {
        'titulo': pliego['titulo'],
        'piezas_por_pliego': int.tryParse(pliego['piezasController'].text) ?? 0,
        'procesos': pliego['procesos'], 
        'offset_data': tieneOffset ? {
          'ancho_trabajo': pliego['anchoTrabajoCtrl'].text,
          'alto_trabajo': pliego['altoTrabajoCtrl'].text,
          'medianil': pliego['medianilCtrl'].text,
          'ancho_pliego': pliego['anchoPliegoCtrl'].text,
          'alto_pliego': pliego['altoPliegoCtrl'].text,
          'orientacion_piezas': pliego['orientacionCtrl'].text,
          'pliegos_extra': pliego['pliegosExtraCtrl'].text,
          'cantidad_ocupar_de_este_pliego': pliego['cantidadOcuparCtrl'].text,
          'cantidad_total_del_pliego': pliego['cantidadTotalPliegoCtrl'].text,
          'cantidad_pliegos_calculados': pliego['cantidadPliegosCtrl'].text,
          'pliegos_sobrantes': pliego['pliegosSobrantesCtrl'].text,
          'total_pliegos_utilizar': pliego['totalPliegosUtilizarCtrl'].text,
          'millares_imprimir': pliego['millaresImprimirCtrl'].text,
          
          'papel_datos': {
            'nombre': pliego['nombrePapelCtrl'].text,
            'tipo': pliego['tipoPapelCtrl'].text,
            'ancho': pliego['anchoPapelCtrl'].text,
            'largo': pliego['largoPapelCtrl'].text,
            'peso': pliego['pesoPapelCtrl'].text,
            'proveedor': pliego['proveedorPapelCtrl'].text,
            'costo_millar': pliego['costoMillarCtrl'].text,
            'total_pliegos_assigned': pliego['totalPliegosCtrl'].text,
            'descuento_aplicado': pliego['descuentoPapelCtrl'].text,
            'costo_total_sin_iva': pliego['costoTotalPapelSinIvaCtrl'].text,
            'costo_total_con_iva': pliego['costoTotalPapelConIvaCtrl'].text,
          },

          'maquina_datos': {
            'nombre_maquina': pliego['nombreMaquinaCtrl'].text,
            'tintas_frente': pliego['tintasFteCtrl'].text,
            'tintas_reverso': pliego['tintasRevCtrl'].text,
            'costo_total_tintas': pliego['costoGranTotalTintasCtrl'].text,
            'costo_total_placas': pliego['costoTotalPlacasCtrl'].text,
            'costo_total_placas_790': pliego['costoTotalPlacas790Ctrl'].text,
            'costo_barniz': pliego['costoBarnizCtrl'].text,
            'configuracion_frente': pliego['configuracionFrente'],
            'configuracion_vuelta': pliego['configuracionVuelta'],
          },

          'pruebas_color': (pliego['pruebasColor'] as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, {
              'activo': value['activo'],
              'cantidad': int.tryParse(value['cantidadController'].text) ?? 0,
              'precio': double.tryParse(value['precioController'].text) ?? 0.0,
              'total': double.tryParse(value['totalController'].text) ?? 0.0,
            });
          }),
        } : null
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

    bool isPortada = pliego['isPortada'] == true;
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
                    value: pliego['procesos'][nombreProceso],
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
                        value: pliego['isPortada'],
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
                        value: pliego['isInteriores'],
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
                          child: _buildInput('Pág. Internas x Pieza', pliego['paginasInternasPiezaCtrl'], esNumerico: true),
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
                  bool estaActivo = pruebaData['activo'] == true;
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

  Widget _buildInput(String label, TextEditingController controller, {bool esNumerico = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: esNumerico ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      onChanged: (_) => setState(() {}), 
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