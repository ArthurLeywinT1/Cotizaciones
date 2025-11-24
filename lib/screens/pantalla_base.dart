import 'package:flutter/material.dart';

class PantallaBase extends StatelessWidget {
  final String titulo;

  final VoidCallback? onAgregar;
  final VoidCallback? onModificar;
  final VoidCallback? onEliminar;

  const PantallaBase({
    super.key,
    required this.titulo,
    this.onAgregar,
    this.onModificar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Center(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // BOTONERA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onAgregar,
                child: const Text('Agregar'),
              ),
              ElevatedButton(
                onPressed: onModificar,
                child: const Text('Modificar'),
              ),
              ElevatedButton(
                onPressed: onEliminar,
                child: const Text('Eliminar'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
