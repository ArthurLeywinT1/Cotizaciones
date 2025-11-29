import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/extra_model.dart';
import '../providers/extra_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_extra.dart';

class ExtraScreen extends ConsumerWidget {
  const ExtraScreen({super.key});

  void _abrirModal(BuildContext context, WidgetRef ref, Extra? extra) {
    showDialog(
      context: context,
      builder: (context) => ModalExtra(
        titulo: extra == null ? 'Nuevo Extra' : 'Modificar Extra',
        extraInicial: extra,
        onGuardar: (nuevoExtra) async {
          bool success;
          if (extra == null) {
            success = await ref
                .read(extrasProvider.notifier)
                .crearExtra(nuevoExtra);
          } else {
            success = await ref
                .read(extrasProvider.notifier)
                .actualizarExtra(nuevoExtra);
          }

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  extra == null ? 'Extra creado' : 'Extra actualizado',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _eliminar(BuildContext context, WidgetRef ref, Extra extra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar el acabado "${extra.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(extrasProvider.notifier)
                  .eliminarExtra(extra.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ref.read(extraSeleccionadoProvider.notifier).state = null;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Eliminado')));
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
    final extrasState = ref.watch(extrasProvider);
    final seleccionado = ref.watch(extraSeleccionadoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: extrasState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : extrasState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${extrasState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : extrasState.extras.isEmpty
                ? const Center(child: Text('No hay extras registrados'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Costo cm²')),
                      DataColumn(label: Text('Costo Fijo')),
                      DataColumn(label: Text('Costo Min. Total')),
                      DataColumn(label: Text('Costo Fijo')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: extrasState.extras.map((e) {
                      final isSelected = seleccionado?.id == e.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref.read(extraSeleccionadoProvider.notifier).state =
                              isSelected ? null : e;
                        },
                        cells: [
                          DataCell(
                            Text(
                              e.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(e.costoCm2 != null ? '\$${e.costoCm2}' : '-'),
                          ),
                          DataCell(
                            Text(
                              e.costoFijo != null ? '\$${e.costoFijo}' : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              e.costoMinimoTotal != null
                                  ? '\$${e.costoMinimoTotal}'
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              e.costoFijo != null ? '\$${e.costoFijo}' : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              e.fechaModificacion != null
                                  ? '${e.fechaModificacion!.day}/${e.fechaModificacion!.month}/${e.fechaModificacion!.year}'
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
                  label: "Nuevo Extra",
                  onPressed: () => _abrirModal(context, ref, null),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (seleccionado != null)
                      _abrirModal(context, ref, seleccionado);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (seleccionado != null)
                      _eliminar(context, ref, seleccionado);
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
