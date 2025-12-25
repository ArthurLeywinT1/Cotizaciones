import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/maquina_model.dart';
import '../../providers/maquina_provider.dart';

class DialogoSelectorMaquina extends ConsumerStatefulWidget {
  final Function(Maquina) onSeleccionado;

  const DialogoSelectorMaquina({super.key, required this.onSeleccionado});

  @override
  ConsumerState<DialogoSelectorMaquina> createState() =>
      _DialogoSelectorMaquinaState();
}

class _DialogoSelectorMaquinaState
    extends ConsumerState<DialogoSelectorMaquina> {
  String _filtro = "";

  @override
  Widget build(BuildContext context) {
    final maquinasState = ref.watch(maquinasProvider);

    return AlertDialog(
      title: const Text("Seleccionar Máquina"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Buscar máquina",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _filtro = val.toLowerCase()),
            ),
            const SizedBox(height: 10),

            // Lista
            Expanded(
              child: maquinasState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : maquinasState.error.isNotEmpty
                  ? Center(
                      child: Text(
                        "Error: ${maquinasState.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.builder(
                      itemCount: maquinasState.maquinas.length,
                      itemBuilder: (context, index) {
                        final maquina = maquinasState.maquinas[index];

                        if (_filtro.isNotEmpty &&
                            !maquina.nombre.toLowerCase().contains(_filtro)) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          leading: const Icon(Icons.print),
                          title: Text(
                            maquina.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Tintas: ${maquina.cantidadTintas ?? '-'}",
                          ),
                          trailing: Text(
                            "\$${maquina.costoPorPlaca}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            widget.onSeleccionado(maquina);
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
