import 'package:flutter/material.dart';
import 'pantalla_base.dart';

class ExtrasScreen extends StatelessWidget {
  const ExtrasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: "Extras",
      onAgregar: () => _mensaje(context, "Agregar Extra"),
      onModificar: () => _mensaje(context, "Modificar Extra"),
      onEliminar: () => _mensaje(context, "Eliminar Extra"),
    );
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}
