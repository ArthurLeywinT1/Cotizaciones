import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PanelSerigrafia extends ConsumerStatefulWidget {
  final bool enabled;
  final TextEditingController piezasTotalesController;
  final TextEditingController cantidadMarcosController;
  final TextEditingController totalMarcosController;
  final List<TextEditingController> anchoMarcos;
  final List<TextEditingController> altoMarcos;
  final List<TextEditingController> precioMarcos;
  final TextEditingController cantidadNegativosController;
  final TextEditingController precioNegativoController;
  final TextEditingController totalNegativosController;
  final TextEditingController cantidadTintasController;
  final TextEditingController costoTintasController;
  final TextEditingController totalTintasController;
  final TextEditingController numeroEntradasController;
  final TextEditingController costoMillarController;
  final TextEditingController totalEntradaController;
  final VoidCallback? onChanged; // Callback para notificar al padre al instante

  const PanelSerigrafia({
    super.key,
    required this.enabled,
    required this.piezasTotalesController,
    required this.cantidadMarcosController,
    required this.totalMarcosController,
    required this.anchoMarcos,
    required this.altoMarcos,
    required this.precioMarcos,
    required this.cantidadNegativosController,
    required this.precioNegativoController,
    required this.cantidadTintasController,
    required this.costoTintasController,
    required this.totalTintasController,
    required this.numeroEntradasController,
    required this.costoMillarController,
    required this.totalEntradaController,
    required this.totalNegativosController,
    this.onChanged,
  });

  @override
  ConsumerState<PanelSerigrafia> createState() => _PanelSerigrafiaState();
}

class _PanelSerigrafiaState extends ConsumerState<PanelSerigrafia> {
  @override
  void initState() {
    super.initState();
    _agregarListeners();
    // Ejecutar un cálculo inicial
    WidgetsBinding.instance.addPostFrameCallback((_) => _calcularTodo());
  }

  void _agregarListeners() {
    widget.cantidadNegativosController.addListener(_calcularTodo);
    widget.precioNegativoController.addListener(_calcularTodo);
    widget.cantidadTintasController.addListener(_calcularTodo);
    widget.costoTintasController.addListener(_calcularTodo);
    widget.numeroEntradasController.addListener(_calcularTodo);
    widget.costoMillarController.addListener(_calcularTodo);

    for (var ctrl in widget.precioMarcos) {
      ctrl.addListener(_calcularTodo);
    }
  }

  void _quitarListeners() {
    widget.cantidadNegativosController.removeListener(_calcularTodo);
    widget.precioNegativoController.removeListener(_calcularTodo);
    widget.cantidadTintasController.removeListener(_calcularTodo);
    widget.costoTintasController.removeListener(_calcularTodo);
    widget.numeroEntradasController.removeListener(_calcularTodo);
    widget.costoMillarController.removeListener(_calcularTodo);

    for (var ctrl in widget.precioMarcos) {
      ctrl.removeListener(_calcularTodo);
    }
  }

  void _calcularTodo() {
    if (!widget.enabled) return;

    // 1. Cálculo Total Marcos
    double totalMarcos = 0.0;
    for (var ctrl in widget.precioMarcos) {
      totalMarcos += double.tryParse(ctrl.text) ?? 0.0;
    }
    widget.totalMarcosController.text = totalMarcos.toStringAsFixed(2);

    // 2. Cálculo Total Negativos
    final cantNeg = double.tryParse(widget.cantidadNegativosController.text) ?? 0;
    final precioNeg = double.tryParse(widget.precioNegativoController.text) ?? 0;
    final totalNeg = cantNeg * precioNeg;
    widget.totalNegativosController.text = totalNeg.toStringAsFixed(2);

    // 3. Cálculo Total Tintas
    final cantTintas = double.tryParse(widget.cantidadTintasController.text) ?? 0;
    final costoTintas = double.tryParse(widget.costoTintasController.text) ?? 0;
    final totalTintas = cantTintas * costoTintas;
    widget.totalTintasController.text = totalTintas.toStringAsFixed(2);

    // 4. Cálculo Total Entrada
    final entradas = double.tryParse(widget.numeroEntradasController.text) ?? 0;
    final costoMillar = double.tryParse(widget.costoMillarController.text) ?? 0;
    final totalEntrada = (entradas / 1000) * costoMillar;
    widget.totalEntradaController.text = totalEntrada.toStringAsFixed(2);

    // Notificar al widget padre de forma inmediata
    if (widget.onChanged != null) {
      Future.microtask(() {
        if (mounted) widget.onChanged!();
      });
    }
  }

  void actualizarMarcos() {
    if (!widget.enabled) return;

    _quitarListeners(); // Limpiar listeners previos de la lista antigua de marcos

    final cantidad = int.tryParse(widget.cantidadMarcosController.text) ?? 0;
    setState(() {
      if (cantidad > widget.anchoMarcos.length) {
        for (int i = widget.anchoMarcos.length; i < cantidad; i++) {
          widget.anchoMarcos.add(TextEditingController());
          widget.altoMarcos.add(TextEditingController());
          widget.precioMarcos.add(TextEditingController());
        }
      } else if (cantidad < widget.anchoMarcos.length) {
        for (int i = widget.anchoMarcos.length - 1; i >= cantidad; i--) {
          widget.anchoMarcos[i].dispose();
          widget.altoMarcos[i].dispose();
          widget.precioMarcos[i].dispose();
          widget.anchoMarcos.removeAt(i);
          widget.altoMarcos.removeAt(i);
          widget.precioMarcos.removeAt(i);
        }
      }
    });

    _agregarListeners(); // Reasignar listeners
    _calcularTodo();
  }

  Widget campo(String label, TextEditingController controller,
      {Function(String)? onChanged, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          if (onChanged != null) onChanged(val);
          _calcularTodo();
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: readOnly,
          fillColor: readOnly ? const Color(0xFFEEEEEE) : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quitarListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.4,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("SERIGRAFÍA",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),

                campo("Cantidad de Marcos", widget.cantidadMarcosController,
                    onChanged: (_) => actualizarMarcos()),

                ...List.generate(
                  widget.anchoMarcos.length,
                  (index) => Row(
                    children: [
                      Expanded(
                          child: campo("Ancho ${index + 1}",
                              widget.anchoMarcos[index])),
                      const SizedBox(width: 5),
                      Expanded(
                          child: campo(
                              "Alto ${index + 1}", widget.altoMarcos[index])),
                      const SizedBox(width: 5),
                      Expanded(
                          child: campo("Precio ${index + 1}",
                              widget.precioMarcos[index])),
                    ],
                  ),
                ),

                campo("Total Marcos", widget.totalMarcosController,
                    readOnly: true),

                Row(children: [
                  Expanded(
                      child: campo("Cantidad Negativos",
                          widget.cantidadNegativosController)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: campo("Precio Negativo",
                          widget.precioNegativoController)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: campo("Total Negativos",
                          widget.totalNegativosController,
                          readOnly: true)),
                ]),

                Row(children: [
                  Expanded(
                      child: campo("Cantidad Tintas",
                          widget.cantidadTintasController)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: campo(
                          "Costo por Tinta", widget.costoTintasController)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: campo(
                          "Total Tintas", widget.totalTintasController,
                          readOnly: true)),
                ]),

                Row(children: [
                  Expanded(
                      child: campo(
                          "# de Entrada", widget.numeroEntradasController)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: campo(
                          "Costo por Millar", widget.costoMillarController)),
                  const SizedBox(width: 5),
                  Expanded(
                      child: campo(
                          "Total por Entrada", widget.totalEntradaController,
                          readOnly: true)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}