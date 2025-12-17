import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/proveedor_model.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_proveedor.dart';

class ProveedorScreen extends ConsumerWidget {
  const ProveedorScreen({super.key});

  void _agregarProveedor(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ModalProveedor(
        titulo: 'Nuevo Proveedor',
        onGuardar: (proveedorNuevo) async {
          final success = await ref
              .read(proveedoresProvider.notifier)
              .crearProveedor(proveedorNuevo);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Proveedor creado')));
          }
        },
      ),
    );
  }

  void _modificarProveedor(
    BuildContext context,
    WidgetRef ref,
    Proveedor proveedor,
  ) {
    showDialog(
      context: context,
      builder: (context) => ModalProveedor(
        titulo: 'Modificar Proveedor',
        proveedorInicial: proveedor,
        onGuardar: (proveedorEditado) async {
          final success = await ref
              .read(proveedoresProvider.notifier)
              .actualizarProveedor(proveedorEditado);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proveedor actualizado')),
            );
          }
        },
      ),
    );
  }

  void _eliminarProveedor(
    BuildContext context,
    WidgetRef ref,
    Proveedor proveedor,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar a "${proveedor.razonSocial}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(proveedoresProvider.notifier)
                  .eliminarProveedor(proveedor.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ref.read(proveedorSeleccionadoProvider.notifier).state = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Proveedor eliminado')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedoresState = ref.watch(proveedoresProvider);
    final proveedorSeleccionado = ref.watch(proveedorSeleccionadoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: proveedoresState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : proveedoresState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${proveedoresState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : proveedoresState.proveedores.isEmpty
                ? const Center(child: Text('No hay proveedores registrados'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Razón Social')),
                      DataColumn(label: Text('RFC')),
                      DataColumn(label: Text('Dirección')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Correo Electrónico')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: proveedoresState.proveedores.map((proveedor) {
                      final isSelected =
                          proveedorSeleccionado?.id == proveedor.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref
                              .read(proveedorSeleccionadoProvider.notifier)
                              .state = isSelected
                              ? null
                              : proveedor;
                        },
                        cells: [
                          DataCell(
                            Text(
                              proveedor.razonSocial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(proveedor.rfc ?? '-')),
                          DataCell(Text(proveedor.direccion ?? '-')),
                          DataCell(Text(proveedor.telefono ?? '-')),
                          DataCell(Text(proveedor.correoElectronico ?? '-')),
                          DataCell(
                            Text(
                              proveedor.fechaModificacion != null
                                  ? '${proveedor.fechaModificacion!.day}/${proveedor.fechaModificacion!.month}/${proveedor.fechaModificacion!.year}'
                                  : '-',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Boton(
                  icon: Icons.add,
                  label: "Nuevo Proveedor",
                  onPressed: () => _agregarProveedor(context, ref),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (proveedorSeleccionado != null)
                      _modificarProveedor(context, ref, proveedorSeleccionado);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (proveedorSeleccionado != null)
                      _eliminarProveedor(context, ref, proveedorSeleccionado);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(proveedoresProvider.notifier).recargar();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
