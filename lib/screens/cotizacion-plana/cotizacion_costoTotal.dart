import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanelCostoTotal extends StatefulWidget {
  final TextEditingController costoTotalController;
  final TextEditingController margenController;
  final TextEditingController descuentoController;
  final TextEditingController diasEntregaController;
  final TextEditingController precioUtilidadController;
  final TextEditingController precioDescuentoController;
  final TextEditingController precioUnitarioController;
  final TextEditingController ivaController;
  final TextEditingController precioConIvaController;
  final VoidCallback onRecalcular;

  const PanelCostoTotal({
    super.key,
    required this.costoTotalController,
    required this.margenController,
    required this.descuentoController,
    required this.diasEntregaController,
    required this.precioUtilidadController,
    required this.precioDescuentoController,
    required this.precioUnitarioController,
    required this.ivaController,
    required this.precioConIvaController,
    required this.onRecalcular,
  });

  @override
  State<PanelCostoTotal> createState() => _PanelCostoTotalState();
}

class _PanelCostoTotalState extends State<PanelCostoTotal> {
  void _mostrarPickerPorcentaje(TextEditingController controller) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRecalcular();
                    },
                    child: const Text(
                      "Aceptar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: int.tryParse(controller.text) ?? 0,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    controller.text = index.toString();
                  });
                  widget.onRecalcular(); // 🔥 recalcula automáticamente
                },
                children: List.generate(
                  101,
                  (i) => Center(
                    child: Text("$i%", style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              "Costo Totales",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text("Costo Total:"),
            const SizedBox(height: 4),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.costoTotalController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => widget.onRecalcular(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixText: "\$ ",
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.onRecalcular,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                  child: const Icon(Icons.calculate),
                ),
              ],
            ),

            const SizedBox(height: 20),

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
                    "Datos Solo Administrador:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text("Margen de Utilidad:"),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.margenController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("%"),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down_circle),
                        onPressed: () =>
                            _mostrarPickerPorcentaje(widget.margenController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text("Descuento a Aplicar:"),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.descuentoController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("%"),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down_circle),
                        onPressed: () => _mostrarPickerPorcentaje(
                          widget.descuentoController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text("Días de Entrega:"),
                  const SizedBox(height: 5),

                  TextField(
                    controller: widget.diasEntregaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => widget.onRecalcular(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            campoResultado(
              "Precio con Utilidad:",
              widget.precioUtilidadController,
            ),
            campoResultado(
              "Precio con Descuento:",
              widget.precioDescuentoController,
            ),
            campoResultado("Precio Unitario:", widget.precioUnitarioController),
            campoResultado("IVA:", widget.ivaController),
            campoResultado("Precio Con IVA:", widget.precioConIvaController),
          ],
        ),
      ),
    );
  }

  Widget campoResultado(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(label),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixText: "\$ ",
            isDense: true,
            contentPadding: EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}
