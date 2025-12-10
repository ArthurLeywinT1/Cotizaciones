import 'package:flutter/material.dart';

class PanelSuaje extends StatelessWidget {
  final bool enabled;

  const PanelSuaje({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                Text("Suaje", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(decoration: InputDecoration(labelText: "Tamaño suaje")),
                TextField(decoration: InputDecoration(labelText: "Costo suaje")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
