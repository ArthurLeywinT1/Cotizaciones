import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/operario_provider.dart';
import '../../providers/incidente_provider.dart';
import '../../widgets/tabla.dart';
import '../../widgets/boton.dart';
import '../../orden de trabajo/iniciarOrden.dart';
import '../modals/incidente.dart';

class TablaOperarioScreen extends ConsumerStatefulWidget {
  final String area;
  final bool verHistorial;

  const TablaOperarioScreen({
    super.key,
    required this.area,
    required this.verHistorial,
  });

  @override
  ConsumerState<TablaOperarioScreen> createState() =>
      _TablaOperarioScreenState();
}

class _TablaOperarioScreenState extends ConsumerState<TablaOperarioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(operarioOTProvider.notifier)
          .cargarOrdenesOperario(widget.area, widget.verHistorial);
    });
  }

  @override
  void didUpdateWidget(covariant TablaOperarioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verHistorial != widget.verHistorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(otOperarioSeleccionadaProvider.notifier).state = null;
        ref
            .read(operarioOTProvider.notifier)
            .cargarOrdenesOperario(widget.area, widget.verHistorial);
      });
    }
  }

  void _mostrarModalIncidente(
    BuildContext context,
    Map<String, dynamic> ordenSeleccionada,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Incidente - Folio: ${ordenSeleccionada['folio']}"),
          content: SizedBox(
            width: 400,
            child: IncidenteModalContent(
              ordenTrabajoId: ordenSeleccionada['ot_id'],
              area: widget.area,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(incidenteProvider.notifier).limpiarIncidenteActual();
                Navigator.of(context).pop();
                ref
                    .read(operarioOTProvider.notifier)
                    .cargarOrdenesOperario(widget.area, widget.verHistorial);
              },
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operarioOTProvider);
    final seleccionada = ref.watch(otOperarioSeleccionadaProvider);

    Widget contenidoTabla;

    if (state.isLoading) {
      contenidoTabla = const Center(child: CircularProgressIndicator());
    } else if (state.error.isNotEmpty) {
      contenidoTabla = Center(
        child: Text(
          "Error: ${state.error}",
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (state.ordenes.isEmpty) {
      contenidoTabla = Center(
        child: Text(
          widget.verHistorial
              ? "No hay historial de órdenes terminadas."
              : "¡Excelente! No hay órdenes pendientes.",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      contenidoTabla = Tabla(
        columns: const [
          DataColumn(label: Text('Folio')),
          DataColumn(label: Text('No. Orden')),
          DataColumn(label: Text('Fecha Creación')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Fecha Entrega')),
          DataColumn(label: Text('Estatus del Área')),
          DataColumn(label: Text('Incidente')),
        ],
        rows: state.ordenes.map((orden) {
          final isSelected =
              seleccionada != null && seleccionada['ot_id'] == orden['ot_id'];

          String fFecha(dynamic f) {
            if (f == null || f.toString().isEmpty) return '-';
            if (f is DateTime) {
              return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
            }
            try {
              final parsed = DateTime.parse(f.toString());
              return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
            } catch (e) {
              return f.toString().split(' ')[0];
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  fontSize: 12,
                ),
              ),
            );
          }

          Widget widgetIncidente(String? estatus) {
            final val = estatus ?? '-';
            if (val == '-') {
              return const Text('-', style: TextStyle(color: Colors.black87));
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  fontSize: 12,
                ),
              ),
            );
          }

          return DataRow(
            selected: isSelected,
            onSelectChanged: (_) {
              ref.read(otOperarioSeleccionadaProvider.notifier).state =
                  isSelected ? null : orden;
            },
            cells: [
              DataCell(Text(orden['folio'] ?? '-')),
              DataCell(Text(orden['no_orden']?.toString() ?? '-')),
              DataCell(Text(fFecha(orden['fecha_creacion']))),
              DataCell(Text(orden['cliente'] ?? '-')),
              DataCell(Text(orden['descripcion'] ?? '-')),
              DataCell(Text(fFecha(orden['fecha_entrega']))),
              DataCell(widgetEstatus(orden['estatus_departamento'])),
              DataCell(widgetIncidente(orden['estatus_incidente'])),
            ],
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Expanded(child: contenidoTabla),

        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Boton(
                icon: Icons.play_circle_fill,
                label: "Iniciar Proceso",
                onPressed: () {
                  if (seleccionada != null &&
                      seleccionada['cotizacion_id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProduccionScreen(
                          cotizacionId: seleccionada['cotizacion_id'],
                          area: widget.area,
                        ),
                      ),
                    ).then((_) {
                      ref
                          .read(operarioOTProvider.notifier)
                          .cargarOrdenesOperario(
                            widget.area,
                            widget.verHistorial,
                          );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Selecciona una orden de trabajo primero.',
                        ),
                      ),
                    );
                  }
                },
              ),

              Boton(
                icon: Icons.refresh,
                label: "Recargar Lista",
                onPressed: () {
                  ref
                      .read(operarioOTProvider.notifier)
                      .cargarOrdenesOperario(widget.area, widget.verHistorial);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
