import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // ======================================
  // CONTROLADORES — AQUÍ VAN TODOS
  // ======================================
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController medianilController = TextEditingController();
  final TextEditingController anchoFinalController = TextEditingController(text: "0");
  final TextEditingController altoFinalController = TextEditingController(text: "0");

  final TextEditingController pliegoAnchoController = TextEditingController();
  final TextEditingController pliegoAltoController = TextEditingController();

  final TextEditingController posicionPiezasController = TextEditingController();
  final TextEditingController piezasPorPliegoController = TextEditingController();
  final TextEditingController tamanoPorPliegoController = TextEditingController();

  // ACABADOS
  bool barnizRegistro = false;
  bool plastificadoBrillante = false;
  bool plastificadoMate = false;
  bool uvBrillantePlasta = false;
  bool uvMatePlasta = false;

  bool panelAcabadosActivo = false;

  // SUAJE
  bool suaje = false;

  // ======================================
  // MÉTODOS Y LÓGICA
  // ======================================

  void _calcularMedidasFinales() {
    final ancho = double.tryParse(anchoController.text) ?? 0;
    final alto = double.tryParse(altoController.text) ?? 0;
    final medianil = double.tryParse(medianilController.text) ?? 0;

    setState(() {
      anchoFinalController.text = (ancho + medianil).toStringAsFixed(2);
      altoFinalController.text = (alto + medianil).toStringAsFixed(2);
    });
  }

  // ======================================
  // BUILD PRINCIPAL
  // ======================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cotización Plana")),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PANEL CLIENTES
            PanelClientes(
              anchoController: anchoController,
              altoController: altoController,
              medianilController: medianilController,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              suaje: suaje,
              onCalcular: _calcularMedidasFinales,
              onSuajeChanged: (v) => setState(() => suaje = v),
              onAcabadosChanged: (isActive) =>
                  setState(() => panelAcabadosActivo = isActive),
            ),

            // PANEL PLIEGOS
            PanelPliegos(
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              pliegoAnchoController: pliegoAnchoController,
              pliegoAltoController: pliegoAltoController,
              posicionPiezasController: posicionPiezasController,
              piezasPorPliegoController: piezasPorPliegoController,
              tamanoPorPliegoController: tamanoPorPliegoController,
            ),

            // PANEL PAPEL
            const PanelDatosPapel(),

            // COSTO PAPEL
            const PanelCostoPapel(),

            // MAQUINA
            const PanelMaquina(),

            PanelAcabados(enabled: panelAcabadosActivo),
            
            PanelSuaje(enabled: suaje),

            // ACABADOS ESPECIALES
            const PanelAcabadosEspeciales(),

            // COSTO TOTAL
            const PanelCostoTotal(),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
