// costoPapel_pliegos.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/descuento_provider.dart';

class PanelCostoPapelPliego extends ConsumerStatefulWidget {
  final TextEditingController costoMillarController;
  final TextEditingController totalPliegosController;
  final TextEditingController costoTotalPapelController;
  final TextEditingController descuentoController;
  final TextEditingController costoConIvaController;

  const PanelCostoPapelPliego({
    super.key,
    required this.costoMillarController,
    required this.totalPliegosController,
    required this.costoTotalPapelController,
    required this.descuentoController,
    required this.costoConIvaController,
  });

  @override
  ConsumerState<PanelCostoPapelPliego> createState() => _PanelCostoPapelPliegoState();
}

class _PanelCostoPapelPliegoState extends ConsumerState<PanelCostoPapelPliego> {
  final TextEditingController _costoSinDescuentoCtrl = TextEditingController(text: "0.00");
  bool _usarDescuentoGeneral = true; 

  @override
  void initState() {
    super.initState();
    // Escuchamos directamente los controladores
    widget.costoMillarController.addListener(_onInputChanged);
    widget.totalPliegosController.addListener(_onInputChanged);
    widget.descuentoController.addListener(_onInputChanged);

    Future.microtask(() async {
      await ref.read(descuentosProvider.notifier).recargar();
      if (mounted) _calcular();
    });
  }

  @override
  void dispose() {
    widget.costoMillarController.removeListener(_onInputChanged);
    widget.totalPliegosController.removeListener(_onInputChanged);
    widget.descuentoController.removeListener(_onInputChanged);
    _costoSinDescuentoCtrl.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    _calcular();
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

    // Se asigna siempre para asegurar sincronía sin romper la notificación del listener
    final String nuevoDescuentoStr = descuentoEncontrado.toString();
    if (widget.descuentoController.text != nuevoDescuentoStr) {
      widget.descuentoController.text = nuevoDescuentoStr;
    }
  }

  void _calcular() {
    // Si la casilla está activa, determinamos primero qué % de descuento corresponde
    if (_usarDescuentoGeneral) {
      _aplicarDescuentoAutomatico();
    }

    final double costoMillar = double.tryParse(widget.costoMillarController.text) ?? 0.0;
    final int totalPliegos = int.tryParse(widget.totalPliegosController.text) ?? 0;
    
    // Tomamos el descuento directamente según si el checkbox está activo o no
    final double descuentoPorcentaje = _usarDescuentoGeneral
        ? (double.tryParse(widget.descuentoController.text) ?? 0.0)
        : 0.0;

    // 1. Cálculo base
    final double costoUnitarioHoja = costoMillar / 1000;
    final double costoBase = costoUnitarioHoja * totalPliegos;

    // 2. Descuento
    final double montoDescuento = costoBase * (descuentoPorcentaje / 100);
    final double costoConDescuento = costoBase - montoDescuento;

    // 3. IVA
    final double iva = costoConDescuento * 0.16;
    final double costoConIva = costoConDescuento + iva;

    // Actualizaciones de UI / Controllers
    _costoSinDescuentoCtrl.text = costoBase.toStringAsFixed(2);

    if (widget.costoTotalPapelController.text != costoConDescuento.toStringAsFixed(2)) {
      widget.costoTotalPapelController.text = costoConDescuento.toStringAsFixed(2);
    }

    if (widget.costoConIvaController.text != costoConIva.toStringAsFixed(2)) {
      widget.costoConIvaController.text = costoConIva.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(descuentosProvider, (previous, next) {
      _calcular();
    });

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cotización del Papel (Costos):",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _costoSinDescuentoCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Costo Base (Sin Descuento)',
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Color(0xFFF4F2F7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Aplicar Descuento:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    Checkbox(
                      value: _usarDescuentoGeneral,
                      onChanged: (v) {
                        setState(() {
                          _usarDescuentoGeneral = v ?? false;
                          if (!_usarDescuentoGeneral) {
                            widget.descuentoController.text = "0";
                          }
                          _calcular();
                        });
                      },
                    ),
                    const Expanded(child: Text("Usar el Descuento General del Papel", style: TextStyle(fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("Descuento a Aplicar: ", style: TextStyle(fontSize: 13)),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.costoTotalPapelController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Costo Sin IVA (Con Dto)',
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Color(0xFFF4F2F7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.costoConIvaController,
                  readOnly: true,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  decoration: const InputDecoration(
                    labelText: 'Costo Total (CON IVA)',
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    isDense: true,
                    filled: true,
                    fillColor: Color(0xFFE8F5E9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}