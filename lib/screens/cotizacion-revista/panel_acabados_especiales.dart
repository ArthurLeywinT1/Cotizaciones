import 'package:flutter/material.dart';

// Panel específico para el cálculo de acabados especiales
class PanelAcabadosEspeciales extends StatefulWidget {
  final bool enabled;
  final TextEditingController cantidadImpresionController;
  final List<bool> activos;
  final List<TextEditingController> descripcionControllers;
  final List<TextEditingController> costoMillarControllers;
  final List<TextEditingController> costoTotalControllers;
  final void Function(int index, bool value) onChangedActivo;
  final void Function(int index) onCalcularCosto;

  const PanelAcabadosEspeciales({
    super.key,
    required this.enabled,
    required this.cantidadImpresionController,
    required this.activos,
    required this.descripcionControllers,
    required this.costoMillarControllers,
    required this.costoTotalControllers,
    required this.onChangedActivo,
    required this.onCalcularCosto,
  });

  @override
  State<PanelAcabadosEspeciales> createState() =>
      _PanelAcabadosEspecialesState();
}

class _PanelAcabadosEspecialesState extends State<PanelAcabadosEspeciales> {
  late List<bool> localActivos;

  @override
  void initState() {
    super.initState();
    _sincronizarEstadoLocal();
    widget.cantidadImpresionController.addListener(_recalcularTodos);
  }

  void _sincronizarEstadoLocal() {
    localActivos = List.from(widget.activos);
  }

  void _recalcularTodos() {
    if (!widget.enabled) return;
    for (int i = 0; i < 5; i++) {
      if (localActivos[i]) {
        _calcularCostoIndividual(i);
      }
    }
  }

  void _calcularCostoIndividual(int index) {
    if (!widget.enabled) return;
    
    final double piezas =
        double.tryParse(widget.cantidadImpresionController.text) ?? 0.0;
    final double costoMillar =
        double.tryParse(widget.costoMillarControllers[index].text) ?? 0.0;
    final double total = (piezas / 1000) * costoMillar;
    widget.costoTotalControllers[index].text = total.toStringAsFixed(2);
    widget.onCalcularCosto(index);
  }

  @override
  void dispose() {
    widget.cantidadImpresionController.removeListener(_recalcularTodos);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.4,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Acabados Especiales",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < 5; i++) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: localActivos[i],
                        onChanged: (v) {
                          final bool nuevoValor = v ?? false;
                          setState(() {
                            localActivos[i] = nuevoValor;
                            widget.onChangedActivo(i, nuevoValor);
                            if (nuevoValor) {
                              _calcularCostoIndividual(i);
                            } else {
                              widget.descripcionControllers[i].clear();
                              widget.costoMillarControllers[i].clear();
                              widget.costoTotalControllers[i].text = "0.00";
                              widget.onCalcularCosto(i);
                            }
                          });
                        },
                      ),
                      Text("Acabado Especial ${i + 1}:"),
                    ],
                  ),
                  if (localActivos[i]) ...[
                    const SizedBox(height: 4),
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
                        Expanded(
                          child: TextField(
                            controller: widget.cantidadImpresionController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Piezas",
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(10),
                              filled: true,
                              fillColor: Color(0xFFEEEEEE),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widget.costoMillarControllers[i],
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              _calcularCostoIndividual(i);
                            },
                            decoration: const InputDecoration(
                              labelText: "Costo por millar",
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
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}