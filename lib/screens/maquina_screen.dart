import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maquina_model.dart';
import '../providers/maquina_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_maquina.dart';

final maquinaSeleccionadoProvider = StateProvider<Maquina?>((ref) => null);

class MaquinaScreen extends ConsumerWidget {
  const MaquinaScreen({super.key});

  void _agregarMaquina(BuildContext context, WidgetRef ref, Maquina? maquina) {
    showDialog(
      context: context,
      builder: (context) => ModalMaquina(
        titulo: maquina == null ? 'Nueva Máquina' : 'Modificar Máquina',
        maquinaInicial: maquina,
        onGuardar: (nuevaMaquina) async {
          bool success;
          if (maquina == null) {
            success = await ref
                .read(maquinasProvider.notifier)
                .crearMaquina(nuevaMaquina);
          } else {
            success = await ref
                .read(maquinasProvider.notifier)
                .actualizarMaquina(nuevaMaquina);
          }

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  maquina == null ? 'Máquina creada' : 'Máquina actualizada',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _eliminar(BuildContext context, WidgetRef ref, Maquina maquina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar la máquina "${maquina.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(maquinasProvider.notifier)
                  .eliminarMaquina(maquina.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ref.read(maquinaSeleccionadoProvider.notifier).state = null;
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
    final maquinasState = ref.watch(maquinasProvider);
    final seleccionado = ref.watch(maquinaSeleccionadoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: maquinasState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : maquinasState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${maquinasState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : maquinasState.maquinas.isEmpty
                ? const Center(child: Text('No hay máquinas registradas'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Tintas')),
                      DataColumn(label: Text('Tamaños')),
                      DataColumn(label: Text('Formato Max.')),
                      DataColumn(label: Text('Costo 615x724')),
                      DataColumn(label: Text('Costo 790x1030')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: maquinasState.maquinas.map((m) {
                      final isSelected = seleccionado?.id == m.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref.read(maquinaSeleccionadoProvider.notifier).state =
                              isSelected ? null : m;
                        },
                        cells: [
                          DataCell(
                            Text(
                              m.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(m.cantidadTintas?.toString() ?? '-')),
                          DataCell(Text(m.cantidadTamanos?.toString() ?? '-')),
                          DataCell(Text(m.tamanoMaximo)),
                          DataCell(
                            Text('\$${m.costoPlaca615x724.toStringAsFixed(2)}'),
                          ),
                          DataCell(
                            Text(
                              '\$${m.costoPlaca790x1030.toStringAsFixed(2)}',
                            ),
                          ),
                          DataCell(
                            Text(
                              m.fechaModificacion != null
                                  ? '${m.fechaModificacion!.day}/${m.fechaModificacion!.month}/${m.fechaModificacion!.year}'
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
                  label: "Nueva Máquina",
                  onPressed: () => _agregarMaquina(context, ref, null),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (seleccionado != null) {
                      _agregarMaquina(context, ref, seleccionado);
                    }
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (seleccionado != null) {
                      _eliminar(context, ref, seleccionado);
                    }
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(maquinasProvider.notifier).recargar();
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
