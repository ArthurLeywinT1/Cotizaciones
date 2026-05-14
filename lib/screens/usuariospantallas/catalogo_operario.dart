import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/operario_provider.dart';
import '../../providers/incidente_provider.dart';
import '../../widgets/tabla.dart';
import '../../widgets/boton.dart';
import '../../orden de trabajo/ordenTrabajo.dart';
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
          DataColumn(label: Text('Folio OT')),
          DataColumn(label: Text('Fecha Creación')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Descripción / Proyecto')),
          DataColumn(label: Text('Estatus del Área')),
          DataColumn(label: Text('Fecha Inicio')),
          DataColumn(label: Text('Fecha Fin')),
        ],
        rows: state.ordenes.map((orden) {
          final isSelected =
              seleccionada != null && seleccionada['ot_id'] == orden['ot_id'];

          String fFecha(dynamic f) {
            if (f == null || f.toString().isEmpty) return '-';
            if (f is DateTime) return '${f.day}/${f.month}/${f.year}';
            return f.toString().split(' ')[0];
          }

          return DataRow(
            selected: isSelected,
            onSelectChanged: (_) {
              ref.read(otOperarioSeleccionadaProvider.notifier).state =
                  isSelected ? null : orden;
            },
            cells: [
              DataCell(Text(orden['folio'] ?? 'S/F')),
              DataCell(Text(fFecha(orden['fecha_creacion']))),
              DataCell(Text(orden['cliente'] ?? '-')),
              DataCell(Text(orden['descripcion'] ?? '-')),
              DataCell(Text(orden['estatus_departamento'] ?? 'Pendiente')),
              DataCell(Text(orden['inicio_departamento'] ?? '-')),
              DataCell(Text(orden['fin_departamento'] ?? '-')),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Boton(
                icon: Icons.visibility,
                label: "Abrir Orden de Trabajo",
                onPressed: () {
                  if (seleccionada != null &&
                      seleccionada['cotizacion_id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdenTrabajoScreen(
                          cotizacionId: seleccionada['cotizacion_id'],
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
                icon: Icons.warning_amber_rounded,
                label: "Incidente",
                isDestructive: true,
                onPressed: () {
                  if (seleccionada != null && seleccionada['ot_id'] != null) {
                    _mostrarModalIncidente(context, seleccionada);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Selecciona una orden de trabajo para reportar un incidente.',
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
