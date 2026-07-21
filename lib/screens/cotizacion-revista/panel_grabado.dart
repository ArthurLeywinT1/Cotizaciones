import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

// Panel específico para el cálculo de grabado
class PanelGrabado extends ConsumerStatefulWidget {
  final bool enabled;
  final TextEditingController piezasTotalesController;
  final TextEditingController cantidadPlacasController;
  final TextEditingController costoPlacaController;
  final TextEditingController costoTotalPlacasController;
  final TextEditingController costoEntradaController;
  final TextEditingController costoTotalEntradaController;
  final TextEditingController costoTotalGrabadoController;
  final VoidCallback? onChanged;

  const PanelGrabado({
    super.key,
    required this.enabled,
    required this.piezasTotalesController,
    required this.cantidadPlacasController,
    required this.costoPlacaController,
    required this.costoTotalPlacasController,
    required this.costoEntradaController,
    required this.costoTotalEntradaController,
    required this.costoTotalGrabadoController,
    this.onChanged,
  });

  @override
  ConsumerState<PanelGrabado> createState() => _PanelGrabadoState();
}

class _PanelGrabadoState extends ConsumerState<PanelGrabado> {
  final TextEditingController _millaresController = TextEditingController();
  bool _editadoManualmente = false;

  @override
  void initState() {
    super.initState();
    widget.cantidadPlacasController.addListener(_onFieldChanged);
    widget.costoPlacaController.addListener(_onFieldChanged);
    widget.costoEntradaController.addListener(_onFieldChanged);
    widget.piezasTotalesController.addListener(_onPiezasChanged);
    _millaresController.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarCostosBD());
  }

  void _onPiezasChanged() {
    if (!_editadoManualmente) {
      final piezas = double.tryParse(widget.piezasTotalesController.text) ?? 0;
      _millaresController.text = (piezas / 1000).toStringAsFixed(2);
    }
    _onFieldChanged();
  }

  void _onFieldChanged() {
    calcular();
  }

  void _cargarCostosBD() {
    final extrasState = ref.read(extrasProvider);

    try {
      final extraPlaca = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'placa grabado',
      );
      final double valorActual =
          double.tryParse(widget.costoPlacaController.text) ?? 0.0;

      if (valorActual == 0) {
        widget.costoPlacaController.text = (extraPlaca.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    try {
      final extraEntrada = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'entrada grabado por millar',
      );
      final double valorActual =
          double.tryParse(widget.costoEntradaController.text) ?? 0.0;

      if (valorActual == 0) {
        widget.costoEntradaController.text = (extraEntrada.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    if (_millaresController.text.isEmpty) {
      final piezas = double.tryParse(widget.piezasTotalesController.text) ?? 0;
      _millaresController.text = (piezas / 1000).toStringAsFixed(2);
    }

    calcular();
  }

  void calcular() {
    if (!widget.enabled) return;

    final cantidadPlacas = double.tryParse(widget.cantidadPlacasController.text) ?? 0;
    final costoPlaca = double.tryParse(widget.costoPlacaController.text) ?? 0;
    final costoEntrada = double.tryParse(widget.costoEntradaController.text) ?? 0;
    final millares = double.tryParse(_millaresController.text) ?? 0;

    final totalPlacas = cantidadPlacas * costoPlaca;
    final totalEntrada = millares * costoEntrada;
    final totalGrabado = totalPlacas + totalEntrada;

    widget.costoTotalPlacasController.text = totalPlacas.toStringAsFixed(2);
    widget.costoTotalEntradaController.text = totalEntrada.toStringAsFixed(2);
    widget.costoTotalGrabadoController.text = totalGrabado.toStringAsFixed(2);

    // Disparo inmediato para refrescar al padre sin retardo en el mismo microtask
    if (widget.onChanged != null) {
      Future.microtask(() {
        if (mounted) widget.onChanged!();
      });
    }
  }

  @override
  void dispose() {
    widget.cantidadPlacasController.removeListener(_onFieldChanged);
    widget.costoPlacaController.removeListener(_onFieldChanged);
    widget.costoEntradaController.removeListener(_onFieldChanged);
    widget.piezasTotalesController.removeListener(_onPiezasChanged);
    _millaresController.removeListener(_onFieldChanged);
    _millaresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) => _cargarCostosBD());
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.4,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Grabado",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.cantidadPlacasController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _onFieldChanged(),
                        decoration: const InputDecoration(
                          labelText: "Cantidad de Placas",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        controller: widget.costoPlacaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Costo por Placa",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.costoTotalPlacasController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Costo Total Placas",
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _millaresController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) {
                          _editadoManualmente = true;
                          _onFieldChanged();
                        },
                        decoration: const InputDecoration(
                          labelText: "Millares a Cobrar",
                          hintText: "0.00",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.costoEntradaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _onFieldChanged(),
                        decoration: const InputDecoration(
                          labelText: "Costo Entrada (x Millar)",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: widget.costoTotalEntradaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Costo Total Entrada",
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                ),
                const Divider(height: 24),
                TextField(
                  controller: widget.costoTotalGrabadoController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Costo Total Grabado",
                    filled: true,
                    fillColor: Color(0xFFDDDDDD),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}