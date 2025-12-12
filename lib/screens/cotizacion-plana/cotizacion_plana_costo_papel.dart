import 'package:flutter/material.dart';

class PanelCostoPapel extends StatelessWidget {
  const PanelCostoPapel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO PRINCIPAL
            const Text(
              "Costos del Papel a Usar:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // CAMPO: Costo Papel sin descuento
            const Text("Costo Papel Sin Descuento:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 20),

            // ===========================================
            // SECCIÓN "Datos Solo Administrador"
            // ===========================================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Datos Solo Administrador",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (_) {},
                      ),
                      const Text("Usar el Descuento General del Papel"),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text("Descuento a Aplicar: "),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          enabled: false, // DESHABILITADO como en la imagen
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
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

            const SizedBox(height: 20),

            // COSTO SIN IVA
            const Text("Costo Papel Sin IVA:"),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 16),

            // COSTO CON IVA (TITULO EN NEGRITAS)
            const Text(
              "Costo Papel Con IVA:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                prefixText: "\$ ",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
