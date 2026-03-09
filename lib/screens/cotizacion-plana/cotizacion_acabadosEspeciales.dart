import 'package:flutter/material.dart';

// Panel específico para el cálculo de acabados especiales (5 tipos, cada uno con descripción y costo)
class PanelAcabadosEspeciales extends StatefulWidget {
  final TextEditingController cantidadImpresionController;

  const PanelAcabadosEspeciales({
    super.key,
    required this.cantidadImpresionController,
  });

  @override
  State<PanelAcabadosEspeciales> createState() =>
      _PanelAcabadosEspecialesState();
}

class _PanelAcabadosEspecialesState extends State<PanelAcabadosEspeciales> {
  // Estado de los 5 acabados especiales
  final List<bool> activo = [false, false, false, false, false];
  late List<TextEditingController> costoMillarControllers;
  late List<TextEditingController> costoTotalControllers;

  @override
  void initState() {
    super.initState();
    costoMillarControllers = List.generate(5, (_) => TextEditingController());
    costoTotalControllers = List.generate(
      5,
      (_) => TextEditingController(text: "0.00"),
    );
    widget.cantidadImpresionController.addListener(_onCantidadChanged);
  }

  void _onCantidadChanged() {
    for (int i = 0; i < 5; i++) {
      if (activo[i]) {
        _calcularCosto(i);
      }
    }
  }

  void _calcularCosto(int index) {
    final double piezas =
        double.tryParse(widget.cantidadImpresionController.text) ?? 0.0;
    final double costoMillar =
        double.tryParse(costoMillarControllers[index].text) ?? 0.0;
    final double total = (piezas / 1000) * costoMillar;
    costoTotalControllers[index].text = total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    widget.cantidadImpresionController.removeListener(_onCantidadChanged);
    for (var c in costoMillarControllers) {
      c.dispose();
    }
    for (var c in costoTotalControllers) {
      c.dispose();
    }
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
              "Acabados Especiales",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Genera los 5 acabados dinámicamente
            for (int i = 0; i < 5; i++) ...[
              Row(
                children: [
                  Checkbox(
                    value: activo[i],
                    onChanged: (value) {
                      setState(() {
                        activo[i] = value!;
                        if (activo[i]) {
                          _calcularCosto(i);
                        } else {
                          costoMillarControllers[i].clear();
                          costoTotalControllers[i].text = "0.00";
                        }
                      });
                    },
                  ),
                  Text("Acabado Especial ${i + 1}:"),
                ],
              ),

              // Si está activo → muestra los campos
              if (activo[i]) ...[
                const SizedBox(height: 4),

                // CAMPO DESCRIPCIÓN
                const SizedBox(height: 4),
                TextField(
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
                    // CAMPO PIEZAS
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
                        controller: costoMillarControllers[i],
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calcularCosto(i),
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

                // CAMPO COSTO
                TextField(
                  controller: costoTotalControllers[i],
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
    );
  }
}
