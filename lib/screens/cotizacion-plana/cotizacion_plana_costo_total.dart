import 'package:flutter/material.dart';

class PanelCostoTotal extends StatelessWidget {
  const PanelCostoTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Costo Total", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "Precio total")),
            TextField(decoration: InputDecoration(labelText: "Descuento (%)")),
            TextField(decoration: InputDecoration(labelText: "Precio final")),
          ],
        ),
      ),
    );
  }
}
