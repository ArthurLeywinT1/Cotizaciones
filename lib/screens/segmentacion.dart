import 'package:flutter/material.dart';

class SegmentacionPliegosScreen extends StatefulWidget {
  final double anchoTrabajo;
  final double altoTrabajo;

  const SegmentacionPliegosScreen({
    super.key,
    this.anchoTrabajo = 0,
    this.altoTrabajo = 0,
  });

  bool get desdeCotizacion => anchoTrabajo > 0 && altoTrabajo > 0;

  @override
  State<SegmentacionPliegosScreen> createState() =>
      _SegmentacionPliegosScreenState();
}

class _SegmentacionPliegosScreenState extends State<SegmentacionPliegosScreen> {
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
    {"titulo": "Medida Especial", "ancho": 0.0, "alto": 0.0, "especial": true},
  ];

  int calcularPiezas(double papAncho, double papAlto, bool invertido) {
    if (trabajoAncho <= 0 || trabajoAlto <= 0) return 0;

    return !invertido
        ? (papAncho ~/ trabajoAncho) * (papAlto ~/ trabajoAlto)
        : (papAncho ~/ trabajoAlto) * (papAlto ~/ trabajoAncho);
  }

  @override
  void initState() {
    super.initState();
    trabajoAncho = widget.anchoTrabajo;
    trabajoAlto = widget.altoTrabajo;

    if (widget.anchoTrabajo > 0) {
      anchoController.text = widget.anchoTrabajo.toString();
    }
    if (widget.altoTrabajo > 0) {
      altoController.text = widget.altoTrabajo.toString();
    }
  }

  @override
  void dispose() {
    anchoController.dispose();
    altoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DETECTAMOS EL ANCHO DE LA PANTALLA
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final bool esDesktop = anchoPantalla > 750;

    final compatibles = panels.where((p) {
      if (p["especial"] == true) return true;
      if (trabajoAncho <= 0 || trabajoAlto <= 0) return true;

      final anchoPliego = (p["ancho"] as num).toDouble();
      final altoPliego = (p["alto"] as num).toDouble();

      return (anchoPliego >= trabajoAncho && altoPliego >= trabajoAlto) ||
          (anchoPliego >= trabajoAlto && altoPliego >= trabajoAncho);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Segmentación de Pliegos")),
      backgroundColor: Colors.grey[200],
      // Envolvemos la columna principal en un SingleChildScrollView para asegurar el scroll en móviles
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.desdeCotizacion)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade400,
                child: const Text(
                  "⚠️ La selección de pliegos solo se permite desde Cotización",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            /// PANEL MEDIDAS DEL TRABAJO (ADAPTATIVO)
            Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                // Si es Desktop usa Row, si es móvil muta a un Wrap para no desbordar a la derecha
                child: esDesktop
                    ? Row(
                        children: _construirFilaMedidas(),
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: _construirFilaMedidas(),
                      ),
              ),
            ),

            /// CONTENEDOR DE LA CUADRÍCULA (RESPONSIVA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true, // Permite que conviva dentro del SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Delega el scroll al padre
                itemCount: compatibles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  // 3 columnas en PC, 2 en pantallas medianas, 1 sola columna en celular
                  crossAxisCount: anchoPantalla > 950 ? 3 : (anchoPantalla > 600 ? 2 : 1),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  // Reemplazamos childAspectRatio por una altura fija (mainAxisExtent) para que no se aplasten
                  mainAxisExtent: 210, 
                ),
                itemBuilder: (context, index) {
                  final p = compatibles[index];
                  final bool especial = p["especial"] == true;

                  final piezasNormal = calcularPiezas(
                    (p["ancho"] as num).toDouble(),
                    (p["alto"] as num).toDouble(),
                    false,
                  );

                  final piezasInvertido = calcularPiezas(
                    (p["ancho"] as num).toDouble(),
                    (p["alto"] as num).toDouble(),
                    true,
                  );

                  return InkWell(
                    onTap: () async {
                      if (!widget.desdeCotizacion) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "❗ Solo puedes seleccionar un pliego si vienes desde Cotización",
                            ),
                          ),
                        );
                        return;
                      }

                      if (especial && (p["ancho"] == 0 || p["alto"] == 0)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Introduce las medidas en 'Medida Especial'",
                            ),
                          ),
                        );
                        return;
                      }

                      final opcion = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Seleccionar orientación"),
                          content: const Text(
                            "¿Cómo deseas acomodar las piezas?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, "Normal"),
                              child: Text("Normal ($piezasNormal piezas)"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, "Invertido"),
                              child: Text("Invertido ($piezasInvertido piezas)"),
                            ),
                          ],
                        ),
                      );

                      if (opcion == null) return;

                      final piezasSeleccionadas = opcion == "Normal"
                          ? piezasNormal
                          : piezasInvertido;

                      Navigator.pop(context, {
                        "nombre": p["titulo"],
                        "ancho": p["ancho"],
                        "alto": p["alto"],
                        "piezasPorPliego": piezasSeleccionadas,
                        "posicion": opcion,
                      });
                    },

                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p["titulo"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              "Medidas del papel (cm):",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            
                            Row(
                              children: [
                                Expanded(
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
                                    keyboardType: TextInputType.number,
                                    onChanged: especial
                                        ? (v) {
                                            setState(() {
                                              p["ancho"] =
                                                  double.tryParse(v) ?? 0;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
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
                                    keyboardType: TextInputType.number,
                                    onChanged: especial
                                        ? (v) {
                                            setState(() {
                                              p["alto"] = double.tryParse(v) ?? 0;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 10),

                            // Bloque de piezas Normal
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                                const SizedBox(width: 6),
                                const Text("Piezas normal: ", style: TextStyle(fontSize: 12)),
                                const Spacer(),
                                Text(
                                  trabajoAncho > 0 ? "$piezasNormal" : "-",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            // Bloque de piezas Invertido
                            Row(
                              children: [
                                const Icon(Icons.sync_alt, color: Colors.green, size: 16),
                                const SizedBox(width: 6),
                                const Text("Piezas invertido: ", style: TextStyle(fontSize: 12)),
                                const Spacer(),
                                Text(
                                  trabajoAlto > 0 ? "$piezasInvertido" : "-",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Método modular para generar los widgets de control superiores sin duplicar código
  List<Widget> _construirFilaMedidas() {
    return [
      const Text(
        "Medidas del Trabajo (cm): ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 90,
        child: TextField(
          controller: anchoController,
          decoration: const InputDecoration(
            labelText: "Ancho",
            isDense: true,
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            setState(() {
              trabajoAncho = double.tryParse(v) ?? 0;
            });
          },
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 90,
        child: TextField(
          controller: altoController,
          decoration: const InputDecoration(
            labelText: "Alto",
            isDense: true,
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            setState(() {
              trabajoAlto = double.tryParse(v) ?? 0;
            });
          },
        ),
      ),
      const SizedBox(width: 12),
      ElevatedButton.icon(
        icon: const Icon(Icons.calculate, size: 18),
        onPressed: () {
          setState(() {
            trabajoAncho = double.tryParse(anchoController.text) ?? 0;
            trabajoAlto = double.tryParse(altoController.text) ?? 0;
          });
        },
        label: const Text("Calcular"),
      ),
    ];
  }
}