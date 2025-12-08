import 'package:flutter/material.dart';

class PanelPliegos extends StatelessWidget {
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;

  final TextEditingController pliegoAnchoController;
  final TextEditingController pliegoAltoController;

  final TextEditingController posicionPiezasController;
  final TextEditingController piezasPorPliegoController;
  final TextEditingController tamanoPorPliegoController;

  const PanelPliegos({
    super.key,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.pliegoAnchoController,
    required this.pliegoAltoController,
    required this.posicionPiezasController,
    required this.piezasPorPliegoController,
    required this.tamanoPorPliegoController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Datos del Pliego", style: TextStyle(fontWeight: FontWeight.bold)),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pliegoAnchoController,
                    decoration: const InputDecoration(labelText: "Ancho pliego"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: pliegoAltoController,
                    decoration: const InputDecoration(labelText: "Alto pliego"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: posicionPiezasController,
              decoration: const InputDecoration(labelText: "Posición piezas por pliego"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: piezasPorPliegoController,
              decoration: const InputDecoration(labelText: "Piezas por pliego"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: tamanoPorPliegoController,
              decoration: const InputDecoration(labelText: "Tamaño por pliego"),
            ),
          ],
        ),
      ),
    );
  }
}
