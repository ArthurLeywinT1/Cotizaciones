import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/descuento_provider.dart';

class PanelCostoPapel extends ConsumerStatefulWidget {
  final TextEditingController costoMillarController;
  final TextEditingController totalPliegosController;
  final TextEditingController costoTotalPapelController;
  final TextEditingController descuentoController;
  final TextEditingController costoConIvaController;
// 🔒 SOLO COSTO PAPEL
  const PanelCostoPapel({
    super.key,
    required this.costoMillarController,
    required this.totalPliegosController,
    required this.costoTotalPapelController,
    required this.descuentoController,
    required this.costoConIvaController,
  });

  @override
  ConsumerState<PanelCostoPapel> createState() => _PanelCostoPapelState();
}

class _PanelCostoPapelState extends ConsumerState<PanelCostoPapel> {
  final TextEditingController _costoSinDescuentoCtrl = TextEditingController(
    text: "0.00",
  );

  bool _usarDescuentoGeneral = false;

  @override
  void initState() {
    super.initState();
    widget.costoMillarController.addListener(_calcular);
    widget.totalPliegosController.addListener(_calcular);
    widget.descuentoController.addListener(_calcular);

    Future.microtask(() => ref.read(descuentosProvider.notifier).recargar());
  }

  @override
  void dispose() {
    _costoSinDescuentoCtrl.dispose();
    super.dispose();
  }

  void _aplicarDescuentoAutomatico() {
    if (!_usarDescuentoGeneral) return;

    final int cantidad = int.tryParse(widget.totalPliegosController.text) ?? 0;
    final descuentosState = ref.read(descuentosProvider);

    double descuentoEncontrado = 0.0;

    try {
      final regla = descuentosState.descuentos.firstWhere(
        (d) => cantidad >= d.cantidadDesde && cantidad <= d.cantidadHasta,
      );
      descuentoEncontrado = regla.descuento;
    } catch (e) {
      descuentoEncontrado = 0.0;
    }

    if (widget.descuentoController.text != descuentoEncontrado.toString()) {
      widget.descuentoController.text = descuentoEncontrado.toString();
    }
  }

  void _calcular() {
    if (_usarDescuentoGeneral) {
      _aplicarDescuentoAutomatico();
    }

    final double costoMillar =
        double.tryParse(widget.costoMillarController.text) ?? 0.0;
    final int totalPliegos =
        int.tryParse(widget.totalPliegosController.text) ?? 0;
    final double descuentoPorcentaje =
        double.tryParse(widget.descuentoController.text) ?? 0.0;

    final double costoUnitarioHoja = costoMillar / 1000;
    final double costoBase = costoUnitarioHoja * totalPliegos;

    final double montoDescuento = costoBase * (descuentoPorcentaje / 100);
    final double costoConDescuento = costoBase - montoDescuento;

    final double iva = costoConDescuento * 0.16;
    final double costoConIva = costoConDescuento + iva;
    _costoSinDescuentoCtrl.text = costoBase.toStringAsFixed(2);

    if (widget.costoTotalPapelController.text !=
        costoConDescuento.toStringAsFixed(2)) {
      widget.costoTotalPapelController.text = costoConDescuento.toStringAsFixed(
        2,
      );
    }

    if (widget.costoConIvaController.text != costoConIva.toStringAsFixed(2)) {
      widget.costoConIvaController.text = costoConIva.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(descuentosProvider, (previous, next) {
      if (_usarDescuentoGeneral) _calcular();
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              // TÍTULO PRINCIPAL
              "Costos del Papel a Usar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // CAMPO: Costo Papel sin descuento
            const Text("Costo Papel Sin Descuento:"),
            const SizedBox(height: 4),
            TextField(
              controller: _costoSinDescuentoCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Aplicar Descuento:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: _usarDescuentoGeneral,
                        onChanged: (v) {
                          setState(() {
                            _usarDescuentoGeneral = v ?? false;
                            if (_usarDescuentoGeneral) {
                              _calcular();
                            } else {
                              widget.descuentoController.text = "0";
                            }
                          });
                        },
                      ),
                      const Expanded(
                        child: Text("Usar el Descuento General del Papel"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text("Descuento a Aplicar: "),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: widget.descuentoController,
                          readOnly: !_usarDescuentoGeneral,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("%"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Costo Papel Sin IVA (Con Descuento):"),
            const SizedBox(height: 4),
            TextField(
              controller: widget.costoTotalPapelController,
              readOnly: true,
              decoration: const InputDecoration(
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const SizedBox(height: 16),

            // COSTO CON IVA (TITULO EN NEGRITAS)
            const Text(
              "Costo Papel Con IVA:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: widget.costoConIvaController,
              readOnly: true,
              decoration: const InputDecoration(
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
