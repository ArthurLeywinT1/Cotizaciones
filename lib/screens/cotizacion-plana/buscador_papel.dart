import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/papel_model.dart';
import '../../providers/papel_provider.dart';

class DialogoSelectorPapel extends ConsumerStatefulWidget {
  final Function(Papel) onSeleccionado;

  final double minAncho;
  final double minLargo;

  const DialogoSelectorPapel({
    super.key,
    required this.onSeleccionado,
    this.minAncho = 0.0,
    this.minLargo = 0.0,
  });

  @override
  ConsumerState<DialogoSelectorPapel> createState() =>
      _DialogoSelectorPapelState();
}

class _DialogoSelectorPapelState extends ConsumerState<DialogoSelectorPapel> {
  String _filtro = "";
  bool _mostrarTodos = false;

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

            if (widget.minAncho > 0 || widget.minLargo > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: !_mostrarTodos,
                      onChanged: (val) => setState(() => _mostrarTodos = !val!),
                    ),
                    Expanded(
                      child: Text(
                        "¨Papeles donde quepa el pliego (${widget.minAncho}x${widget.minLargo})",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
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
                        final papelAncho = papel.ancho?.toDouble() ?? 0.0;
                        final papelLargo = papel.largo?.toDouble() ?? 0.0;

                        if (_filtro.isNotEmpty &&
                            !papel.nombre.toLowerCase().contains(_filtro)) {
                          return const SizedBox.shrink();
                        }

                        bool cabe =
                            (papelAncho >= widget.minAncho &&
                                papelLargo >= widget.minLargo) ||
                            (papelAncho >= widget.minLargo &&
                                papelLargo >= widget.minAncho);

                        if (!_mostrarTodos &&
                            !cabe &&
                            (widget.minAncho > 0 || widget.minLargo > 0)) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          leading: Icon(
                            Icons.description,
                            color: cabe ? Colors.black : Colors.grey,
                          ),
                          title: Text(
                            papel.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cabe ? Colors.black : Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            "${papel.tipo ?? 'Sin tipo'} | ${papel.peso ?? '?'}g | ${papel.ancho ?? 0}x${papel.largo ?? 0} cm",
                            style: TextStyle(
                              color: cabe
                                  ? Colors.black87
                                  : Colors.red.shade300,
                            ),
                          ),
                          trailing: Text(
                            "\$${papel.costoMillar}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            if (!cabe) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Advertencia: El pliego es más grande que este papel.",
                                  ),
                                ),
                              );
                            }
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
