import 'package:flutter/material.dart';
import 'revista_cliente.dart';
import 'revista_paginasinternas_pligos.dart';


class RevistaScreen extends StatefulWidget {
  const RevistaScreen({super.key});

  @override
  State<RevistaScreen> createState() => _RevistaScreenState();
}

class _RevistaScreenState extends State<RevistaScreen> {
  // =================================
  // CONTROLADORES GENERALES
  // =================================
  final TextEditingController cantidadImpresionController =
      TextEditingController();
  final TextEditingController tipoTrabajoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  // ===== PÁGINAS INTERIORES - MEDIDAS =====
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController medianilController = TextEditingController();
  final TextEditingController anchoFinalController = TextEditingController();
  final TextEditingController altoFinalController = TextEditingController();

  // ===============================================
  // CONTROLADORES: CANTIDADES INTERIORES
  // ===============================================
  final TextEditingController multiplosImpresionController =
      TextEditingController(text: '4');

  final TextEditingController paginasPorPiezaController =
      TextEditingController();
  final TextEditingController cantidadPiezasTotalesController =
      TextEditingController();
  final TextEditingController cantidadPaginasTotalesController =
      TextEditingController();

  // ===============================================
  // CONTROLADORES: PLIEGOS (NUEVOS)
  // ===============================================
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

  bool suaje = false;

  @override
  void initState() {
    super.initState();

    paginasPorPiezaController.addListener(_calcularPaginasTotales);
    cantidadPiezasTotalesController.addListener(_calcularPaginasTotales);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _calcularPaginasTotales());
  }

  void _calcularPaginasTotales() {
    final int piezas =
        int.tryParse(cantidadPiezasTotalesController.text) ?? 0;
    final int paginasPorPieza =
        int.tryParse(paginasPorPiezaController.text) ?? 0;

    cantidadPaginasTotalesController.text =
        (piezas * paginasPorPieza).toString();
  }

  @override
  void dispose() {
    paginasPorPiezaController.removeListener(_calcularPaginasTotales);
    cantidadPiezasTotalesController.removeListener(_calcularPaginasTotales);

    cantidadImpresionController.dispose();
    tipoTrabajoController.dispose();
    descripcionController.dispose();
    anchoController.dispose();
    altoController.dispose();
    medianilController.dispose();
    anchoFinalController.dispose();
    altoFinalController.dispose();

    multiplosImpresionController.dispose();
    paginasPorPiezaController.dispose();
    cantidadPiezasTotalesController.dispose();
    cantidadPaginasTotalesController.dispose();

    // 🔻 PLIEGOS
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotización Revista'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// PANEL CLIENTES / DATOS GENERALES
            RevistaPanelClientes(
              cantidadImpresionController: cantidadImpresionController,
              tipoTrabajoController: tipoTrabajoController,
              descripcionController: descripcionController,
              anchoController: anchoController,
              anchoFinalController: anchoFinalController,
              altoController: altoController,
              altoFinalController: altoFinalController,
              medianilController: medianilController,

              multiplosImpresionController: multiplosImpresionController,
              paginasPorPiezaController: paginasPorPiezaController,
              cantidadPiezasTotalesController:
                  cantidadPiezasTotalesController,
              cantidadPaginasTotalesController:
                  cantidadPaginasTotalesController,

              suaje: suaje,
              onSuajeChanged: (value) {
                setState(() {
                  suaje = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// PANEL PLIEGOS – PÁGINAS INTERNAS
            RevistaPaginasInternasPliegos(
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              pliegoAnchoController: pliegoAnchoController,
              pliegoAltoController: pliegoAltoController,
              posicionPiezasController: posicionPiezasController,
              piezasPorPliegoController: piezasPorPliegoController,
              tamanoPorPliegoController: tamanoPorPliegoController,
              cantidadImpresionesController:
                  cantidadImpresionController,
              cantidadPliegosController: cantidadPliegosController,
              pliegosSobrantesController: pliegosSobrantesController,
              totalPliegosController: totalPliegosController,
              millaresController: millaresController,
            ),
          ],
        ),
      ),
    );
  }
}
