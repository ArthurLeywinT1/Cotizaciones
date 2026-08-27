import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../models/cotizacion_model.dart';
import '../orden de trabajo/ordenTrabajo.dart';
import '../providers/cotizacion_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'cotizacion-plana/cotizacion_plana.dart';
import 'cotizacion-revista/revista.dart';
import 'modals/pdf.dart';

class CatalogoCotizacionesScreen extends ConsumerWidget {
  const CatalogoCotizacionesScreen({super.key});

  Future<void> _nuevaCotizacion(BuildContext context) async {
    final tipoSeleccionado = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Selecciona el tipo de cotización'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'P'),
            child: const Text('Cotización Plana'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'R'),
            child: const Text('Cotización Revista'),
          ),
        ],
      ),
    );

    if (!context.mounted || tipoSeleccionado == null) return;

    if (tipoSeleccionado == 'P') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CotizacionPlanaScreen(),
        ),
      );
    } else if (tipoSeleccionado == 'R') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RevistaPage(),
        ),
      );
    }
  }

  void _eliminar(BuildContext context, WidgetRef ref, Cotizacion cotizacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Eliminar la cotización con folio "${cotizacion.folio ?? 'S/F'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (cotizacion.id != null) {
                final success = await ref
                    .read(cotizacionesProvider.notifier)
                    .eliminarCotizacion(cotizacion.id!);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cotización eliminada')),
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

  void _recotizar(BuildContext context, WidgetRef ref, Cotizacion cotizacion) {
    final piezasController = TextEditingController(
      text: cotizacion.cantidadImpresiones.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recotización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se abrirá la cotización con folio "${cotizacion.folio ?? 'S/F'}" '
              'con los mismos datos, para guardarla como una cotización nueva '
              'con otra cantidad de piezas.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: piezasController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Piezas totales solicitadas',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nuevasPiezas = int.tryParse(piezasController.text);
              if (nuevasPiezas == null || nuevasPiezas <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa una cantidad de piezas válida'),
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final esRevista = cotizacion.tipoCotizacion == 'R';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => esRevista
                      ? RevistaPage(
                          cotizacionAEditar: cotizacion,
                          piezasOverride: nuevasPiezas,
                          esRecotizacion: true,
                        )
                      : CotizacionPlanaScreen(
                          cotizacionAEditar: cotizacion,
                          piezasOverride: nuevasPiezas,
                          esRecotizacion: true,
                        ),
                ),
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cotizacionesState = ref.watch(cotizacionesProvider);
    final seleccionado = ref.watch(cotizacionSeleccionadaProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: cotizacionesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cotizacionesState.error.isNotEmpty
                    ? Center(
                        child: Text(
                          cotizacionesState.error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : cotizacionesState.cotizaciones.isEmpty
                        ? const Center(
                            child: Text('No hay cotizaciones registradas'),
                          )
                        : Tabla(
                            columns: const [
                              DataColumn(label: Text('Folio')),
                              DataColumn(label: Text('Fecha\nCreación')),
                              DataColumn(label: Text('Tipo')),
                              DataColumn(label: Text('Cliente')),
                              DataColumn(label: Text('Descripción')),
                              DataColumn(label: Text('Medida\nTrabajo (cm)')),
                              DataColumn(label: Text('Tintas')),
                              DataColumn(label: Text('Cantidad\nImpresiones')),
                              DataColumn(label: Text('Número\nde Pliegos')),
                              DataColumn(label: Text('Total\nPliegos')),
                              DataColumn(label: Text('Precio\nsin IVA')),
                              DataColumn(label: Text('Precio\nUnitario')),
                              DataColumn(label: Text('Precio\ncon IVA')),
                              DataColumn(label: Text('Estatus')),
                              DataColumn(label: Text('Usuario')),
                            ],
                            rows: cotizacionesState.cotizaciones.map((c) {
                              final isSelected = seleccionado?.id == c.id;
                              return DataRow(
                                selected: isSelected,
                                onSelectChanged: (_) {
                                  ref
                                      .read(cotizacionSeleccionadaProvider.notifier)
                                      .state = isSelected ? null : c;
                                },
                                cells: [
                                  DataCell(Text(c.folio ?? '-')),
                                  DataCell(
                                    Text(
                                      c.fechaCreacion != null
                                          ? DateFormat('dd/MM/yyyy\nHH:mm').format(
                                              c.fechaCreacion!.toLocal(),
                                            )
                                          : '-',
                                    ),
                                  ),
                                  DataCell(Text(c.tipoCotizacionLabel)),
                                  DataCell(Text(c.clienteNombre ?? 'Desconocido')),
                                  DataCell(Text(c.descripcion)),
                                  DataCell(Text(c.medidas)),
                                  DataCell(Text(c.tintas)),
                                  DataCell(Text(c.cantidadImpresiones.toString())),
                                  DataCell(Text(c.numPliegos.toString())),
                                  DataCell(Text(c.totalPliegos.toString())),
                                  DataCell(
                                    Text('\$${c.precioSinIva.toStringAsFixed(2)}'),
                                  ),
                                  DataCell(
                                    Text('\$${c.precioUnitario.toStringAsFixed(4)}'),
                                  ),
                                  DataCell(
                                    Text('\$${c.precioConIva.toStringAsFixed(2)}'),
                                  ),
                                  DataCell(Text(c.status)),
                                  DataCell(Text(c.usuarioNombre ?? 'Desconocido')),
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
                  label: "Nueva Cotización",
                  onPressed: () => _nuevaCotizacion(context),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (seleccionado != null) {
                      final cotizacionesActuales = ref
                          .read(cotizacionesProvider)
                          .cotizaciones;
                      final cotizacionFresca = cotizacionesActuales.firstWhere(
                        (c) => c.id == seleccionado.id,
                        orElse: () => seleccionado,
                      );

                      final esRevista = cotizacionFresca.tipoCotizacion == 'R';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => esRevista
                              ? RevistaPage(cotizacionAEditar: cotizacionFresca)
                              : CotizacionPlanaScreen(
                                  cotizacionAEditar: cotizacionFresca,
                                ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una cotización para modificar',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Boton(
                  icon: Icons.content_copy,
                  label: "Recotización",
                  onPressed: () {
                    if (seleccionado != null) {
                      final cotizacionesActuales = ref
                          .read(cotizacionesProvider)
                          .cotizaciones;
                      final cotizacionFresca = cotizacionesActuales.firstWhere(
                        (c) => c.id == seleccionado.id,
                        orElse: () => seleccionado,
                      );
                      _recotizar(context, ref, cotizacionFresca);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una cotización para recotizar',
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
                    if (seleccionado != null) {
                      _eliminar(context, ref, seleccionado);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una cotización para eliminar',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Boton(
                  icon: Icons.disabled_by_default_outlined,
                  label: "No Aprobar",
                  isDestructive: true,
                  onPressed: () async {
                    if (seleccionado != null && seleccionado.id != null) {
                      final ok = await ref
                          .read(cotizacionesProvider.notifier)
                          .cambiarStatus(seleccionado.id!, 'No Aprobado');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Cotización marcada como No Aprobado'
                                  : 'No se pudo actualizar el estatus',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(cotizacionesProvider.notifier).recargar();
                  },
                ),
                Boton(
                  icon: Icons.picture_as_pdf,
                  label: "Generar PDF",
                  onPressed: () async {
                    if (seleccionado != null) {
                      await initializeDateFormatting('es');
                      if (!context.mounted) return;

                      showDialog(
                        context: context,
                        builder: (context) =>
                            DialogoGenerarPdf(cotizacion: seleccionado),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una cotización para generar PDF',
                          ),
                        ),
                      );
                    }
                  },
                ),
                Boton(
                  icon: Icons.assignment,
                  label: "Generar OT",
                  onPressed: () async {
                    if (seleccionado != null && seleccionado.id != null) {
                      final ok = await ref
                          .read(cotizacionesProvider.notifier)
                          .cambiarStatus(
                            seleccionado.id!,
                            'Orden de Trabajo',
                          );

                      if (ok && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrdenTrabajoScreen(
                              cotizacionId: seleccionado.id!,
                            ),
                          ),
                        );
                      } else if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error al cambiar el estatus a Orden de Trabajo',
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona una cotización para generar la Orden de Trabajo',
                          ),
                        ),
                      );
                    }
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
