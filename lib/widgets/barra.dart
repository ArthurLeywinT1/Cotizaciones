import 'package:flutter/material.dart';

class BarraItem extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;

  const BarraItem({super.key, required this.texto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          texto,
          style: const TextStyle(
            color: Color.fromARGB(255, 33, 33, 33),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
