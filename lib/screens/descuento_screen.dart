import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/descuento_model.dart';
import '../providers/descuento_provider.dart';
import '../providers/papel_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_descuento.dart';

class DescuentoScreen extends ConsumerWidget {
  const DescuentoScreen({super.key});

  void _abrirModal(
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
        listaPapeles: listaPapeles,
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

  void _eliminar(
    BuildContext context,
    WidgetRef ref,
    DescuentoPapel descuento,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Eliminar este descuento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(descuentosProvider.notifier)
                  .eliminarDescuento(descuento.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ref.read(descuentoSeleccionadoProvider.notifier).state = null;
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

  String _nombrePapel(String id, WidgetRef ref) {
    final papeles = ref.watch(papelesProvider).papeles;
    try {
      return papeles.firstWhere((p) => p.id == id).nombre;
    } catch (e) {
      return 'Papel Desconocido';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descuentosState = ref.watch(descuentosProvider);
    final papelesState = ref.watch(papelesProvider);
    final seleccionado = ref.watch(descuentoSeleccionadoProvider);

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
                    columns: const [
                      DataColumn(label: Text('Papel')),
                      DataColumn(label: Text('Cantidad Desde')),
                      DataColumn(label: Text('Cantidad Hasta')),
                      DataColumn(label: Text('Descuento (%)')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: descuentosState.descuentos.map((d) {
                      final isSelected = seleccionado?.id == d.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref
                              .read(descuentoSeleccionadoProvider.notifier)
                              .state = isSelected
                              ? null
                              : d;
                        },
                        cells: [
                          DataCell(
                            Text(
                              _nombrePapel(d.papelId, ref),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Boton(
                  icon: Icons.add,
                  label: "Nuevo Descuento",
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
