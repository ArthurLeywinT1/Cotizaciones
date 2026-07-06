import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanelCostoTotalPliegos extends StatefulWidget {
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
  final int piezasTotales; // Para calcular el precio unitario

  const PanelCostoTotalPliegos({
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
    required this.piezasTotales,
  });

  @override
  State<PanelCostoTotalPliegos> createState() => _PanelCostoTotalPliegosState();
}

class _PanelCostoTotalPliegosState extends State<PanelCostoTotalPliegos> {
  
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
      margin: const EdgeInsets.symmetric(vertical: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumen de Costos Totales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blueGrey)),
            const Divider(),
            const SizedBox(height: 10),

            const Text("Costo Total de Producción (Todos los pliegos):", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.costoTotalController,
                    readOnly: true, // Automático desde los pliegos
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.1),
                      border: const OutlineInputBorder(),
                      prefixText: "\$ ",
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: widget.onRecalcular,
                  icon: const Icon(Icons.calculate),
                  label: const Text("Calcular"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Contenedor Administrador
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text("Datos Comerciales:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  _buildPercentField("Margen de Utilidad:", widget.margenController),
                  const SizedBox(height: 15),
                  _buildPercentField("Descuento a Aplicar:", widget.descuentoController),
                  const SizedBox(height: 15),

                  const Text("Días de Entrega Estimados:", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: widget.diasEntregaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

            // Campos de Resultado
            _campoResultado("Precio de Venta (Con Utilidad):", widget.precioUtilidadController),
            _campoResultado("Precio con Descuento Aplicado:", widget.precioDescuentoController),
            _campoResultado("Precio Unitario (por pieza):", widget.precioUnitarioController, highlight: true),
            _campoResultado("I.V.A. (16%):", widget.ivaController),
            _campoResultado("Gran Total a Cobrar (Con IVA):", widget.precioConIvaController, isFinal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text("%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blue, size: 30),
              onPressed: () => _mostrarPickerPorcentaje(controller),
            ),
          ],
        ),
      ],
    );
  }

  Widget _campoResultado(String label, TextEditingController controller, {bool isFinal = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: isFinal || highlight ? FontWeight.bold : FontWeight.normal, fontSize: isFinal ? 16 : 14)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: true,
            style: TextStyle(
              fontWeight: isFinal || highlight ? FontWeight.bold : FontWeight.normal,
              color: isFinal ? Colors.green[800] : (highlight ? Colors.blue[800] : Colors.black),
              fontSize: isFinal ? 18 : 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isFinal ? Colors.green.withOpacity(0.1) : (highlight ? Colors.blue.withOpacity(0.05) : Colors.grey[100]),
              border: OutlineInputBorder(borderSide: isFinal ? const BorderSide(color: Colors.green) : const BorderSide()),
              prefixText: "\$ ",
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}