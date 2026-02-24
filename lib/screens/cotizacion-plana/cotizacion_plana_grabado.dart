import 'package:flutter/material.dart';

class PanelGrabado extends StatefulWidget {
  final TextEditingController piezasTotalesController;

  const PanelGrabado({
    super.key,
    required this.piezasTotalesController,
  });

  @override
  State<PanelGrabado> createState() => _PanelGrabadoState();
}

class _PanelGrabadoState extends State<PanelGrabado> {

  final TextEditingController cantidadPlacasController =
      TextEditingController(text: "0");

  final TextEditingController costoPlacaController =
      TextEditingController(text: "0.00");

  final TextEditingController costoTotalPlacasController =
      TextEditingController(text: "0.00");

  final TextEditingController costoEntradaController =
      TextEditingController(text: "0.00");

  final TextEditingController costoTotalEntradaController =
      TextEditingController(text: "0.00");

  final TextEditingController costoTotalGrabadoController =
      TextEditingController(text: "0.00");

  @override
  void initState() {
    super.initState();

    cantidadPlacasController.addListener(calcular);
    costoPlacaController.addListener(calcular);
    costoEntradaController.addListener(calcular);
    widget.piezasTotalesController.addListener(calcular);
  }

  void calcular() {
  final piezas =
      double.tryParse(widget.piezasTotalesController.text) ?? 0;

  final cantidadPlacas =
      double.tryParse(cantidadPlacasController.text) ?? 0;

  final costoPlaca =
      double.tryParse(costoPlacaController.text) ?? 0;

  final costoEntrada =
      double.tryParse(costoEntradaController.text) ?? 0;

  final totalPlacas = cantidadPlacas * costoPlaca;

  // 🔥 Ahora es por millar
  final totalEntrada = (piezas / 1000) * costoEntrada;

  final totalGrabado = totalPlacas + totalEntrada;

  costoTotalPlacasController.text =
      totalPlacas.toStringAsFixed(2);

  costoTotalEntradaController.text =
      totalEntrada.toStringAsFixed(2);

  costoTotalGrabadoController.text =
      totalGrabado.toStringAsFixed(2);
}

  @override
  void dispose() {
    cantidadPlacasController.dispose();
    costoPlacaController.dispose();
    costoTotalPlacasController.dispose();
    costoEntradaController.dispose();
    costoTotalEntradaController.dispose();
    costoTotalGrabadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            /// ========================
            /// PLACAS
            /// ========================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cantidadPlacasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Cantidad de Placas",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: costoPlacaController,
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
              controller: costoTotalPlacasController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Costo Total Placas",
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const Divider(height: 24),

            /// ========================
            /// ENTRADA
            /// ========================

            TextField(
              controller: costoEntradaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Costo de Entrada (por millar)",
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: costoTotalEntradaController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Costo Total Entrada",
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const Divider(height: 24),

            /// ========================
            /// TOTAL GRABADO
            /// ========================

            TextField(
              controller: costoTotalGrabadoController,
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