import 'package:flutter/material.dart';

class PanelAcabadosEspeciales extends StatelessWidget {
  const PanelAcabadosEspeciales({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Acabados Especiales", style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(title: Text("Especial 1"), value: false, onChanged: null),
            CheckboxListTile(title: Text("Especial 2"), value: false, onChanged: null),
          ],
        ),
      ),
    );
  }
}
