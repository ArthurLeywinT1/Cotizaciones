import 'package:flutter/material.dart';
import 'pantalla_base.dart';

class DescuentosPapelScreen extends StatelessWidget {
  const DescuentosPapelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: "Descuentos Papel",
      onAgregar: () => _mensaje(context, "Agregar Descuento"),
      onModificar: () => _mensaje(context, "Modificar Descuento"),
      onEliminar: () => _mensaje(context, "Eliminar Descuento"),
    );
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}
