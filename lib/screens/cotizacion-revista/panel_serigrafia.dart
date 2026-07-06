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
  });

  @override
  ConsumerState<PanelSerigrafia> createState() =>
      _PanelSerigrafiaState();
}

class _PanelSerigrafiaState extends ConsumerState<PanelSerigrafia> {
  
  @override
  void initState() {
    super.initState();
    widget.numeroEntradasController.addListener(_calcularTotalEntrada);
    widget.costoMillarController.addListener(_calcularTotalEntrada);
  }

  @override
  void dispose() {
    widget.numeroEntradasController.removeListener(_calcularTotalEntrada);
    widget.costoMillarController.removeListener(_calcularTotalEntrada);
    super.dispose();
  }

  void _calcularTotalEntrada() {
    if (!widget.enabled) return;
    
    final entradas = double.tryParse(widget.numeroEntradasController.text) ?? 0;
    final costoMillar = double.tryParse(widget.costoMillarController.text) ?? 0;
    final total = (entradas / 1000) * costoMillar;
    widget.totalEntradaController.text = total.toStringAsFixed(2);
  }

  void actualizarMarcos() {
    if (!widget.enabled) return;

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
  }

  Widget campo(String label, TextEditingController controller, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
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
                const Text("SERIGRAFÍA", style: TextStyle(fontWeight: FontWeight.bold)),
                
                campo("Cantidad de Marcos", widget.cantidadMarcosController, onChanged: (_) => actualizarMarcos()),
                
                ...List.generate(widget.anchoMarcos.length, (index) => Row(
                  children: [
                    Expanded(child: campo("Ancho ${index + 1}", widget.anchoMarcos[index])),
                    const SizedBox(width: 5),
                    Expanded(child: campo("Alto ${index + 1}", widget.altoMarcos[index])),
                    const SizedBox(width: 5),
                    Expanded(child: campo("Precio ${index + 1}", widget.precioMarcos[index])),
                  ],
                )),
                
                campo("Total Marcos", widget.totalMarcosController),
                
                Row(children: [
                  Expanded(child: campo("Cantidad Negativos", widget.cantidadNegativosController)),
                  const SizedBox(width: 5),
                  Expanded(child: campo("Precio Negativo", widget.precioNegativoController)),
                  const SizedBox(width: 5),
                  Expanded(child: campo("Total Negativos", widget.totalNegativosController)),
                ]),
                
                Row(children: [
                  Expanded(child: campo("Cantidad Tintas", widget.cantidadTintasController)),
                  const SizedBox(width: 5),
                  Expanded(child: campo("Costo por Tinta", widget.costoTintasController)),
                  const SizedBox(width: 5),
                  Expanded(child: campo("Total Tintas", widget.totalTintasController)),
                ]),
                
                Row(children: [
                  Expanded(child: campo("# de Entrada", widget.numeroEntradasController)),
                  const SizedBox(width: 5),
                  Expanded(child: campo("Costo por Millar", widget.costoMillarController)),
                  const SizedBox(width: 5),
                  Expanded(child: campo("Total por Entrada", widget.totalEntradaController)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}