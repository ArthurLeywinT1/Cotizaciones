import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cotizacion_model.dart';
import '../providers/cotizacion_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'cotizacion-plana/cotizacion_plana_screen.dart';

class CatalogoCotizacionesScreen extends ConsumerWidget {
  const CatalogoCotizacionesScreen({super.key});

  void _nuevaCotizacion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CotizacionPlanaScreen()),
    );
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
      appBar: AppBar(
        title: const Text('Catálogo Cotizaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: cotizacionesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cotizacionesState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${cotizacionesState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : cotizacionesState.cotizaciones.isEmpty
                ? const Center(child: Text('No hay cotizaciones registradas'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Número\nCotización')),
                      DataColumn(label: Text('Fecha\nCreación')),
                      DataColumn(label: Text('Cliente')),
                      DataColumn(label: Text('Descripción')),
                      DataColumn(label: Text('Medida\nTrabajo (cm)')),
                      DataColumn(label: Text('Tipo\nCotización')),
                      DataColumn(label: Text('Tintas')),
                      DataColumn(label: Text('Cantidad\nImpresiones')),
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
                              .state = isSelected
                              ? null
                              : c;
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
                          DataCell(Text(c.clienteNombre ?? 'Desconocido')),
                          DataCell(Text(c.descripcion)),
                          DataCell(Text(c.medidas)),
                          DataCell(Text(c.tipoCotizacion)),
                          DataCell(Text(c.tintas)),
                          DataCell(Text(c.cantidadImpresiones.toString())),
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función en desarrollo')),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
