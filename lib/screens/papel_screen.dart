import 'package:flutter/material.dart';
import 'pantalla_base.dart';

class PapelScreen extends StatelessWidget {
  const PapelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: "Papel",
      onAgregar: () => _mensaje(context, "Agregar Papel"),
      onModificar: () => _mensaje(context, "Modificar Papel"),
      onEliminar: () => _mensaje(context, "Eliminar Papel"),
    );
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}
