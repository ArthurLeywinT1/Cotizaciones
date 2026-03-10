import 'package:flutter/material.dart';

class PanelEmbalaje extends StatelessWidget {
  final List<String> items;
  final List<bool> activo;
  final List<TextEditingController> costoControllers;
  final List<TextEditingController> cantidadControllers;
  final List<TextEditingController> totalControllers;
  final Function(int) onCalcular;
  final Function(int, bool) onItemChanged;
  // 🔒 SOLO EMBALAJE

  const PanelEmbalaje({
    super.key,
    required this.items,
    required this.activo,
    required this.costoControllers,
    required this.cantidadControllers,
    required this.totalControllers,
    required this.onCalcular,
    required this.onItemChanged,
  });

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

            for (int i = 0; i < items.length; i++) ...[
              Row(
                children: [
                  Checkbox(
                    value: activo[i],
                    onChanged: (value) {
                      onItemChanged(i, value ?? false);
                    },
                  ),
                  Text(items[i]),
                ],
              ),

              if (activo[i]) ...[
                const SizedBox(height: 5),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costoControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Costo Unitario",
                          prefixText: "\$ ",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => onCalcular(i),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: TextField(
                        controller: cantidadControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Cantidad",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => onCalcular(i),
                      ),
                    ),

                    const SizedBox(width: 8),

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
        ),
      ),
    );
  }
}
