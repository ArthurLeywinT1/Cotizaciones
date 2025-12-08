import 'package:flutter/material.dart';

class PanelMaquina extends StatelessWidget {
  const PanelMaquina({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Datos de Máquina", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "Nombre máquina")),
            TextField(decoration: InputDecoration(labelText: "Total tintas")),
            TextField(decoration: InputDecoration(labelText: "Costo tintas front")),
            TextField(decoration: InputDecoration(labelText: "Costo tintas reverso")),
          ],
        ),
      ),
    );
  }
}
