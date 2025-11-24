import 'package:flutter/material.dart';
import 'pantalla_base.dart';

class MaquinasScreen extends StatelessWidget {
  const MaquinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: "Máquinas",
      onAgregar: () => _mensaje(context, "Agregar Máquina"),
      onModificar: () => _mensaje(context, "Modificar Máquina"),
      onEliminar: () => _mensaje(context, "Eliminar Máquina"),
    );
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}
