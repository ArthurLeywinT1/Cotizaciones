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
import '../services/excel.dart';

final cotizacionesSeleccionadasProvider = StateProvider<List<Cotizacion>>((ref) => []);

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
        MaterialPageRoute(builder: (context) => const CotizacionPlanaScreen()),
      );
    } else if (tipoSeleccionado == 'R') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RevistaPage()),
      );
    }
  }

  void _eliminar(BuildContext context, WidgetRef ref, List<Cotizacion> seleccionadas) {
    if (seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una cotización para eliminar')),
      );
      return;
    }

    final esMultiple = seleccionadas.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar las ${seleccionadas.length} cotizaciones seleccionadas?'
        : '¿Eliminar la cotización con folio "${seleccionadas.first.folio ?? 'S/F'}"?';

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
              for (final cotizacion in seleccionadas) {
                if (cotizacion.id != null) {
                  final ok = await ref
                      .read(cotizacionesProvider.notifier)
                      .eliminarCotizacion(cotizacion.id!);
                  if (ok) eliminadas++;
                }
              }

              if (context.mounted) {
                ref.read(cotizacionesSeleccionadasProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminadas cotizaciones eliminadas con éxito'
                          : 'Cotización eliminada exitosamente',
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

  Future<void> _noAprobar(
    BuildContext context,
    WidgetRef ref,
    List<Cotizacion> seleccionadas,
  ) async {
    if (seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una cotización')),
      );
      return;
    }

    final esMultiple = seleccionadas.length > 1;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cambio de Estatus'),
        content: Text(
          esMultiple
              ? '¿Deseas marcar las ${seleccionadas.length} cotizaciones seleccionadas como "No Aprobado"?'
              : '¿Deseas marcar la cotización "${seleccionadas.first.folio ?? 'S/F'}" como "No Aprobado"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    int actualizadas = 0;
    for (final c in seleccionadas) {
      if (c.id != null) {
        final ok = await ref
            .read(cotizacionesProvider.notifier)
            .cambiarStatus(c.id!, 'No Aprobado');
        if (ok) actualizadas++;
      }
    }

    if (context.mounted) {
      ref.read(cotizacionesSeleccionadasProvider.notifier).state = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esMultiple
                ? '$actualizadas cotizaciones marcadas como No Aprobado'
                : 'Cotización marcada como No Aprobado',
          ),
        ),
      );
    }
  }

  Future<void> _generarExcel(
    BuildContext context,
    List<Cotizacion> seleccionadas,
    List<Cotizacion> todasLasCotizaciones,
  ) async {
    if (todasLasCotizaciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cotizaciones para exportar')),
      );
      return;
    }

    List<Cotizacion>? cotizacionesAExportar;

    if (seleccionadas.isNotEmpty) {
      final seleccion = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exportar a Excel'),
          content: Text(
            'Tienes ${seleccionadas.length} cotización(es) seleccionada(s).\n\n¿Qué deseas exportar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'todas'),
              child: Text('Todas (${todasLasCotizaciones.length})'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'seleccionadas'),
              child: Text('Solo las seleccionadas (${seleccionadas.length})'),
            ),
          ],
        ),
      );

      if (seleccion == null) return;
      cotizacionesAExportar = (seleccion == 'seleccionadas')
          ? seleccionadas
          : todasLasCotizaciones;
    } else {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exportar a Excel'),
          content: Text(
            'No has seleccionado ninguna cotización.\n\n¿Deseas exportar el catálogo completo (${todasLasCotizaciones.length} cotizaciones)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Exportar Todas'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
      cotizacionesAExportar = todasLasCotizaciones;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando archivo Excel...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final excelService = ExcelExportService();
      final guardado = await excelService.exportarCotizaciones(cotizacionesAExportar);

      if (context.mounted && guardado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo Excel guardado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cotizacionesState = ref.watch(cotizacionesProvider);
    final seleccionadas = ref.watch(cotizacionesSeleccionadasProvider);

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
                            onSelectAll: (selected) {
                              if (selected == true) {
                                ref.read(cotizacionesSeleccionadasProvider.notifier).state =
                                    List<Cotizacion>.from(cotizacionesState.cotizaciones);
                              } else {
                                ref.read(cotizacionesSeleccionadasProvider.notifier).state = [];
                              }
                            },
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
                              final isSelected = seleccionadas.any((item) => item.id == c.id);
                              return DataRow(
                                selected: isSelected,
                                onSelectChanged: (selected) {
                                  final actual = List<Cotizacion>.from(
                                    ref.read(cotizacionesSeleccionadasProvider),
                                  );
                                  if (selected == true) {
                                    actual.add(c);
                                  } else {
                                    actual.removeWhere((item) => item.id == c.id);
                                  }
                                  ref.read(cotizacionesSeleccionadasProvider.notifier).state = actual;
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
                    if (seleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona una cotización para modificar')),
                      );
                      return;
                    }
                    if (seleccionadas.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar una cotización a la vez')),
                      );
                      return;
                    }

                    final seleccionada = seleccionadas.first;
                    final cotizacionFresca = cotizacionesState.cotizaciones.firstWhere(
                      (c) => c.id == seleccionada.id,
                      orElse: () => seleccionada,
                    );

                    final esRevista = cotizacionFresca.tipoCotizacion == 'R';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => esRevista
                            ? RevistaPage(cotizacionAEditar: cotizacionFresca)
                            : CotizacionPlanaScreen(cotizacionAEditar: cotizacionFresca),
                      ),
                    );
                  },
                ),
                Boton(
                  icon: Icons.content_copy,
                  label: "Recotización",
                  onPressed: () {
                    if (seleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona una cotización para recotizar')),
                      );
                      return;
                    }
                    if (seleccionadas.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes recotizar una cotización a la vez')),
                      );
                      return;
                    }

                    final seleccionada = seleccionadas.first;
                    final cotizacionFresca = cotizacionesState.cotizaciones.firstWhere(
                      (c) => c.id == seleccionada.id,
                      orElse: () => seleccionada,
                    );
                    _recotizar(context, ref, cotizacionFresca);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () => _eliminar(context, ref, seleccionadas),
                ),
                Boton(
                  icon: Icons.disabled_by_default_outlined,
                  label: "No Aprobar",
                  isDestructive: true,
                  onPressed: () => _noAprobar(context, ref, seleccionadas),
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(cotizacionesProvider.notifier).recargar();
                    ref.read(cotizacionesSeleccionadasProvider.notifier).state = [];
                  },
                ),
                Boton(
                  icon: Icons.picture_as_pdf,
                  label: "Generar PDF",
                  onPressed: () async {
                    if (seleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona una cotización para generar PDF')),
                      );
                      return;
                    }
                    if (seleccionadas.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes generar el PDF de una cotización a la vez')),
                      );
                      return;
                    }

                    await initializeDateFormatting('es');
                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      builder: (context) => DialogoGenerarPdf(cotizacion: seleccionadas.first),
                    );
                  },
                ),
                Boton(
                  icon: Icons.table_view_rounded,
                  label: "Generar Excel",
                  onPressed: () => _generarExcel(
                    context,
                    seleccionadas,
                    cotizacionesState.cotizaciones,
                  ),
                ),
                Boton(
                  icon: Icons.assignment,
                  label: "Generar OT",
                  onPressed: () async {
                    if (seleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona una cotización para generar la Orden de Trabajo'),
                        ),
                      );
                      return;
                    }
                    if (seleccionadas.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solo puedes generar la Orden de Trabajo de una cotización a la vez'),
                        ),
                      );
                      return;
                    }

                    final seleccionada = seleccionadas.first;
                    if (seleccionada.id != null) {
                      final ok = await ref
                          .read(cotizacionesProvider.notifier)
                          .cambiarStatus(seleccionada.id!, 'Orden de Trabajo');

                      if (ok && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrdenTrabajoScreen(
                              cotizacionId: seleccionada.id!,
                            ),
                          ),
                        );
                      } else if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al cambiar el estatus a Orden de Trabajo'),
                          ),
                        );
                      }
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
