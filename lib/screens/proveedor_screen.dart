import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/proveedor_model.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_proveedor.dart';

final proveedoresSeleccionadosProvider = StateProvider<List<Proveedor>>((ref) => []);

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

  void _eliminarProveedores(
    BuildContext context,
    WidgetRef ref,
    List<Proveedor> proveedores,
  ) {
    final esMultiple = proveedores.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar los ${proveedores.length} proveedores seleccionados?'
        : '¿Eliminar a "${proveedores.first.razonSocial}"?';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('$mensaje\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              int eliminados = 0;
              for (final proveedor in proveedores) {
                final success = await ref
                    .read(proveedoresProvider.notifier)
                    .eliminarProveedor(proveedor.id);
                if (success) eliminados++;
              }
              if (context.mounted) {
                ref.read(proveedoresSeleccionadosProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminados proveedores eliminados exitosamente'
                          : 'Proveedor eliminado',
                    ),
                  ),
                );
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
    final proveedoresSeleccionados = ref.watch(proveedoresSeleccionadosProvider);

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
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(proveedoresSeleccionadosProvider.notifier).state =
                            List.from(proveedoresState.proveedores);
                      } else {
                        ref.read(proveedoresSeleccionadosProvider.notifier).state = [];
                      }
                    },
                    columns: const [
                      DataColumn(label: Text('Razón Social')),
                      DataColumn(label: Text('RFC')),
                      DataColumn(label: Text('Dirección')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Correo Electrónico')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: proveedoresState.proveedores.map((proveedor) {
                      final isSelected = proveedoresSeleccionados.any((p) => p.id == proveedor.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<Proveedor>.from(
                            ref.read(proveedoresSeleccionadosProvider),
                          );
                          if (selected == true) {
                            actual.add(proveedor);
                          } else {
                            actual.removeWhere((p) => p.id == proveedor.id);
                          }
                          ref.read(proveedoresSeleccionadosProvider.notifier).state = actual;
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            color: Colors.grey.shade200,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
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
                    if (proveedoresSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un proveedor para modificar')),
                      );
                      return;
                    }
                    if (proveedoresSeleccionados.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar un proveedor a la vez')),
                      );
                      return;
                    }
                    _modificarProveedor(context, ref, proveedoresSeleccionados.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (proveedoresSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos un proveedor para eliminar')),
                      );
                      return;
                    }
                    _eliminarProveedores(context, ref, proveedoresSeleccionados);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(proveedoresProvider.notifier).recargar();
                    ref.read(proveedoresSeleccionadosProvider.notifier).state = [];
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
