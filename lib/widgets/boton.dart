import 'package:flutter/material.dart';

class Boton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isWarning;

  const Boton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color fgColor = Colors.black87;

    if (isDestructive) {
      bgColor = Colors.red.shade50;
      fgColor = Colors.red;
    } else if (isWarning) {
      bgColor = Colors.orange.shade50;
      fgColor = Colors.orange.shade800;
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 1,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
