import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/descuento_model.dart';
import '../providers/descuento_provider.dart';
import '../providers/papel_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_descuento.dart';

final descuentosSeleccionadosProvider = StateProvider<List<DescuentoPapel>>((ref) => []);

class DescuentoScreen extends ConsumerWidget {
  const DescuentoScreen({super.key});

  void _agregarDescuento(
    BuildContext context,
    WidgetRef ref,
    DescuentoPapel? descuento,
  ) {
    final listaPapeles = ref.read(papelesProvider).papeles;

    if (listaPapeles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes registrar papeles en el sistema'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ModalDescuento(
        titulo: descuento == null ? 'Nuevo Descuento' : 'Modificar Descuento',
        descuentoInicial: descuento,
        onGuardar: (nuevoDescuento) async {
          bool success;
          if (descuento == null) {
            success = await ref
                .read(descuentosProvider.notifier)
                .crearDescuento(nuevoDescuento);
          } else {
            success = await ref
                .read(descuentosProvider.notifier)
                .actualizarDescuento(nuevoDescuento);
          }

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  descuento == null
                      ? 'Descuento creado'
                      : 'Descuento actualizado',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _eliminarDescuentos(
    BuildContext context,
    WidgetRef ref,
    List<DescuentoPapel> descuentos,
  ) {
    final esMultiple = descuentos.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar los ${descuentos.length} descuentos seleccionados?'
        : '¿Eliminar este descuento?';

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
              for (final d in descuentos) {
                final success = await ref
                    .read(descuentosProvider.notifier)
                    .eliminarDescuento(d.id);
                if (success) eliminados++;
              }
              if (context.mounted) {
                ref.read(descuentosSeleccionadosProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminados descuentos eliminados exitosamente'
                          : 'Descuento eliminado',
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
    final descuentosState = ref.watch(descuentosProvider);
    final papelesState = ref.watch(papelesProvider);
    final descuentosSeleccionados = ref.watch(descuentosSeleccionadosProvider);

    final isLoading = descuentosState.isLoading || papelesState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : descuentosState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${descuentosState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Tabla(
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(descuentosSeleccionadosProvider.notifier).state =
                            List.from(descuentosState.descuentos);
                      } else {
                        ref.read(descuentosSeleccionadosProvider.notifier).state = [];
                      }
                    },
                    columns: const [
                      DataColumn(label: Text('Cantidad Desde')),
                      DataColumn(label: Text('Cantidad Hasta')),
                      DataColumn(label: Text('Descuento (%)')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: descuentosState.descuentos.map((d) {
                      final isSelected = descuentosSeleccionados.any((item) => item.id == d.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<DescuentoPapel>.from(
                            ref.read(descuentosSeleccionadosProvider),
                          );
                          if (selected == true) {
                            actual.add(d);
                          } else {
                            actual.removeWhere((item) => item.id == d.id);
                          }
                          ref.read(descuentosSeleccionadosProvider.notifier).state = actual;
                        },
                        cells: [
                          DataCell(Text(d.cantidadDesde.toString())),
                          DataCell(Text(d.cantidadHasta.toString())),
                          DataCell(
                            Text(
                              '${d.descuento}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              d.fechaModificacion != null
                                  ? '${d.fechaModificacion!.day}/${d.fechaModificacion!.month}/${d.fechaModificacion!.year}'
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
                  label: "Nuevo Descuento",
                  onPressed: () => _agregarDescuento(context, ref, null),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (descuentosSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un descuento para modificar')),
                      );
                      return;
                    }
                    if (descuentosSeleccionados.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar un descuento a la vez')),
                      );
                      return;
                    }
                    _agregarDescuento(context, ref, descuentosSeleccionados.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (descuentosSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos un descuento para eliminar')),
                      );
                      return;
                    }
                    _eliminarDescuentos(context, ref, descuentosSeleccionados);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(descuentosProvider.notifier).recargar();
                    ref.read(descuentosSeleccionadosProvider.notifier).state = [];
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
