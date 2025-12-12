import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanelCostoTotal extends StatefulWidget {
  const PanelCostoTotal({super.key});

  @override
  State<PanelCostoTotal> createState() => _PanelCostoTotalState();
}

class _PanelCostoTotalState extends State<PanelCostoTotal> {
  final TextEditingController margenController = TextEditingController(text: "0");
  final TextEditingController descuentoController = TextEditingController(text: "0");

  final TextEditingController diasEntregaController =
      TextEditingController(text: "1"); // valor mínimo inicial

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
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Aceptar", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                scrollController: FixedExtentScrollController(
                  initialItem: int.tryParse(controller.text) != null
                      ? int.parse(controller.text)
                      : 0,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    controller.text = index.toString();
                  });
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Costo Totales", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            const Text("Costo Total:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),

            const SizedBox(height: 20),

            // -------------- ADMIN -----------------
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
                  const Text("Datos Solo Administrador:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // MARGEN
                  const Text("Margen de Utilidad:"),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: margenController,
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
                            _mostrarPickerPorcentaje(margenController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // DESCUENTO
                  const Text("Descuento a Aplicar:"),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: descuentoController,
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
                            _mostrarPickerPorcentaje(descuentoController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ---- DÍAS DE ENTREGA (solo números + mínimo 1) ----
                  const Text("Días de Entrega:"),
                  const SizedBox(height: 5),

                  TextField(
                    controller: diasEntregaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],

                    // ✔ Validación cuando el usuario deja el campo
                    onEditingComplete: () {
                      String value = diasEntregaController.text;

                      if (value.isEmpty || value == "0") {
                        diasEntregaController.text = "1";
                      }

                      diasEntregaController.selection = TextSelection.fromPosition(
                        TextPosition(offset: diasEntregaController.text.length),
                      );
                    },

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

            // RESTO DE CAMPOS
            const Text("Precio con Utilidad:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),

            const SizedBox(height: 15),
            const Text("Precio con Descuento:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),

            const SizedBox(height: 15),
            const Text("Precio Con Entrega:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),

            const SizedBox(height: 15),
            const Text("Precio Unitario:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),

            const SizedBox(height: 15),
            const Text("IVA:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),

            const SizedBox(height: 15),
            const Text("Precio Con IVA:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixText: "\$ ",
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
