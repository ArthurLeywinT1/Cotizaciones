import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Importante para el formato de números

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
  // Formateador para mostrar números con comas y 2 decimales
  final NumberFormat _f = NumberFormat("#,##0.00", "en_US");

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
                    child: const Text("Aceptar", style: TextStyle(fontSize: 18)),
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
                  widget.onRecalcular();
                },
                children: List.generate(
                  101,
                  (i) => Center(child: Text("$i%", style: const TextStyle(fontSize: 20))),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Costos Totales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),

            const Text("Costo Total:"),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.costoTotalController,
                    keyboardType: TextInputType.number,
                    // Formateador dinámico para poner comas mientras escribes
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CurrencyInputFormatter(),
                    ],
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
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                  child: const Icon(Icons.calculate),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Contenedor Administrador
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Datos Solo Administrador:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 15),

                  _buildPercentField("Margen de Utilidad:", widget.margenController),
                  const SizedBox(height: 15),
                  _buildPercentField("Descuento a Aplicar:", widget.descuentoController),
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

            const SizedBox(height: 10),

            // Campos de Resultado
            _campoResultado("Precio con Utilidad:", widget.precioUtilidadController),
            _campoResultado("Precio con Descuento:", widget.precioDescuentoController),
            _campoResultado("Precio Unitario:", widget.precioUnitarioController),
            _campoResultado("IVA:", widget.ivaController),
            _campoResultado("Precio Con IVA:", widget.precioConIvaController, isFinal: true),
          ],
        ),
      ),
    );
  }

  // Widget para los campos de porcentaje con el botón del picker
  Widget _buildPercentField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text("%", style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
              onPressed: () => _mostrarPickerPorcentaje(controller),
            ),
          ],
        ),
      ],
    );
  }

  // Widget para mostrar resultados (Solo Lectura con Comas)
  Widget _campoResultado(String label, TextEditingController controller, {bool isFinal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(label, style: TextStyle(fontWeight: isFinal ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
            color: isFinal ? Colors.green[700] : Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: const OutlineInputBorder(),
            prefixText: "\$ ",
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}

// FORMATEADOR PARA EL TEXTFIELD DE ENTRADA
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    // Quitamos cualquier cosa que no sea número
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    double value = double.parse(cleanText);
    
    // Formateamos sin decimales para la entrada de costo (o ajusta según necesites)
    final formatter = NumberFormat("#,###", "en_US");
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}