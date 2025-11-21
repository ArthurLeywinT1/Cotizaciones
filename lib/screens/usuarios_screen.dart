import 'package:flutter/material.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Agregar')),
              ElevatedButton(onPressed: () {}, child: const Text('Modificar')),
              ElevatedButton(onPressed: () {}, child: const Text('Eliminar')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
