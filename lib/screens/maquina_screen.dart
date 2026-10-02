import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maquina_model.dart';
import '../providers/maquina_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_maquina.dart';

final maquinasSeleccionadasProvider = StateProvider<List<Maquina>>((ref) => []);

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

  void _eliminarMaquinas(
    BuildContext context,
    WidgetRef ref,
    List<Maquina> maquinas,
  ) {
    final esMultiple = maquinas.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar las ${maquinas.length} máquinas seleccionadas?'
        : '¿Eliminar la máquina "${maquinas.first.nombre}"?';

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
              int eliminadas = 0;
              for (final m in maquinas) {
                final success = await ref
                    .read(maquinasProvider.notifier)
                    .eliminarMaquina(m.id);
                if (success) eliminadas++;
              }
              if (context.mounted) {
                ref.read(maquinasSeleccionadasProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminadas máquinas eliminadas exitosamente'
                          : 'Máquina eliminada exitosamente',
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
    final maquinasState = ref.watch(maquinasProvider);
    final maquinasSeleccionadas = ref.watch(maquinasSeleccionadasProvider);

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
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(maquinasSeleccionadasProvider.notifier).state =
                            List.from(maquinasState.maquinas);
                      } else {
                        ref.read(maquinasSeleccionadasProvider.notifier).state = [];
                      }
                    },
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
                      final isSelected = maquinasSeleccionadas.any((item) => item.id == m.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<Maquina>.from(
                            ref.read(maquinasSeleccionadasProvider),
                          );
                          if (selected == true) {
                            actual.add(m);
                          } else {
                            actual.removeWhere((item) => item.id == m.id);
                          }
                          ref.read(maquinasSeleccionadasProvider.notifier).state = actual;
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
                  label: "Nueva Máquina",
                  onPressed: () => _agregarMaquina(context, ref, null),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (maquinasSeleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona una máquina para modificar')),
                      );
                      return;
                    }
                    if (maquinasSeleccionadas.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar una máquina a la vez')),
                      );
                      return;
                    }
                    _agregarMaquina(context, ref, maquinasSeleccionadas.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (maquinasSeleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos una máquina para eliminar')),
                      );
                      return;
                    }
                    _eliminarMaquinas(context, ref, maquinasSeleccionadas);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(maquinasProvider.notifier).recargar();
                    ref.read(maquinasSeleccionadasProvider.notifier).state = [];
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
