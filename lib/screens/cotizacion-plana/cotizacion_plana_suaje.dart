import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

class PanelSuaje extends ConsumerStatefulWidget {
  final bool enabled;
  final TextEditingController tamanoSuajeController;
  final TextEditingController costoSuajeCmController;
  final TextEditingController costoTotalSuajeController;
  final TextEditingController costoArregloSuajeController;
  final TextEditingController costoTotalSuajadoController;

  final bool gastosEntrega;
  final ValueChanged<bool?> onGastosEntregaChanged;

  final bool duplicarCosto;
  final ValueChanged<bool?> onDuplicarCostoChanged;

  const PanelSuaje({
    super.key,
    required this.enabled,
    required this.tamanoSuajeController,
    required this.costoSuajeCmController,
    required this.costoTotalSuajeController,
    required this.costoArregloSuajeController,
    required this.costoTotalSuajadoController,
    required this.gastosEntrega,
    required this.onGastosEntregaChanged,
    required this.duplicarCosto,
    required this.onDuplicarCostoChanged,
  });

  @override
  ConsumerState<PanelSuaje> createState() => _PanelSuajeState();
}

class _PanelSuajeState extends ConsumerState<PanelSuaje> {
  @override
  void initState() {
    super.initState();
    widget.tamanoSuajeController.addListener(_calcularTotales);
    widget.costoSuajeCmController.addListener(_calcularTotales);
    widget.costoArregloSuajeController.addListener(_calcularTotales);

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarCostosBD());
  }

  void _cargarCostosBD() {
    final extrasState = ref.read(extrasProvider);

    try {
      final extraSuaje = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'suaje',
      );

      final double valorActualSuaje =
          double.tryParse(widget.costoSuajeCmController.text) ?? 0.0;

      if (valorActualSuaje == 0) {
        widget.costoSuajeCmController.text = (extraSuaje.costoCm2 ?? 0.0)
            .toStringAsFixed(4);
      }
    } catch (_) {}

    try {
      final extraArreglo = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'arreglo suaje',
      );

      final double valorActualArreglo =
          double.tryParse(widget.costoArregloSuajeController.text) ?? 0.0;

      if (valorActualArreglo == 0) {
        widget.costoArregloSuajeController.text =
            (extraArreglo.costoFijo ?? 0.0).toStringAsFixed(2);
      }
    } catch (_) {}

    _calcularTotales();
  }

  void _calcularTotales() {
    if (!widget.enabled) return;

    // 🔹 Converti 20 → 2.0
    final double ancho =
        (double.tryParse(widget.anchoSuajeController.text) ?? 0.0) / 10;

    final double alto =
        (double.tryParse(widget.largoSuajeController.text) ?? 0.0) / 10;

    // 🔹 Guardamos el tamaño (área) en tamanoSuajeController
    final double tamano = ancho * alto;
    widget.tamanoSuajeController.text = tamano.toStringAsFixed(2);

    final double costoCm =
        double.tryParse(widget.costoSuajeCmController.text) ?? 0.0;

    final double costoTotalSuaje = tamano * costoCm;
    widget.costoTotalSuajeController.text = costoTotalSuaje.toStringAsFixed(2);

    final double costoArreglo =
        double.tryParse(widget.costoArregloSuajeController.text) ?? 0.0;

    double granTotal = costoTotalSuaje + costoArreglo;

    if (widget.duplicarCosto) {
      granTotal = granTotal * 2;
    }

    widget.costoTotalSuajadoController.text = granTotal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) => _cargarCostosBD());

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            //     SECCIÓN SÚAJE (esta sí depende de enabled)
            // ======================================================
            Opacity(
              opacity: widget.enabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !widget.enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Datos Suaje, Suajado",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text("Tamaño Suaje por Pieza (cm):"),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.tamanoSuajeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("Costo del Suaje por cm:"),
                    const SizedBox(height: 4),
                    TextField(
                      readOnly: true,
                      controller: widget.costoSuajeCmController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      "Costo Total Suaje:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.costoTotalSuajeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text("Costo Arreglo Suajado:"),
                    const SizedBox(height: 4),
                    TextField(
                      readOnly: true,
                      controller: widget.costoArregloSuajeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Checkbox(
                          value: widget.duplicarCosto,
                          onChanged: (v) {
                            widget.onDuplicarCostoChanged(v);
                            Future.delayed(Duration.zero, _calcularTotales);
                          },
                        ),
                        const Text("Duplicar Costo Suajado"),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "Costo Total Suajado:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.costoTotalSuajadoController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),

            // ======================================================
            //       LOGÍSTICA (siempre activa)
            // ======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Logística",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: widget.gastosEntrega,
                        onChanged: widget.onGastosEntregaChanged,
                      ),
                      const Text("Gastos de Entrega:"),
                    ],
                  ),

                  const SizedBox(height: 4),
                  const Text("Costo:"),
                  const SizedBox(height: 4),

                  // Campo de costo: activado / desactivado dinámicamente
                  Opacity(
                    opacity: widget.gastosEntrega ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: !widget.gastosEntrega,
                      child: const TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixText: "\$ ",
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
