import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

// Panel específico para el cálculo de grabado
class PanelGrabado extends ConsumerStatefulWidget {
  final TextEditingController piezasTotalesController;

  final TextEditingController cantidadPlacasController;
  final TextEditingController costoPlacaController;
  final TextEditingController costoTotalPlacasController;

  final TextEditingController costoEntradaController;
  final TextEditingController costoTotalEntradaController;

  final TextEditingController costoTotalGrabadoController;

  const PanelGrabado({
    super.key,
    required this.piezasTotalesController,

    required this.cantidadPlacasController,
    required this.costoPlacaController,
    required this.costoTotalPlacasController,

    required this.costoEntradaController,
    required this.costoTotalEntradaController,

    required this.costoTotalGrabadoController,
  });

  @override
  ConsumerState<PanelGrabado> createState() => _PanelGrabadoState();
}

class _PanelGrabadoState extends ConsumerState<PanelGrabado> {
  @override
  void initState() {
    super.initState();

    widget.cantidadPlacasController.addListener(calcular);
    widget.costoPlacaController.addListener(calcular);
    widget.costoEntradaController.addListener(calcular);
    widget.piezasTotalesController.addListener(calcular);

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarCostosBD());
  }

  void _cargarCostosBD() {
    final extrasState = ref.read(extrasProvider);

    try {
      final extraPlaca = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'placa grabado',
      );
      final double valorActual =
          double.tryParse(widget.costoPlacaController.text) ?? 0.0;

      if (valorActual == 0) {
        widget.costoPlacaController.text = (extraPlaca.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    try {
      final extraEntrada = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'entrada grabado por millar',
      );
      final double valorActual =
          double.tryParse(widget.costoEntradaController.text) ?? 0.0;

      if (valorActual == 0) {
        widget.costoEntradaController.text = (extraEntrada.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    calcular();
  }

  void calcular() {
    final piezas = double.tryParse(widget.piezasTotalesController.text) ?? 0;

    final cantidadPlacas =
        double.tryParse(widget.cantidadPlacasController.text) ?? 0;

    final costoPlaca = double.tryParse(widget.costoPlacaController.text) ?? 0;

    final costoEntrada =
        double.tryParse(widget.costoEntradaController.text) ?? 0;

    final totalPlacas = cantidadPlacas * costoPlaca;
    final totalEntrada = (piezas / 1000) * costoEntrada;
    final totalGrabado = totalPlacas + totalEntrada;

    widget.costoTotalPlacasController.text = totalPlacas.toStringAsFixed(2);

    widget.costoTotalEntradaController.text = totalEntrada.toStringAsFixed(2);

    widget.costoTotalGrabadoController.text = totalGrabado.toStringAsFixed(2);
  }

  @override
  void dispose() {
    widget.cantidadPlacasController.removeListener(calcular);
    widget.costoPlacaController.removeListener(calcular);
    widget.costoEntradaController.removeListener(calcular);
    widget.piezasTotalesController.removeListener(calcular);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) => _cargarCostosBD());
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Grabado",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.cantidadPlacasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Cantidad de Placas",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: widget.costoPlacaController, //precio en extras
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Costo por Placa",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            TextField(
              controller: widget.costoTotalPlacasController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Costo Total Placas",
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const Divider(height: 24),

            TextField(
              readOnly: true,
              controller: widget.costoEntradaController, //precio en extras
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Costo de Entrada (por millar)",
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: widget.costoTotalEntradaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Costo Total Entrada",
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const Divider(height: 24),

            TextField(
              controller: widget.costoTotalGrabadoController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Costo Total Grabado",
                filled: true,
                fillColor: Color(0xFFDDDDDD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
