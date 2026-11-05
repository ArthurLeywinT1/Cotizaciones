import 'package:flutter/material.dart';

// Panel específico para el cálculo de Extras (dinámico, con costo por unidad y cantidad editable)
class PanelExtras extends StatefulWidget {
  final TextEditingController cantidadImpresionController;
  final List<bool> activos;
  final List<TextEditingController> descripcionControllers;
  final List<TextEditingController> cantidadControllers;
  final List<TextEditingController> costoUnitarioControllers;
  final List<TextEditingController> costoTotalControllers;
  final void Function(int index, bool value) onChangedActivo;
  final void Function(int index) onCalcularCosto;
  final VoidCallback onAgregarExtra;

  const PanelExtras({
    super.key,
    required this.cantidadImpresionController,
    required this.activos,
    required this.descripcionControllers,
    required this.cantidadControllers,
    required this.costoUnitarioControllers,
    required this.costoTotalControllers,
    required this.onChangedActivo,
    required this.onCalcularCosto,
    required this.onAgregarExtra,
  });

  @override
  State<PanelExtras> createState() => _PanelExtrasState();
}

class _PanelExtrasState extends State<PanelExtras> {
  // Controla qué filas mantienen sincronizada la cantidad automática
  // y cuáles fueron modificadas manualmente por el usuario.
  final Set<int> _cantidadesEditadasManualmente = {};

  @override
  void initState() {
    super.initState();
    widget.cantidadImpresionController.addListener(_sincronizarCantidadesAutomaticas);
  }

  void _sincronizarCantidadesAutomaticas() {
    final String piezasGlobales = widget.cantidadImpresionController.text;
    for (int i = 0; i < widget.activos.length; i++) {
      if (!_cantidadesEditadasManualmente.contains(i)) {
        widget.cantidadControllers[i].text = piezasGlobales;
        if (widget.activos[i]) {
          _calcularCostoIndividual(i);
        }
      }
    }
  }

  void _calcularCostoIndividual(int index) {
    final double piezas =
        double.tryParse(widget.cantidadControllers[index].text) ?? 0.0;
    final double costoUnitario =
        double.tryParse(widget.costoUnitarioControllers[index].text) ?? 0.0;
    final double total = piezas * costoUnitario;

    widget.costoTotalControllers[index].text = total.toStringAsFixed(2);
    widget.onCalcularCosto(index);
  }

  @override
  void dispose() {
    widget.cantidadImpresionController.removeListener(_sincronizarCantidadesAutomaticas);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Extras",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            for (int i = 0; i < widget.activos.length; i++) ...[
              Row(
                children: [
                  Checkbox(
                    value: widget.activos[i],
                    onChanged: (v) {
                      final bool nuevoValor = v ?? false;
                      setState(() {
                        widget.onChangedActivo(i, nuevoValor);
                        if (nuevoValor) {
                          if (widget.cantidadControllers[i].text.isEmpty ||
                              widget.cantidadControllers[i].text == "0") {
                            widget.cantidadControllers[i].text =
                                widget.cantidadImpresionController.text;
                            _cantidadesEditadasManualmente.remove(i);
                          }
                          _calcularCostoIndividual(i);
                        } else {
                          _cantidadesEditadasManualmente.remove(i);
                          widget.descripcionControllers[i].clear();
                          widget.cantidadControllers[i].text =
                              widget.cantidadImpresionController.text;
                          widget.costoUnitarioControllers[i].clear();
                          widget.costoTotalControllers[i].text = "0.00";
                          widget.onCalcularCosto(i);
                        }
                      });
                    },
                  ),
                  Text("Extra ${i + 1}:"),
                ],
              ),

              if (widget.activos[i]) ...[
                const SizedBox(height: 4),

                // CAMPO DESCRIPCIÓN
                TextField(
                  controller: widget.descripcionControllers[i],
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    // CAMPO PIEZAS (Automático pero editable)
                    Expanded(
                      child: TextField(
                        controller: widget.cantidadControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) {
                          if (val == widget.cantidadImpresionController.text) {
                            _cantidadesEditadasManualmente.remove(i);
                          } else {
                            _cantidadesEditadasManualmente.add(i);
                          }
                          _calcularCostoIndividual(i);
                        },
                        decoration: const InputDecoration(
                          labelText: "Piezas",
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // CAMPO COSTO POR UNIDAD
                    Expanded(
                      child: TextField(
                        controller: widget.costoUnitarioControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => _calcularCostoIndividual(i),
                        decoration: const InputDecoration(
                          labelText: "Costo por unidad",
                          border: OutlineInputBorder(),
                          prefixText: "\$ ",
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // CAMPO COSTO TOTAL
                TextField(
                  controller: widget.costoTotalControllers[i],
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Costo Total",
                    border: OutlineInputBorder(),
                    prefixText: "\$ ",
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],

            // BOTÓN PARA AGREGAR MÁS DE 5 EXTRAS
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: widget.onAgregarExtra,
                icon: const Icon(Icons.add),
                label: const Text("Agregar otro Extra"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}