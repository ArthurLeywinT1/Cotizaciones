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
  int _modoOrdenamientoPrecio = 0;

  void _alternarOrdenamiento() {
    setState(() {
      _modoOrdenamientoPrecio = (_modoOrdenamientoPrecio + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final papelesState = ref.watch(papelesProvider);

    List<Papel> papelesFiltrados = List.from(papelesState.papeles);

    papelesFiltrados = papelesFiltrados.where((papel) {
      bool cumpleFiltroNombre =
          _filtro.isEmpty || papel.nombre.toLowerCase().contains(_filtro);

      double papelAncho = papel.ancho?.toDouble() ?? 0.0;
      double papelLargo = papel.largo?.toDouble() ?? 0.0;
      bool cabe =
          (papelAncho >= widget.minAncho && papelLargo >= widget.minLargo) ||
          (papelAncho >= widget.minLargo && papelLargo >= widget.minAncho);

      bool cumpleDimensiones =
          _mostrarTodos ||
          cabe ||
          (widget.minAncho == 0 && widget.minLargo == 0);

      return cumpleFiltroNombre && cumpleDimensiones;
    }).toList();

    if (_modoOrdenamientoPrecio == 1) {
      papelesFiltrados.sort((a, b) => a.costoMillar.compareTo(b.costoMillar));
    } else if (_modoOrdenamientoPrecio == 2) {
      papelesFiltrados.sort((a, b) => b.costoMillar.compareTo(a.costoMillar));
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Seleccionar Papel"),
          Tooltip(
            message: "Ordenar por Precio",
            child: IconButton(
              icon: Icon(
                _modoOrdenamientoPrecio == 0
                    ? Icons.sort
                    : _modoOrdenamientoPrecio == 1
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: _modoOrdenamientoPrecio == 0 ? Colors.grey : Colors.blue,
              ),
              onPressed: _alternarOrdenamiento,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por nombre",
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
                        "Solo papeles donde quepa (${widget.minAncho}x${widget.minLargo})",
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
                  : papelesFiltrados.isEmpty
                  ? const Center(child: Text("No hay resultados"))
                  : ListView.builder(
                      itemCount: papelesFiltrados.length,
                      itemBuilder: (context, index) {
                        final papel = papelesFiltrados[index];
                        return ListTile(
                          title: Text(
                            papel.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${papel.tipo ?? 'Sin tipo'} | ${papel.peso ?? '?'}g | ${papel.ancho ?? 0}x${papel.largo ?? 0} cm\nProv: ${papel.proveedorRazonSocial ?? 'Desconocido'}",
                          ),
                          trailing: Text(
                            "\$${papel.costoMillar.toStringAsFixed(2)}",
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
    );
  }
}
