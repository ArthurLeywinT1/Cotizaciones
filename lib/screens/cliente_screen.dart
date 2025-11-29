import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cliente_model.dart';
import '../providers/cliente_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_cliente.dart';

class ClienteScreen extends ConsumerWidget {
  const ClienteScreen({super.key});

  void _agregarCliente(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ModalCliente(
        titulo: 'Nuevo Cliente',
        onGuardar: (clienteNuevo) async {
          final success = await ref
              .read(clientesProvider.notifier)
              .crearCliente(clienteNuevo);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Cliente creado')));
          }
        },
      ),
    );
  }

  void _modificarCliente(BuildContext context, WidgetRef ref, Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => ModalCliente(
        titulo: 'Modificar Cliente',
        clienteInicial: cliente,
        onGuardar: (clienteEditado) async {
          final success = await ref
              .read(clientesProvider.notifier)
              .actualizarCliente(clienteEditado);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cliente actualizado')),
            );
          }
        },
      ),
    );
  }

  void _eliminarCliente(BuildContext context, WidgetRef ref, Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Eliminar a "${cliente.razonSocial}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(clientesProvider.notifier)
                  .eliminarCliente(cliente.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ref.read(clienteSeleccionadoProvider.notifier).state = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente eliminado')),
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
    final clientesState = ref.watch(clientesProvider);
    final clienteSeleccionado = ref.watch(clienteSeleccionadoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: clientesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : clientesState.error.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: ${clientesState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : clientesState.clientes.isEmpty
                ? const Center(child: Text('No hay clientes registrados'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Razón Social')),
                      DataColumn(label: Text('RFC')),
                      DataColumn(label: Text('Calle')),
                      DataColumn(label: Text('No. Ext')),
                      DataColumn(label: Text('No. Int')),
                      DataColumn(label: Text('Colonia')),
                      DataColumn(label: Text('C.P.')),
                      DataColumn(label: Text('Municipio')),
                      DataColumn(label: Text('Ciudad')),
                      DataColumn(label: Text('País')),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Margen')),
                      DataColumn(label: Text('Fecha Modificación')),
                    ],
                    rows: clientesState.clientes.map((cliente) {
                      final isSelected = clienteSeleccionado?.id == cliente.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          ref.read(clienteSeleccionadoProvider.notifier).state =
                              isSelected ? null : cliente;
                        },
                        cells: [
                          DataCell(
                            Text(
                              cliente.razonSocial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(cliente.rfc ?? '-')),
                          DataCell(Text(cliente.calle ?? '-')),
                          DataCell(Text(cliente.noExterior ?? '-')),
                          DataCell(Text(cliente.noInterior ?? '-')),
                          DataCell(Text(cliente.colonia ?? '-')),
                          DataCell(Text(cliente.cp ?? '-')),
                          DataCell(Text(cliente.municipio ?? '-')),
                          DataCell(Text(cliente.ciudad ?? '-')),
                          DataCell(Text(cliente.pais)),
                          DataCell(Text(cliente.correoElectronico ?? '-')),
                          DataCell(Text("${cliente.margenUtilidad}%")),
                          DataCell(
                            Text(
                              cliente.fechaModificacion != null
                                  ? '${cliente.fechaModificacion!.day}/${cliente.fechaModificacion!.month}/${cliente.fechaModificacion!.year}'
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
                  label: "Nuevo Cliente",
                  onPressed: () => _agregarCliente(context, ref),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (clienteSeleccionado != null)
                      _modificarCliente(context, ref, clienteSeleccionado);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (clienteSeleccionado != null)
                      _eliminarCliente(context, ref, clienteSeleccionado);
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
