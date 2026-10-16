import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/papel_model.dart';
import '../providers/papel_provider.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_papel.dart';
import '../utils/formatters.dart';

final papelesSeleccionadosProvider = StateProvider<List<Papel>>((ref) => []);

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

  void _eliminarPapeles(BuildContext context, WidgetRef ref, List<Papel> papeles) {
    final esMultiple = papeles.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar los ${papeles.length} papeles seleccionados?'
        : '¿Eliminar a "${papeles.first.nombre}"?';

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
              for (final papel in papeles) {
                final success = await ref
                    .read(papelesProvider.notifier)
                    .eliminarPapel(papel.id);
                if (success) eliminados++;
              }
              if (context.mounted) {
                ref.read(papelesSeleccionadosProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminados papeles eliminados exitosamente'
                          : 'Papel eliminado',
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
    final papelesSeleccionados = ref.watch(papelesSeleccionadosProvider);

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
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(papelesSeleccionadosProvider.notifier).state =
                            List.from(papelesState.papeles);
                      } else {
                        ref.read(papelesSeleccionadosProvider.notifier).state = [];
                      }
                    },
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
                      final isSelected = papelesSeleccionados.any((p) => p.id == papel.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<Papel>.from(ref.read(papelesSeleccionadosProvider));
                          if (selected == true) {
                            actual.add(papel);
                          } else {
                            actual.removeWhere((p) => p.id == papel.id);
                          }
                          ref.read(papelesSeleccionadosProvider.notifier).state = actual;
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
                            Text(Formatters.moneda(papel.costoMillar)),
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
                  label: "Nuevo Papel",
                  onPressed: () => _agregarPapel(context, ref, []),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (papelesSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un papel para modificar')),
                      );
                      return;
                    }
                    if (papelesSeleccionados.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar un papel a la vez')),
                      );
                      return;
                    }
                    _modificarPapel(context, ref, papelesSeleccionados.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (papelesSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos un papel para eliminar')),
                      );
                      return;
                    }
                    _eliminarPapeles(context, ref, papelesSeleccionados);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(papelesProvider.notifier).recargar();
                    ref.read(papelesSeleccionadosProvider.notifier).state = [];
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
