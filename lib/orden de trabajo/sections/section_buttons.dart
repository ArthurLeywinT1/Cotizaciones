import 'package:flutter/material.dart';

class SectionButtons extends StatelessWidget {
  const SectionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDisabledButton("Inicio", Icons.play_arrow, Colors.blue),
          _buildDisabledButton("Fin", Icons.stop, Colors.red),
          _buildDisabledButton("Incidente", Icons.warning_amber_rounded, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildDisabledButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      // Al pasar null al onPressed, el botón se ve "deshabilitado" u oculto visualmente de acción
      onPressed: null, 
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        disabledForegroundColor: color.withOpacity(0.6),
        disabledBackgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}