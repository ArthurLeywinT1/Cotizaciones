import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cliente_model.dart';
import '../providers/cliente_provider.dart';
import '../widgets/boton.dart';
import '../widgets/tabla.dart';
import 'modals/modal_cliente.dart';

final clientesSeleccionadosProvider = StateProvider<List<Cliente>>((ref) => []);

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

  void _eliminarClientes(BuildContext context, WidgetRef ref, List<Cliente> clientes) {
    final esMultiple = clientes.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar los ${clientes.length} clientes seleccionados?'
        : '¿Eliminar a "${clientes.first.razonSocial}"?';

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
              int eliminados = 0;
              for (final cliente in clientes) {
                final success = await ref
                    .read(clientesProvider.notifier)
                    .eliminarCliente(cliente.id);
                if (success) eliminados++;
              }
              if (context.mounted) {
                ref.read(clientesSeleccionadosProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esMultiple
                          ? '$eliminados clientes eliminados exitosamente'
                          : 'Cliente eliminado',
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
    final clientesState = ref.watch(clientesProvider);
    final clientesSeleccionados = ref.watch(clientesSeleccionadosProvider);

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
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(clientesSeleccionadosProvider.notifier).state =
                            List.from(clientesState.clientes);
                      } else {
                        ref.read(clientesSeleccionadosProvider.notifier).state = [];
                      }
                    },
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
                      final isSelected = clientesSeleccionados.any((c) => c.id == cliente.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<Cliente>.from(ref.read(clientesSeleccionadosProvider));
                          if (selected == true) {
                            actual.add(cliente);
                          } else {
                            actual.removeWhere((c) => c.id == cliente.id);
                          }
                          ref.read(clientesSeleccionadosProvider.notifier).state = actual;
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
                  label: "Nuevo Cliente",
                  onPressed: () => _agregarCliente(context, ref),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (clientesSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un cliente para modificar')),
                      );
                      return;
                    }
                    if (clientesSeleccionados.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar un cliente a la vez')),
                      );
                      return;
                    }
                    _modificarCliente(context, ref, clientesSeleccionados.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (clientesSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos un cliente para eliminar')),
                      );
                      return;
                    }
                    _eliminarClientes(context, ref, clientesSeleccionados);
                  },
                ),
                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(clientesProvider.notifier).recargar();
                    ref.read(clientesSeleccionadosProvider.notifier).state = [];
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
