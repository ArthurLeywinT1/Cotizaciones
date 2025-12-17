import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/papel_model.dart';
import '../providers/papel_provider.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_papel.dart';

class PapelScreen extends ConsumerWidget {
  const PapelScreen({super.key});

  void _agregarPapel(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> proveedores,
  ) {
    showDialog(
      context: context,
      builder: (context) => ModalPapel(
        titulo: 'Nuevo Papel',
        listaProveedores: ref.read(proveedoresProvider).proveedores,
        onGuardar: (papelNuevo) async {
          final success = await ref
              .read(papelesProvider.notifier)
              .crearPapel(papelNuevo);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Papel creado')));
          }
        },
      ),
    );
  }

  void _modificarPapel(BuildContext context, WidgetRef ref, Papel papel) {
    showDialog(
      context: context,
      builder: (context) => ModalPapel(
        titulo: 'Modificar Papel',
        papelInicial: papel,
        listaProveedores: ref.read(proveedoresProvider).proveedores,
        onGuardar: (papelEditado) async {
          final success = await ref
              .read(papelesProvider.notifier)
              .actualizarPapel(papelEditado);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Papel actualizado')));
          }
        },
      ),
    );
  }

  void _eliminarPapel(BuildContext context, WidgetRef ref, Papel papel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar a "${papel.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(papelesProvider.notifier)
                  .eliminarPapel(papel.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ref.read(papelSeleccionadoProvider.notifier).state = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Papel eliminado')),
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

  String _obtenerNombreProveedor(String? id, WidgetRef ref) {
    if (id == null) return '-';
    final lista = ref.read(proveedoresProvider).proveedores;
    try {
      return lista.firstWhere((p) => p.id == id).razonSocial;
    } catch (e) {
      return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papelesState = ref.watch(papelesProvider);
    final proveedoresState = ref.watch(proveedoresProvider);
    final papelSeleccionado = ref.watch(papelSeleccionadoProvider);

    final isLoading = papelesState.isLoading || proveedoresState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : papelesState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${papelesState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : papelesState.papeles.isEmpty
                ? const Center(child: Text('No hay papeles registrados'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Nombre Papel')),
                      DataColumn(label: Text('Tipo')),
                      DataColumn(label: Text('Medidas')),
                      DataColumn(label: Text('Peso')),
                      DataColumn(label: Text('Costo')),
                      DataColumn(label: Text('Proveedor')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: papelesState.papeles.map((papel) {
                      final isSelected = papelSeleccionado?.id == papel.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref.read(papelSeleccionadoProvider.notifier).state =
                              isSelected ? null : papel;
                        },
                        cells: [
                          DataCell(
                            Text(
                              papel.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(papel.tipo ?? '-')),
                          DataCell(Text(papel.medidas)),
                          DataCell(
                            Text(papel.peso != null ? '${papel.peso} g' : '-'),
                          ),
                          DataCell(
                            Text('\$${papel.costoMillar.toStringAsFixed(2)}'),
                          ),
                          DataCell(
                            Text(
                              _obtenerNombreProveedor(papel.proveedorId, ref),
                            ),
                          ),
                          DataCell(
                            Text(
                              papel.fechaModificacion != null
                                  ? '${papel.fechaModificacion!.day}/${papel.fechaModificacion!.month}/${papel.fechaModificacion!.year}'
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
                  label: "Nuevo Papel",
                  onPressed: () => _agregarPapel(context, ref, []),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (papelSeleccionado != null) {
                      _modificarPapel(context, ref, papelSeleccionado);
                    }
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (papelSeleccionado != null) {
                      _eliminarPapel(context, ref, papelSeleccionado);
                    }
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(papelesProvider.notifier).recargar();
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
