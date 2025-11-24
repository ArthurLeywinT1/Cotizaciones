import 'package:flutter/material.dart';
import 'pantalla_base.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: "Clientes",
      onAgregar: () => _mensaje(context, "Agregar Cliente"),
      onModificar: () => _mensaje(context, "Modificar Cliente"),
      onEliminar: () => _mensaje(context, "Eliminar Cliente"),
    );
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}
