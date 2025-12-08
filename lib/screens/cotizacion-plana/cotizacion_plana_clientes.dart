import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanelClientes extends StatelessWidget {
  final TextEditingController anchoController;
  final TextEditingController altoController;
  final TextEditingController medianilController;

  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;

  final bool suaje;
  final Function(bool) onSuajeChanged;

  final VoidCallback onCalcular;

  final Function(bool) onAcabadosChanged;

  const PanelClientes({
    super.key,
    required this.anchoController,
    required this.altoController,
    required this.medianilController,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.suaje,
    required this.onSuajeChanged,
    required this.onCalcular,
    required this.onAcabadosChanged,
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
            const Text("Datos del Cliente", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: anchoController,
                    decoration: const InputDecoration(labelText: "Ancho"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: altoController,
                    decoration: const InputDecoration(labelText: "Alto"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: medianilController,
                    decoration: const InputDecoration(labelText: "Medianil"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: onCalcular,
                  child: const Text("Calcular Final"),
                )
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: anchoFinalController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "Ancho Final"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: altoFinalController,
                    enabled: false,
                    decoration: const InputDecoration(labelText: "Alto Final"),
                  ),
                ),
              ],
            ),

            CheckboxListTile(
              title: const Text("Suaje"),
              value: suaje,
              onChanged: (v) => onSuajeChanged(v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}
