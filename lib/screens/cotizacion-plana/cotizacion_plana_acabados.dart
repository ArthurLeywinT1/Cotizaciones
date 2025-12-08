import 'package:flutter/material.dart';

class PanelAcabados extends StatelessWidget {
  final bool enabled;

  const PanelAcabados({super.key, required this.enabled});

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
                Text("Acabados", style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(title: Text("Barniz UV"), value: false, onChanged: null),
                CheckboxListTile(title: Text("Plastificado brillante"), value: false, onChanged: null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
