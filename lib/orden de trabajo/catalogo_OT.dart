import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogoOT_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import '../orden de trabajo/ordenTrabajo.dart';

class CatalogoOTScreen extends ConsumerWidget {
  const CatalogoOTScreen({super.key});

  void _eliminarOrden(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> orden,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Eliminar la Orden de Trabajo ligada al Folio "${orden['folio'] ?? 'S/F'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(catalogoOTProvider.notifier)
                  .eliminarOrden(orden['ot_id']);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ref.read(otSeleccionadaProvider.notifier).state = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Orden de Trabajo eliminada')),
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
    final otState = ref.watch(catalogoOTProvider);
    final otSeleccionada = ref.watch(otSeleccionadaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: otState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : otState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${otState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : otState.ordenes.isEmpty
                ? const Center(
                    child: Text('No hay Órdenes de Trabajo registradas'),
                  )
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Folio')),
                      DataColumn(label: Text('No. Orden')),
                      DataColumn(label: Text('Fecha Creación')),
                      DataColumn(label: Text('Cliente')),
                      DataColumn(label: Text('Descripción')),
                      DataColumn(label: Text('Fecha Entrega')),

                      DataColumn(label: Text('Estatus Adq.')),
                      DataColumn(label: Text('Inicio Adq.')),
                      DataColumn(label: Text('Fin Adq.')),

                      DataColumn(label: Text('Estatus PrePrensa')),
                      DataColumn(label: Text('Inicio PrePrensa')),
                      DataColumn(label: Text('Fin PrePrensa')),

                      DataColumn(label: Text('Estatus Offset')),
                      DataColumn(label: Text('Inicio Offset')),
                      DataColumn(label: Text('Fin Offset')),

                      DataColumn(label: Text('Estatus Corte')),
                      DataColumn(label: Text('Inicio Corte')),
                      DataColumn(label: Text('Fin Corte')),

                      DataColumn(label: Text('Estatus Laminado')),
                      DataColumn(label: Text('Inicio Laminado')),
                      DataColumn(label: Text('Fin Laminado')),

                      DataColumn(label: Text('Estatus Suaje')),
                      DataColumn(label: Text('Inicio Suaje')),
                      DataColumn(label: Text('Fin Suaje')),

                      DataColumn(label: Text('Estatus Acabado')),
                      DataColumn(label: Text('Inicio Acabado')),
                      DataColumn(label: Text('Fin Acabado')),

                      DataColumn(label: Text('Estatus Embalaje')),
                      DataColumn(label: Text('Inicio Embalaje')),
                      DataColumn(label: Text('Fin Embalaje')),

                      DataColumn(label: Text('Estatus Logística')),
                      DataColumn(label: Text('Inicio Logística')),
                      DataColumn(label: Text('Fin Logística')),
                    ],
                    rows: otState.ordenes.map((orden) {
                      final isSelected =
                          otSeleccionada != null &&
                          otSeleccionada['ot_id'] == orden['ot_id'];

                      String formatearFecha(dynamic fecha) {
                        if (fecha == null) return '-';
                        if (fecha is DateTime)
                          return '${fecha.day}/${fecha.month}/${fecha.year}';
                        return fecha.toString().split(' ')[0];
                      }

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref.read(otSeleccionadaProvider.notifier).state =
                              isSelected ? null : orden;
                        },
                        cells: [
                          DataCell(Text(orden['folio'] ?? '-')),
                          DataCell(Text(orden['no_orden'] ?? '')),
                          DataCell(
                            Text(formatearFecha(orden['fecha_creacion'])),
                          ),
                          DataCell(Text(orden['cliente'] ?? '-')),
                          DataCell(Text(orden['descripcion'] ?? '-')),
                          DataCell(Text(orden['fecha_entrega'] ?? '')),

                          DataCell(Text(orden['estatus_adquisiciones'] ?? '-')),
                          DataCell(Text(orden['inicio_adquisiciones'] ?? '-')),
                          DataCell(Text(orden['fin_adquisiciones'] ?? '-')),

                          DataCell(Text(orden['estatus_preprensa'] ?? '-')),
                          DataCell(Text(orden['inicio_preprensa'] ?? '-')),
                          DataCell(Text(orden['fin_preprensa'] ?? '-')),

                          DataCell(Text(orden['estatus_offset'] ?? '-')),
                          DataCell(Text(orden['inicio_offset'] ?? '-')),
                          DataCell(Text(orden['fin_offset'] ?? '-')),

                          DataCell(Text(orden['estatus_corte'] ?? '-')),
                          DataCell(Text(orden['inicio_corte'] ?? '-')),
                          DataCell(Text(orden['fin_corte'] ?? '-')),

                          DataCell(Text(orden['estatus_laminado'] ?? '-')),
                          DataCell(Text(orden['inicio_laminado'] ?? '-')),
                          DataCell(Text(orden['fin_laminado'] ?? '-')),

                          DataCell(Text(orden['estatus_suaje'] ?? '-')),
                          DataCell(Text(orden['inicio_suaje'] ?? '-')),
                          DataCell(Text(orden['fin_suaje'] ?? '-')),

                          DataCell(Text(orden['estatus_acabado'] ?? '-')),
                          DataCell(Text(orden['inicio_acabado'] ?? '-')),
                          DataCell(Text(orden['fin_acabado'] ?? '-')),

                          DataCell(Text(orden['estatus_embalaje'] ?? '-')),
                          DataCell(Text(orden['inicio_embalaje'] ?? '-')),
                          DataCell(Text(orden['fin_embalaje'] ?? '-')),

                          DataCell(Text(orden['estatus_logistica'] ?? '-')),
                          DataCell(Text(orden['inicio_logistica'] ?? '-')),
                          DataCell(Text(orden['fin_logistica'] ?? '-')),
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
                  icon: Icons.edit,
                  label: "Ver/Editar Orden",
                  onPressed: () {
                    if (otSeleccionada != null &&
                        otSeleccionada['cotizacion_id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdenTrabajoScreen(
                            cotizacionId: otSeleccionada['cotizacion_id'],
                          ),
                        ),
                      ).then((_) {
                        ref.read(catalogoOTProvider.notifier).cargarOrdenes();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una Orden de Trabajo primero',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (otSeleccionada != null) {
                      _eliminarOrden(context, ref, otSeleccionada);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una Orden de Trabajo primero',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(catalogoOTProvider.notifier).cargarOrdenes();
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
