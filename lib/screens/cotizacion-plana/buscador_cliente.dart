import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cliente_model.dart';
import '../../providers/cliente_provider.dart';

class DialogoSelectorCliente extends ConsumerStatefulWidget {
  final Function(Cliente) onSeleccionado;

  const DialogoSelectorCliente({super.key, required this.onSeleccionado});

  @override
  ConsumerState<DialogoSelectorCliente> createState() =>
      _DialogoSelectorClienteState();
}

class _DialogoSelectorClienteState
    extends ConsumerState<DialogoSelectorCliente> {
  String _filtro = "";

  @override
  Widget build(BuildContext context) {
    final clientesState = ref.watch(clientesProvider);

    return AlertDialog(
      title: const Text("Seleccionar Cliente"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por Razón Social",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _filtro = val.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),

            Expanded(
              child: clientesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : clientesState.error.isNotEmpty
                  ? Center(
                      child: Text(
                        "Error: ${clientesState.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.builder(
                      itemCount: clientesState.clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = clientesState.clientes[index];

                        if (_filtro.isNotEmpty &&
                            !cliente.razonSocial.toLowerCase().contains(
                              _filtro,
                            )) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          leading: const Icon(Icons.business),
                          title: Text(cliente.razonSocial),
                          subtitle: Text("RFC: ${cliente.rfc}"),
                          onTap: () {
                            widget.onSeleccionado(cliente);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
