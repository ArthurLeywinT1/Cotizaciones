import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../orden de trabajo/iniciarOrden.dart';
import '../orden de trabajo/ordenTrabajo.dart';
import '../providers/catalogoOT_provider.dart';
import '../screens/modals/incidente_admin.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';

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
                      DataColumn(label: Text('Incidente Adq.')),
                      DataColumn(label: Text('Inicio Adq.')),
                      DataColumn(label: Text('Fin Adq.')),

                      DataColumn(label: Text('Estatus Diseño')),
                      DataColumn(label: Text('Incidente Diseño')),
                      DataColumn(label: Text('Inicio Diseño')),
                      DataColumn(label: Text('Fin Diseño')),

                      DataColumn(label: Text('Estatus Offset')),
                      DataColumn(label: Text('Incidente Offset')),
                      DataColumn(label: Text('Inicio Offset')),
                      DataColumn(label: Text('Fin Offset')),

                      DataColumn(label: Text('Estatus Corte')),
                      DataColumn(label: Text('Incidente Corte')),
                      DataColumn(label: Text('Inicio Corte')),
                      DataColumn(label: Text('Fin Corte')),

                      DataColumn(label: Text('Estatus Laminado')),
                      DataColumn(label: Text('Incidente Laminado')),
                      DataColumn(label: Text('Inicio Laminado')),
                      DataColumn(label: Text('Fin Laminado')),

                      DataColumn(label: Text('Estatus Suaje')),
                      DataColumn(label: Text('Incidente Suaje')),
                      DataColumn(label: Text('Inicio Suaje')),
                      DataColumn(label: Text('Fin Suaje')),

                      DataColumn(label: Text('Estatus Serigrafía')),
                      DataColumn(label: Text('Incidente Serigrafía')),
                      DataColumn(label: Text('Inicio Serigrafía')),
                      DataColumn(label: Text('Fin Serigrafía')),

                      DataColumn(label: Text('Estatus Grabado')),
                      DataColumn(label: Text('Incidente Grabado')),
                      DataColumn(label: Text('Inicio Grabado')),
                      DataColumn(label: Text('Fin Grabado')),

                      DataColumn(label: Text('Estatus Acabado')),
                      DataColumn(label: Text('Incidente Acabado')),
                      DataColumn(label: Text('Inicio Acabado')),
                      DataColumn(label: Text('Fin Acabado')),

                      DataColumn(label: Text('Estatus Barniz')),
                      DataColumn(label: Text('Incidente Barniz')),
                      DataColumn(label: Text('Inicio Barniz')),
                      DataColumn(label: Text('Fin Barniz')),

                      DataColumn(label: Text('Estatus Embalaje')),
                      DataColumn(label: Text('Incidente Embalaje')),
                      DataColumn(label: Text('Inicio Embalaje')),
                      DataColumn(label: Text('Fin Embalaje')),

                      DataColumn(label: Text('Estatus Logística')),
                      DataColumn(label: Text('Incidente Logística')),
                      DataColumn(label: Text('Inicio Logística')),
                      DataColumn(label: Text('Fin Logística')),
                    ],
                    rows: otState.ordenes.map((orden) {
                      final isSelected =
                          otSeleccionada != null &&
                          otSeleccionada['ot_id'] == orden['ot_id'];

                      String formatearFecha(dynamic fecha) {
                        if (fecha == null ||
                            fecha.toString().isEmpty ||
                            fecha.toString() == 'null') {
                          return '-';
                        }
                        if (fecha is DateTime) {
                          return DateFormat('dd/MM/yyyy\nHH:mm')
                              .format(fecha.toLocal());
                        }
                        try {
                          final parsed =
                              DateTime.parse(fecha.toString()).toLocal();
                          return DateFormat('dd/MM/yyyy\nHH:mm').format(parsed);
                        } catch (_) {
                          return fecha.toString();
                        }
                      }

                      Widget widgetEstatus(String? estatus) {
                        final val = estatus ?? 'Pendiente';
                        Color textColor = Colors.grey.shade700;
                        Color bgColor = Colors.grey.shade100;
                        Color borderColor = Colors.grey.shade300;

                        if (val == 'Inicio') {
                          textColor = Colors.blue.shade700;
                          bgColor = Colors.blue.shade50;
                          borderColor = Colors.blue.shade200;
                        } else if (val == 'Fin') {
                          textColor = Colors.green.shade700;
                          bgColor = Colors.green.shade50;
                          borderColor = Colors.green.shade200;
                        } else if (val == 'Incidente') {
                          textColor = Colors.orange.shade800;
                          bgColor = Colors.orange.shade50;
                          borderColor = Colors.orange.shade300;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            val,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      Widget widgetIncidente(String? estatus) {
                        final val = estatus ?? '-';
                        if (val == '-' || val.isEmpty) {
                          return const Text(
                            '-',
                            style: TextStyle(color: Colors.black87),
                          );
                        }

                        Color textColor = Colors.black87;
                        Color bgColor = Colors.grey.shade100;
                        Color borderColor = Colors.grey.shade300;

                        if (val == 'Pendiente') {
                          textColor = Colors.red.shade700;
                          bgColor = Colors.red.shade50;
                          borderColor = Colors.red.shade200;
                        } else if (val == 'Resuelto') {
                          textColor = Colors.green.shade700;
                          bgColor = Colors.green.shade50;
                          borderColor = Colors.green.shade200;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            val,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref.read(otSeleccionadaProvider.notifier).state =
                              isSelected ? null : orden;
                        },
                        cells: [
                          DataCell(Text(orden['folio'] ?? '-')),
                          DataCell(
                            Text(
                              orden['no_orden']?.toString().isNotEmpty == true
                                  ? orden['no_orden'].toString()
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['fecha_creacion'])),
                          ),
                          DataCell(Text(orden['cliente'] ?? '-')),
                          DataCell(Text(orden['descripcion'] ?? '-')),
                          DataCell(
                            Text(formatearFecha(orden['fecha_entrega'])),
                          ),

                          DataCell(
                            widgetEstatus(orden['estatus_adquisiciones']),
                          ),
                          DataCell(
                            widgetIncidente(orden['incidente_adquisiciones']),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['inicio_adquisiciones'])),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['fin_adquisiciones'])),
                          ),

                          DataCell(widgetEstatus(orden['estatus_diseno'])),
                          DataCell(widgetIncidente(orden['incidente_diseno'])),
                          DataCell(
                            Text(formatearFecha(orden['inicio_diseno'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_diseno']))),

                          DataCell(widgetEstatus(orden['estatus_offset'])),
                          DataCell(widgetIncidente(orden['incidente_offset'])),
                          DataCell(
                            Text(formatearFecha(orden['inicio_offset'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_offset']))),

                          DataCell(widgetEstatus(orden['estatus_corte'])),
                          DataCell(widgetIncidente(orden['incidente_corte'])),
                          DataCell(Text(formatearFecha(orden['inicio_corte']))),
                          DataCell(Text(formatearFecha(orden['fin_corte']))),

                          DataCell(widgetEstatus(orden['estatus_laminado'])),
                          DataCell(
                            widgetIncidente(orden['incidente_laminado']),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['inicio_laminado'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_laminado']))),

                          DataCell(widgetEstatus(orden['estatus_suaje'])),
                          DataCell(widgetIncidente(orden['incidente_suaje'])),
                          DataCell(Text(formatearFecha(orden['inicio_suaje']))),
                          DataCell(Text(formatearFecha(orden['fin_suaje']))),

                          DataCell(widgetEstatus(orden['estatus_serigrafia'])),
                          DataCell(
                            widgetIncidente(orden['incidente_serigrafia']),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['inicio_serigrafia'])),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['fin_serigrafia'])),
                          ),

                          DataCell(widgetEstatus(orden['estatus_grabado'])),
                          DataCell(widgetIncidente(orden['incidente_grabado'])),
                          DataCell(
                            Text(formatearFecha(orden['inicio_grabado'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_grabado']))),

                          DataCell(widgetEstatus(orden['estatus_acabado'])),
                          DataCell(widgetIncidente(orden['incidente_acabado'])),
                          DataCell(
                            Text(formatearFecha(orden['inicio_acabado'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_acabado']))),

                          DataCell(widgetEstatus(orden['estatus_barniz'])),
                          DataCell(widgetIncidente(orden['incidente_barniz'])),
                          DataCell(
                            Text(formatearFecha(orden['inicio_barniz'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_barniz']))),

                          DataCell(widgetEstatus(orden['estatus_embalaje'])),
                          DataCell(
                            widgetIncidente(orden['incidente_embalaje']),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['inicio_embalaje'])),
                          ),
                          DataCell(Text(formatearFecha(orden['fin_embalaje']))),

                          DataCell(widgetEstatus(orden['estatus_logistica'])),
                          DataCell(
                            widgetIncidente(orden['incidente_logistica']),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['inicio_logistica'])),
                          ),
                          DataCell(
                            Text(formatearFecha(orden['fin_logistica'])),
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
                  icon: Icons.play_circle_fill,
                  label: "Iniciar Orden",
                  onPressed: () {
                    if (otSeleccionada != null &&
                        otSeleccionada['cotizacion_id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProduccionScreen(
                            cotizacionId: otSeleccionada['cotizacion_id'],
                            area: 'admin',
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
                  icon: Icons.warning_amber_rounded,
                  label: "Incidentes",
                  isWarning: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const BandejaIncidentesDialog(),
                    ).then((_) {
                      ref.read(catalogoOTProvider.notifier).cargarOrdenes();
                    });
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
