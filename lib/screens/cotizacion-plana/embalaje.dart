import 'package:flutter/material.dart';

class PanelEmbalaje extends StatefulWidget {
  const PanelEmbalaje({super.key});

  @override
  State<PanelEmbalaje> createState() => _PanelEmbalajeState();
}

class _PanelEmbalajeState extends State<PanelEmbalaje> {
  bool embalajeActivo = false;

  final List<String> items = [
    "Cajas",
    "Envoltura",
    "Cinta canela",
    "Ligas",
    "Celofán",
    "Cinta diurex",
    "Otro",
  ];

  final List<bool> activo = List.generate(7, (_) => false);
  final List<TextEditingController> costoControllers =
      List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> cantidadControllers =
      List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> totalControllers =
      List.generate(7, (_) => TextEditingController());

  void calcularTotal(int index) {
    final costo =
        double.tryParse(costoControllers[index].text) ?? 0.0;
    final cantidad =
        double.tryParse(cantidadControllers[index].text) ?? 0.0;

    final total = costo * cantidad;

    totalControllers[index].text = total.toStringAsFixed(2);
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
              "Embalaje",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// CHECKBOX PRINCIPAL
            Row(
              children: [
                Checkbox(
                  value: embalajeActivo,
                  onChanged: (value) {
                    setState(() {
                      embalajeActivo = value!;
                    });
                  },
                ),
                const Text("Embalaje"),
              ],
            ),

            /// SI SE ACTIVA EMBALAJE
            if (embalajeActivo) ...[
              const SizedBox(height: 10),

              for (int i = 0; i < items.length; i++) ...[
                Row(
                  children: [
                    Checkbox(
                      value: activo[i],
                      onChanged: (value) {
                        setState(() {
                          activo[i] = value!;
                        });
                      },
                    ),
                    Text(items[i]),
                  ],
                ),

                /// SI SE ACTIVA EL ITEM
                if (activo[i]) ...[
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      /// COSTO UNITARIO
                      Expanded(
                        child: TextField(
                          controller: costoControllers[i],
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: "Costo Unitario",
                            prefixText: "\$ ",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => calcularTotal(i),
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// CANTIDAD
                      Expanded(
                        child: TextField(
                          controller: cantidadControllers[i],
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: "Cantidad",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => calcularTotal(i),
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// TOTAL
                      Expanded(
                        child: TextField(
                          controller: totalControllers[i],
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Total",
                            prefixText: "\$ ",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 15),
              ],
            ],
          ],
        ),
      ),
    );
  }
}