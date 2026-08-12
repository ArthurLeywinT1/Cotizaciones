import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cotizacion_model.dart';
import '../providers/cotizacion_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'cotizacion-plana/cotizacion_plana.dart';
import 'cotizacion-revista/revista.dart';
import 'modals/pdf.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../orden de trabajo/ordenTrabajo.dart';
import '../utils/formatters.dart';

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
                  ref.read(cotizacionSeleccionadaProvider.notifier).state =
                      null;
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
                          'Error al guardar cotizacion',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : cotizacionesState.cotizaciones.isEmpty
                        ? const Center(child: Text('No hay cotizaciones registradas'))
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
                                          ? '${c.fechaCreacion!.day.toString().padLeft(2, '0')}/${c.fechaCreacion!.month.toString().padLeft(2, '0')}/${c.fechaCreacion!.year}'
                                          : '-',
                                    ),
                                  ),
                                  DataCell(Text(c.tipoCotizacionLabel)),
                                  DataCell(Text(c.clienteNombre ?? 'Desconocido')),
                                  DataCell(Text(c.descripcion)),
                                  DataCell(Text(c.medidas)),
                                  DataCell(Text(c.tintas)),
                                  DataCell(Text(Formatters.numero(c.cantidadImpresiones))),
                                  DataCell(Text(Formatters.numero(c.totalPliegos))),
                                  DataCell(Text(Formatters.moneda(c.precioSinIva))),
                                  DataCell(Text(Formatters.unitario(c.precioUnitario))),
                                  DataCell(Text(Formatters.moneda(c.precioConIva))),
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
                      ).then((_) {
                        final listaActualizada = ref
                            .read(cotizacionesProvider)
                            .cotizaciones;
                        try {
                          final actualizada = listaActualizada.firstWhere(
                            (c) => c.id == seleccionado.id,
                          );
                          ref
                              .read(cotizacionSeleccionadaProvider.notifier)
                              .state = actualizada;
                        } catch (_) {
                          ref
                              .read(cotizacionSeleccionadaProvider.notifier)
                              .state = null;
                        }
                      });
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
                    if (seleccionado != null) {
                      final cotizacionActualizada = Cotizacion(
                        id: seleccionado.id,
                        folio: seleccionado.folio,
                        fechaCreacion: seleccionado.fechaCreacion,
                        clienteId: seleccionado.clienteId,
                        usuarioId: seleccionado.usuarioId,
                        descripcion: seleccionado.descripcion,
                        anchoMedida: seleccionado.anchoMedida,
                        altoMedida: seleccionado.altoMedida,
                        tintaFrontal: seleccionado.tintaFrontal,
                        tintaReverso: seleccionado.tintaReverso,
                        cantidadImpresiones: seleccionado.cantidadImpresiones,
                        totalPliegos: seleccionado.totalPliegos,
                        precioSinIva: seleccionado.precioSinIva,
                        precioUnitario: seleccionado.precioUnitario,
                        precioConIva: seleccionado.precioConIva,
                        status: 'Orden de Trabajo',

                        tipoCotizacion: seleccionado.tipoCotizacion,

                        configClientes: seleccionado.configClientes,
                        configPliegos: seleccionado.configPliegos,
                        configDatosPapel: seleccionado.configDatosPapel,
                        configCostoPapel: seleccionado.configCostoPapel,
                        configMaquina: seleccionado.configMaquina,
                        configAcabados: seleccionado.configAcabados,
                        configLaminado: seleccionado.configLaminado,
                        configSuaje: seleccionado.configSuaje,
                        configGrabado: seleccionado.configGrabado,
                        configSerigrafia: seleccionado.configSerigrafia,
                        configEmbalaje: seleccionado.configEmbalaje,
                        configCostoTotal: seleccionado.configCostoTotal,
                        configAcabadosEspeciales:
                            seleccionado.configAcabadosEspeciales,
                        configCorte: seleccionado.configCorte,
                      );

                      await ref
                          .read(cotizacionesProvider.notifier)
                          .actualizarCotizacion(cotizacionActualizada);

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrdenTrabajoScreen(
                              cotizacionId: seleccionado.id!,
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