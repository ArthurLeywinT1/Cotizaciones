import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/papel_model.dart';
import '../../providers/papel_provider.dart';

class DialogoSelectorPapel extends ConsumerStatefulWidget {
  final Function(Papel) onSeleccionado;

  const DialogoSelectorPapel({super.key, required this.onSeleccionado});

  @override
  ConsumerState<DialogoSelectorPapel> createState() =>
      _DialogoSelectorPapelState();
}

class _DialogoSelectorPapelState extends ConsumerState<DialogoSelectorPapel> {
  String _filtro = "";

  @override
  Widget build(BuildContext context) {
    final papelesState = ref.watch(papelesProvider);

    return AlertDialog(
      title: const Text("Seleccionar Papel"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por nombre...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {
                  _filtro = val.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),

            Expanded(
              child: papelesState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : papelesState.error.isNotEmpty
                  ? Center(
                      child: Text(
                        "Error: ${papelesState.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : papelesState.papeles.isEmpty
                  ? const Center(child: Text("No hay papeles registrados"))
                  : ListView.builder(
                      itemCount: papelesState.papeles.length,
                      itemBuilder: (context, index) {
                        final papel = papelesState.papeles[index];

                        if (_filtro.isNotEmpty &&
                            !papel.nombre.toLowerCase().contains(_filtro)) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(
                            papel.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${papel.tipo ?? 'Sin tipo'} | ${papel.peso ?? '?'}g",
                          ),
                          trailing: Text(
                            "\$${papel.costoMillar}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            widget.onSeleccionado(papel);
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
