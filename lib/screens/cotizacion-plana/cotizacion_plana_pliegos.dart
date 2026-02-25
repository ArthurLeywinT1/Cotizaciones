import 'package:flutter/material.dart';
import '../segmentacion_pliegos_screen.dart';
// Panel específico para el cálculo de pliegos
class PanelPliegos extends StatefulWidget {
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;

  final TextEditingController pliegoAnchoController;
  final TextEditingController pliegoAltoController;

  final TextEditingController posicionPiezasController;
  final TextEditingController piezasPorPliegoController;
  final TextEditingController tamanoPorPliegoController;

  final TextEditingController cantidadImpresionesController;
  final TextEditingController cantidadPliegosController;
  final TextEditingController pliegosSobrantesController;
  final TextEditingController totalPliegosController;
  final TextEditingController millaresController;

  const PanelPliegos({
    super.key,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.pliegoAnchoController,
    required this.pliegoAltoController,
    required this.posicionPiezasController,
    required this.piezasPorPliegoController,
    required this.tamanoPorPliegoController,
    required this.cantidadImpresionesController,
    required this.cantidadPliegosController,
    required this.pliegosSobrantesController,
    required this.totalPliegosController,
    required this.millaresController,
  });

  @override
  State<PanelPliegos> createState() => _PanelPliegosState();
}

class _PanelPliegosState extends State<PanelPliegos> {
  /// Pliegos extra seleccionados
  int pliegosExtraSeleccionados = 0;

  /// ===============================
  /// CÁLCULO DE PLIEGOS
  /// ===============================
  void _calcularPliegos() {
    final int impresiones =
        int.tryParse(widget.cantidadImpresionesController.text) ?? 0;

    final int piezasPorPliego =
        int.tryParse(widget.piezasPorPliegoController.text) ?? 0;

    if (impresiones <= 0 || piezasPorPliego <= 0) {
      widget.cantidadPliegosController.text = "0";
      widget.pliegosSobrantesController.text = "0";
      widget.totalPliegosController.text = "0";
      widget.millaresController.text = "0.00";
      return;
    }

    final int pliegosEnteros = impresiones ~/ piezasPorPliego;
    final bool haySobrante = impresiones % piezasPorPliego > 0;
    final int sobrante = haySobrante ? 1 : 0;

    final int totalPliegos =
        pliegosEnteros + sobrante + pliegosExtraSeleccionados;

    widget.cantidadPliegosController.text = pliegosEnteros.toString();
    widget.pliegosSobrantesController.text = sobrante.toString();
    widget.totalPliegosController.text = totalPliegos.toString();
    widget.millaresController.text = (totalPliegos / 1000).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Datos del Pliego",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            /// MEDIDAS DEL PLIEGO + LUPA
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.pliegoAnchoController,
                    decoration: const InputDecoration(
                      labelText: "Ancho pliego",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.pliegoAltoController,
                    decoration: const InputDecoration(
                      labelText: "Alto pliego",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: "Ver segmentación",
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SegmentacionPliegosScreen(
                          anchoTrabajo:
                              double.tryParse(
                                widget.anchoFinalController.text,
                              ) ??
                              0,
                          altoTrabajo:
                              double.tryParse(
                                widget.altoFinalController.text,
                              ) ??
                              0,
                        ),
                      ),
                    );

                    if (result != null) {
                      widget.pliegoAnchoController.text = result["ancho"]
                          .toString();
                      widget.pliegoAltoController.text = result["alto"]
                          .toString();
                      widget.piezasPorPliegoController.text =
                          result["piezasPorPliego"].toString();
                      widget.posicionPiezasController.text = result["posicion"];
                      widget.tamanoPorPliegoController.text =
                          "${widget.anchoFinalController.text} x ${widget.altoFinalController.text}";

                      _calcularPliegos();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.posicionPiezasController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.piezasPorPliegoController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Piezas por pliego",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: widget.tamanoPorPliegoController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Tamaño del trabajo",
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const Divider(height: 30),

            /// PLIEGOS EXTRA
            const Text(
              "Pliegos Extra por Producción",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              value: pliegosExtraSeleccionados,
              decoration: const InputDecoration(
                labelText: "Seleccionar pliegos extra",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text("0")),
                DropdownMenuItem(value: 50, child: Text("50")),
                DropdownMenuItem(value: 100, child: Text("100")),
                DropdownMenuItem(value: 150, child: Text("150")),
                DropdownMenuItem(value: 200, child: Text("200")),
                DropdownMenuItem(value: 250, child: Text("250")),
                DropdownMenuItem(value: 300, child: Text("300")),
              ],
              onChanged: (value) {
                setState(() {
                  pliegosExtraSeleccionados = value ?? 0;
                });
                _calcularPliegos();
              },
            ),

            const Divider(height: 30),

            /// RESULTADOS DE PLIEGOS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.cantidadPliegosController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Cantidad de Pliegos",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.pliegosSobrantesController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Pliegos Sobrantes",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: widget.totalPliegosController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Total de Pliegos a Utilizar",
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: widget.millaresController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Millares a Imprimir",
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFEEEEEE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
