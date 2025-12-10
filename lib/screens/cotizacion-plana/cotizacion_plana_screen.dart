import 'package:flutter/material.dart';

// IMPORTACIONES DE LOS PANELES
import 'cotizacion_plana_clientes.dart';
import 'cotizacion_plana_pliegos.dart';
import 'cotizacion_plana_datos_papel.dart';
import 'cotizacion_plana_costo_papel.dart';
import 'cotizacion_plana_maquina.dart';
import 'cotizacion_plana_acabados.dart';
import 'cotizacion_plana_suaje.dart';
import 'cotizacion_plana_acabados_especiales.dart';
import 'cotizacion_plana_costo_total.dart';

class CotizacionPlanaScreen extends StatefulWidget {
  const CotizacionPlanaScreen({super.key});

  @override
  State<CotizacionPlanaScreen> createState() => _CotizacionPlanaScreenState();
}

class _CotizacionPlanaScreenState extends State<CotizacionPlanaScreen> {
  // =============================
  // CONTROLADORES – CLIENTES
  // =============================
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController medianilController = TextEditingController();

  final TextEditingController anchoFinalController =
      TextEditingController(text: "0");
  final TextEditingController altoFinalController =
      TextEditingController(text: "0");

  final TextEditingController cantidadImpresionController =
      TextEditingController(text: "0");

  // =============================
  // CONTROLADORES – PLIEGOS
  // =============================
  final TextEditingController pliegoAnchoController = TextEditingController();
  final TextEditingController pliegoAltoController = TextEditingController();
  final TextEditingController posicionPiezasController =
      TextEditingController();
  final TextEditingController piezasPorPliegoController =
      TextEditingController();
  final TextEditingController tamanoPorPliegoController =
      TextEditingController();

  final TextEditingController cantidadPliegosController =
      TextEditingController();
  final TextEditingController pliegosSobrantesController =
      TextEditingController();
  final TextEditingController totalPliegosController =
      TextEditingController();
  final TextEditingController millaresController = TextEditingController();

  // =============================
  // ESTADOS GENERALES
  // =============================
  bool suaje = false;
  bool panelAcabadosActivo = true;

  // =============================
  // ACABADOS (SOLO PARA PanelAcabados)
  // =============================
  Map<String, Map<String, bool>> acabados = {
    "Barniz UV a Registro": {"frente": false, "vuelta": false},
    "Plastificado Brillante": {"frente": false, "vuelta": false},
    "Plastificado Mate": {"frente": false, "vuelta": false},
    "Barniz UV Brillante a Plasta": {"frente": false, "vuelta": false},
    "Barniz UV Mate Plasta": {"frente": false, "vuelta": false},
  };

  // =============================
  // LÓGICA
  // =============================
  void calcularMedidasFinales() {
    final ancho = double.tryParse(anchoController.text) ?? 0;
    final alto = double.tryParse(altoController.text) ?? 0;
    final medianil = double.tryParse(medianilController.text) ?? 0;

    setState(() {
      anchoFinalController.text = (ancho + medianil).toStringAsFixed(2);
      altoFinalController.text = (alto + medianil).toStringAsFixed(2);
    });
  }

  void actualizarAcabado(
      String nombre, String lado, bool valor) {
    setState(() {
      acabados[nombre]?[lado] = valor;
    });
  }

  @override
  void dispose() {
    anchoController.dispose();
    altoController.dispose();
    medianilController.dispose();
    anchoFinalController.dispose();
    altoFinalController.dispose();
    cantidadImpresionController.dispose();

    pliegoAnchoController.dispose();
    pliegoAltoController.dispose();
    posicionPiezasController.dispose();
    piezasPorPliegoController.dispose();
    tamanoPorPliegoController.dispose();

    cantidadPliegosController.dispose();
    pliegosSobrantesController.dispose();
    totalPliegosController.dispose();
    millaresController.dispose();

    super.dispose();
  }

  // =============================
  // BUILD
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cotización Plana")),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PanelClientes(
              cantidadImpresionController: cantidadImpresionController,
              anchoController: anchoController,
              altoController: altoController,
              medianilController: medianilController,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              suaje: suaje,
              onCalcular: calcularMedidasFinales,
              onSuajeChanged: (v) => setState(() => suaje = v),
            ),

            PanelPliegos(
              cantidadImpresionesController: cantidadImpresionController,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              pliegoAnchoController: pliegoAnchoController,
              pliegoAltoController: pliegoAltoController,
              posicionPiezasController: posicionPiezasController,
              piezasPorPliegoController: piezasPorPliegoController,
              tamanoPorPliegoController: tamanoPorPliegoController,
              cantidadPliegosController: cantidadPliegosController,
              pliegosSobrantesController: pliegosSobrantesController,
              totalPliegosController: totalPliegosController,
              millaresController: millaresController,
            ),

            PanelDatosPapel(
               totalPliegosController: totalPliegosController,
                ),

            const PanelCostoPapel(),
            const PanelMaquina(),

            PanelAcabados(
              enabled: panelAcabadosActivo,
              acabados: acabados,
              onAcabadoChanged: actualizarAcabado,
            ),

            PanelSuaje(enabled: suaje),
            const PanelAcabadosEspeciales(),
            const PanelCostoTotal(),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
