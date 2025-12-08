import 'package:flutter/material.dart';

class PanelDatosPapel extends StatelessWidget {
  const PanelDatosPapel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Datos del Papel", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: "Tipo papel")),
            TextField(decoration: InputDecoration(labelText: "Medida compra")),
            TextField(decoration: InputDecoration(labelText: "Peso g/m²")),
            TextField(decoration: InputDecoration(labelText: "Costo millar")),
          ],
        ),
      ),
    );
  }
}
