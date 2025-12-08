import 'package:flutter/material.dart';

class PanelCostoPapel extends StatelessWidget {
  const PanelCostoPapel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Costo del Papel", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "Costo sin descuento")),
            TextField(decoration: InputDecoration(labelText: "Descuento (%)")),
            TextField(decoration: InputDecoration(labelText: "Costo con IVA")),
          ],
        ),
      ),
    );
  }
}
