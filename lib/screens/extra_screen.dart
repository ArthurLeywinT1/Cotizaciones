import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/extra_model.dart';
import '../providers/extra_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_extra.dart';

final extrasSeleccionadosProvider = StateProvider<List<Extra>>((ref) => []);

class ExtraScreen extends ConsumerWidget {
  const ExtraScreen({super.key});

  void _agregarExtra(BuildContext context, WidgetRef ref, Extra? extra) {
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

  void _eliminarExtras(BuildContext context, WidgetRef ref, List<Extra> extras) {
    final esMultiple = extras.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar los ${extras.length} acabados seleccionados?'
        : '¿Eliminar el acabado "${extras.first.nombre}"?';

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
              for (final extra in extras) {
                final success = await ref
                    .read(extrasProvider.notifier)
                    .eliminarExtra(extra.id);
                if (success) eliminados++;
              }
              if (context.mounted) {
                ref.read(extrasSeleccionadosProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminados acabados eliminados exitosamente'
                          : 'Acabado eliminado',
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
    final extrasState = ref.watch(extrasProvider);
    final extrasSeleccionados = ref.watch(extrasSeleccionadosProvider);

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
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(extrasSeleccionadosProvider.notifier).state =
                            List.from(extrasState.extras);
                      } else {
                        ref.read(extrasSeleccionadosProvider.notifier).state = [];
                      }
                    },
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Costo cm²')),
                      DataColumn(label: Text('Costo Fijo')),
                      DataColumn(label: Text('Costo Min. Total')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: extrasState.extras.map((e) {
                      final isSelected = extrasSeleccionados.any((item) => item.id == e.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<Extra>.from(
                            ref.read(extrasSeleccionadosProvider),
                          );
                          if (selected == true) {
                            actual.add(e);
                          } else {
                            actual.removeWhere((item) => item.id == e.id);
                          }
                          ref.read(extrasSeleccionadosProvider.notifier).state = actual;
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
                  label: "Nuevo Extra",
                  onPressed: () => _agregarExtra(context, ref, null),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (extrasSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un acabado para modificar')),
                      );
                      return;
                    }
                    if (extrasSeleccionados.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar un acabado a la vez')),
                      );
                      return;
                    }
                    _agregarExtra(context, ref, extrasSeleccionados.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (extrasSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos un acabado para eliminar')),
                      );
                      return;
                    }
                    _eliminarExtras(context, ref, extrasSeleccionados);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(extrasProvider.notifier).recargar();
                    ref.read(extrasSeleccionadosProvider.notifier).state = [];
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
