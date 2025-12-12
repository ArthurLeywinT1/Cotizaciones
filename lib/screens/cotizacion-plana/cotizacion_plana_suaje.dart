import 'package:flutter/material.dart';

class PanelSuaje extends StatefulWidget {
  final bool enabled;

  const PanelSuaje({super.key, required this.enabled});

  @override
  State<PanelSuaje> createState() => _PanelSuajeState();
}

class _PanelSuajeState extends State<PanelSuaje> {
  bool gastosEntrega = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ======================================================
            //     SECCIÓN SÚAJE (esta sí depende de enabled)
            // ======================================================
            Opacity(
              opacity: widget.enabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !widget.enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Datos Suaje, Suajado",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    const Text("Tamaño Suaje por Pieza (cm):"),
                    const SizedBox(height: 4),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("Costo del Suaje por cm:"),
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
                    const Text(
                      "Costo Total Suaje:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                    const Text("Costo Arreglo Suajado:"),
                    const SizedBox(height: 4),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Checkbox(value: false, onChanged: null),
                        Text("Duplicar Costo Suajado")
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "Costo Total Suajado:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),

            // ======================================================
            //       LOGÍSTICA (siempre activa)
            // ======================================================
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
                    "Logística",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: gastosEntrega,
                        onChanged: (value) {
                          setState(() {
                            gastosEntrega = value!;
                          });
                        },
                      ),
                      const Text("Gastos de Entrega:"),
                    ],
                  ),

                  const SizedBox(height: 4),
                  const Text("Costo:"),
                  const SizedBox(height: 4),

                  // Campo de costo: activado / desactivado dinámicamente
                  Opacity(
                    opacity: gastosEntrega ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: !gastosEntrega,
                      child: const TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixText: "\$ ",
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
