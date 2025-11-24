import 'package:flutter/material.dart';
import 'pantalla_base.dart';

class ProveedoresScreen extends StatelessWidget {
  const ProveedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: "Proveedores",
      onAgregar: () => _mensaje(context, "Agregar Proveedor"),
      onModificar: () => _mensaje(context, "Modificar Proveedor"),
      onEliminar: () => _mensaje(context, "Eliminar Proveedor"),
    );
  }

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
}
