import 'package:flutter/material.dart';

class CotizacionPlanaSerigrafia extends StatefulWidget {
  final TextEditingController piezasTotalesController;

  // =============================
  // MARCOS
  // =============================
  final TextEditingController cantidadMarcosController;
  final TextEditingController totalMarcosController;
  final List<TextEditingController> anchoMarcos;
  final List<TextEditingController> altoMarcos;
  final List<TextEditingController> precioMarcos;

  // =============================
  // NEGATIVOS
  // =============================
  final TextEditingController cantidadNegativosController;
  final TextEditingController precioNegativoController;

  // =============================
  // TINTAS
  // =============================
  final TextEditingController cantidadTintasController;
  final TextEditingController costoTintasController;
  final TextEditingController totalTintasController;

  // =============================
  // ENTRADAS
  // =============================
  final TextEditingController numeroEntradasController;
  final TextEditingController costoMillarController;
  final TextEditingController totalEntradaController;

  const CotizacionPlanaSerigrafia({
    super.key,
    required this.piezasTotalesController,

    required this.cantidadMarcosController,
    required this.totalMarcosController,
    required this.anchoMarcos,
    required this.altoMarcos,
    required this.precioMarcos,

    required this.cantidadNegativosController,
    required this.precioNegativoController,

    required this.cantidadTintasController,
    required this.costoTintasController,
    required this.totalTintasController,

    required this.numeroEntradasController,
    required this.costoMillarController,
    required this.totalEntradaController,
  });

  @override
  State<CotizacionPlanaSerigrafia> createState() =>
      _CotizacionPlanaSerigrafiaState();
}

class _CotizacionPlanaSerigrafiaState
    extends State<CotizacionPlanaSerigrafia> {

  @override
  void initState() {
    super.initState();

    widget.piezasTotalesController.addListener(_actualizarEntradas);
    widget.costoMillarController.addListener(_calcularTotalEntrada);
    widget.cantidadTintasController.addListener(_calcularTotalTintas);
    widget.costoTintasController.addListener(_calcularTotalTintas);
  }

  // =====================================================
  // ENTRADAS
  // =====================================================

  void _actualizarEntradas() {
    widget.numeroEntradasController.text =
        widget.piezasTotalesController.text;

    _calcularTotalEntrada();
  }

  void _calcularTotalEntrada() {
    final entradas =
        double.tryParse(widget.numeroEntradasController.text) ?? 0;

    final costoMillar =
        double.tryParse(widget.costoMillarController.text) ?? 0;

    final total = (entradas / 1000) * costoMillar;

    widget.totalEntradaController.text =
        total.toStringAsFixed(2);
  }

  // =====================================================
  // MARCOS
  // =====================================================

  void actualizarMarcos() {
    final cantidad =
        int.tryParse(widget.cantidadMarcosController.text) ?? 0;

    setState(() {
      if (cantidad > widget.anchoMarcos.length) {
        for (int i = widget.anchoMarcos.length;
            i < cantidad;
            i++) {

          widget.anchoMarcos.add(TextEditingController());
          widget.altoMarcos.add(TextEditingController());

          final precioController =
              TextEditingController();

          precioController.addListener(calcularTotalMarcos);

          widget.precioMarcos.add(precioController);
        }
      } else if (cantidad < widget.anchoMarcos.length) {
        for (int i = widget.anchoMarcos.length - 1;
            i >= cantidad;
            i--) {

          widget.anchoMarcos[i].dispose();
          widget.altoMarcos[i].dispose();
          widget.precioMarcos[i].dispose();

          widget.anchoMarcos.removeAt(i);
          widget.altoMarcos.removeAt(i);
          widget.precioMarcos.removeAt(i);
        }
      }

      calcularTotalMarcos();
    });
  }

  void calcularTotalMarcos() {
    double total = 0;

    for (var controller in widget.precioMarcos) {
      total += double.tryParse(controller.text) ?? 0;
    }

    widget.totalMarcosController.text =
        total.toStringAsFixed(2);
  }

  // =====================================================
  // TINTAS
  // =====================================================

  void _calcularTotalTintas() {
    final cantidad =
        double.tryParse(widget.cantidadTintasController.text) ?? 0;

    final costo =
        double.tryParse(widget.costoTintasController.text) ?? 0;

    final total = cantidad * costo;

    widget.totalTintasController.text =
        total.toStringAsFixed(2);
  }

  // =====================================================
  // CAMPO
  // =====================================================

  Widget campo(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.piezasTotalesController
        .removeListener(_actualizarEntradas);

    widget.costoMillarController
        .removeListener(_calcularTotalEntrada);

    widget.cantidadTintasController
        .removeListener(_calcularTotalTintas);

    widget.costoTintasController
        .removeListener(_calcularTotalTintas);

    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "SERIGRAFÍA",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            campo(
              "Cantidad de Marcos",
              widget.cantidadMarcosController,
              onChanged: (_) => actualizarMarcos(),
            ),

            const SizedBox(height: 10),

            ...List.generate(
              widget.anchoMarcos.length,
              (index) {
                return Row(
                  children: [
                    Expanded(
                      child: campo(
                        "Ancho ${index + 1}",
                        widget.anchoMarcos[index],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: campo(
                        "Alto ${index + 1}",
                        widget.altoMarcos[index],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: campo(
                        "Precio ${index + 1}",
                        widget.precioMarcos[index],
                      ),
                    ),
                  ],
                );
              },
            ),

            campo(
              "Total Marcos",
              widget.totalMarcosController,
              readOnly: true,
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: campo(
                    "Cantidad Negativos",
                    widget.cantidadNegativosController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Precio Negativo",
                    widget.precioNegativoController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: campo(
                    "Cantidad Tintas",
                    widget.cantidadTintasController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Costo por Tinta",
                    widget.costoTintasController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Total Tintas",
                    widget.totalTintasController,
                    readOnly: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: campo(
                    "# de Entrada",
                    widget.numeroEntradasController,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Costo por Millar",
                    widget.costoMillarController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Total por Entrada",
                    widget.totalEntradaController,
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}