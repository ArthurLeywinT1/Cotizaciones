import 'package:flutter/material.dart';

class PanelAcabadosEspeciales extends StatefulWidget {
  final TextEditingController piezasPorPliegoController;

  const PanelAcabadosEspeciales({
    super.key,
    required this.piezasPorPliegoController,
  });

  @override
  State<PanelAcabadosEspeciales> createState() =>
      _PanelAcabadosEspecialesState();
}

class _PanelAcabadosEspecialesState extends State<PanelAcabadosEspeciales> {
  // Estado de los 5 acabados especiales
  final List<bool> activo = [false, false, false, false, false];

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
              "Acabados Especiales",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Genera los 5 acabados dinámicamente
            for (int i = 0; i < 5; i++) ...[
              Row(
                children: [
                  Checkbox(
                    value: activo[i],
                    onChanged: (value) {
                      setState(() => activo[i] = value!);
                    },
                  ),
                  Text("Acabado Especial ${i + 1}:"),
                ],
              ),

              // Si está activo → muestra los campos
              if (activo[i]) ...[
                const SizedBox(height: 4),

                // CAMPO DESCRIPCIÓN
                const SizedBox(height: 4),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: widget.piezasPorPliegoController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Piezas",
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),

                const SizedBox(height: 8),

                // CAMPO COSTO
                const SizedBox(height: 4),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Costo Total",
                    border: OutlineInputBorder(),
                    prefixText: "\$ ",
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
