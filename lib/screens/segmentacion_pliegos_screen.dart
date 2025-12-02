import 'package:flutter/material.dart';


class SegmentacionPliegosScreen extends StatefulWidget {
  const SegmentacionPliegosScreen({super.key});

  @override
  State<SegmentacionPliegosScreen> createState() =>
      _SegmentacionPliegosScreenState();
}

class _SegmentacionPliegosScreenState
    extends State<SegmentacionPliegosScreen> {
  double trabajoAncho = 0;
  double trabajoAlto = 0;

  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();

  final List<Map<String, dynamic>> panels = [
    {"titulo": "Mitad del Pliego (4 Cartas)", "ancho": 57.0, "alto": 43.5},
    {"titulo": "Mitad del Pliego (4 Oficios)", "ancho": 70.0, "alto": 47.5},
    {"titulo": "Pliego Extendido (8 Cartas)", "ancho": 57.0, "alto": 87.0},
    {"titulo": "Pliego Extendido (8 Oficios)", "ancho": 70.0, "alto": 95.0},

    {"titulo": "Mitad del Pliego (4 Cartas)", "ancho": 61.0, "alto": 45.0},
    {"titulo": "Mitad del Pliego (4 Oficios)", "ancho": 72.0, "alto": 51.0},
    {"titulo": "Pliego Extendido (8 Cartas)", "ancho": 61.0, "alto": 90.0},
    {"titulo": "Pliego Extendido (8 Oficios)", "ancho": 72.0, "alto": 102.0},

    {"titulo": "Pliego Extendido (Couché 150g)", "ancho": 58.0, "alto": 88.0},

    // ► Especial editable
    {"titulo": "Medida Especial", "ancho": 0.0, "alto": 0.0, "especial": true},
  ];

  int calcularPiezas(double papAncho, double papAlto, bool invertido) {
    if (trabajoAncho <= 0 || trabajoAlto <= 0) return 0;

    return !invertido
        ? (papAncho ~/ trabajoAncho) * (papAlto ~/ trabajoAlto)
        : (papAncho ~/ trabajoAlto) * (papAlto ~/ trabajoAncho);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          // Panel principal
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Text(
                    "Medidas del Trabajo (cm): ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: anchoController,
                      decoration: const InputDecoration(
                        labelText: "Ancho",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: altoController,
                      decoration: const InputDecoration(
                        labelText: "Alto",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        trabajoAncho =
                            double.tryParse(anchoController.text) ?? 0;
                        trabajoAlto =
                            double.tryParse(altoController.text) ?? 0;
                      });
                    },
                    child: const Text("Calcular"),
                  ),
                ],
              ),
            ),
          ),

          // Grid de paneles
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: panels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (context, index) {
                final p = panels[index];
                final bool especial = p["especial"] == true;

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p["titulo"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),

                        const SizedBox(height: 6),
                        const Text(
                          "Medidas del papel (cm):",
                          style: TextStyle(fontSize: 12),
                        ),

                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: TextEditingController(
                                  text: p["ancho"] == 0
                                      ? ""
                                      : p["ancho"].toString(),
                                ),
                                enabled: especial,
                                decoration: const InputDecoration(
                                  labelText: "Ancho",
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: especial
                                    ? (v) {
                                        p["ancho"] =
                                            double.tryParse(v) ?? 0;
                                      }
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 8),

                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: TextEditingController(
                                  text: p["alto"] == 0
                                      ? ""
                                      : p["alto"].toString(),
                                ),
                                enabled: especial,
                                decoration: const InputDecoration(
                                  labelText: "Alto",
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: especial
                                    ? (v) {
                                        p["alto"] =
                                            double.tryParse(v) ?? 0;
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Text("Piezas normal:",
                            style: TextStyle(fontSize: 12)),

                        Row(
                          children: [
                            const Icon(Icons.arrow_downward,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 6),

                            Text(
                              trabajoAncho > 0
                                  ? "${(p["ancho"] ~/ trabajoAncho)}"
                                  : "-",
                              style: const TextStyle(fontSize: 13),
                            ),

                            const SizedBox(width: 12),
                            const Text("=", style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),

                            Text(
                              trabajoAncho > 0
                                  ? "${calcularPiezas(p["ancho"], p["alto"], false)}"
                                  : "-",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Text("Piezas invertido:",
                            style: TextStyle(fontSize: 12)),

                        Row(
                          children: [
                            const Icon(Icons.sync_alt,
                                color: Colors.green, size: 16),
                            const SizedBox(width: 6),

                            Text(
                              trabajoAlto > 0
                                  ? "${(p["ancho"] ~/ trabajoAlto)}"
                                  : "-",
                              style: const TextStyle(fontSize: 13),
                            ),

                            const SizedBox(width: 12),
                            const Text("=", style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 12),

                            Text(
                              trabajoAlto > 0
                                  ? "${calcularPiezas(p["ancho"], p["alto"], true)}"
                                  : "-",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),

                        if (especial) ...[
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text("Calcular especial"),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
