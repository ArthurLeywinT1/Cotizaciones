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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class BarraDropdown extends StatelessWidget {
  final String titulo;
  final List<PopupMenuEntry<String>> opciones;
  final Function(String) onSelected;

  const BarraDropdown({
    super.key,
    required this.titulo,
    required this.opciones,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Ver opciones de $titulo",
      onSelected: onSelected,
      itemBuilder: (context) => opciones,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Color.fromARGB(255, 33, 33, 33),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Color.fromARGB(255, 33, 33, 33),
            ),
          ],
        ),
      ),
    );
  }
}
