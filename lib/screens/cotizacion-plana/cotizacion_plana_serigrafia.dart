import 'package:flutter/material.dart';

class CotizacionPlanaSerigrafia extends StatefulWidget {
  final TextEditingController piezasTotalesController;

  const CotizacionPlanaSerigrafia({
    super.key,
    required this.piezasTotalesController,
  });

  @override
  State<CotizacionPlanaSerigrafia> createState() =>
      _CotizacionPlanaSerigrafiaState();
}

class _CotizacionPlanaSerigrafiaState
    extends State<CotizacionPlanaSerigrafia> {

  // =============================
  // MARCOS
  // =============================

  final TextEditingController cantidadMarcosController =
      TextEditingController();

  final TextEditingController totalMarcosController =
      TextEditingController();

  List<TextEditingController> anchoMarcos = [];
  List<TextEditingController> altoMarcos = [];
  List<TextEditingController> precioMarcos = [];

  // =============================
  // NEGATIVOS
  // =============================

  final TextEditingController cantidadNegativosController =
      TextEditingController();
  final TextEditingController precioNegativoController =
      TextEditingController();

  // =============================
  // TINTAS
  // =============================

  final TextEditingController cantidadTintasController =
      TextEditingController();
  final TextEditingController costoTintasController =
      TextEditingController();
  final TextEditingController totalTintasController =
      TextEditingController();

  // =============================
  // ENTRADAS (AUTOMÁTICO)
  // =============================

  final TextEditingController numeroEntradasController =
      TextEditingController();
  final TextEditingController costoMillarController =
      TextEditingController();
  final TextEditingController totalEntradaController =
      TextEditingController();

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    /// Escucha piezas totales
    widget.piezasTotalesController.addListener(_actualizarEntradas);

    /// Escucha costo millar para recalcular total
    costoMillarController.addListener(_calcularTotalEntrada);
  }

  // =====================================================
  // ACTUALIZAR # ENTRADAS AUTOMÁTICO
  // =====================================================

  void _actualizarEntradas() {
    numeroEntradasController.text =
        widget.piezasTotalesController.text;

    _calcularTotalEntrada();
  }

  // =====================================================
  // CALCULAR TOTAL ENTRADA
  // Formula: (Entradas / 1000) * CostoMillar
  // =====================================================

  void _calcularTotalEntrada() {
    final entradas =
        double.tryParse(numeroEntradasController.text) ?? 0;

    final costoMillar =
        double.tryParse(costoMillarController.text) ?? 0;

    final total = (entradas / 1000) * costoMillar;

    totalEntradaController.text = total.toStringAsFixed(2);
  }

  // =====================================================
  // ACTUALIZAR MARCOS DINÁMICAMENTE
  // =====================================================

  void actualizarMarcos() {
    final cantidad = int.tryParse(cantidadMarcosController.text) ?? 0;

    setState(() {
      if (cantidad > anchoMarcos.length) {
        for (int i = anchoMarcos.length; i < cantidad; i++) {
          anchoMarcos.add(TextEditingController());
          altoMarcos.add(TextEditingController());

          final precioController = TextEditingController();
          precioController.addListener(calcularTotalMarcos);
          precioMarcos.add(precioController);
        }
      } else if (cantidad < anchoMarcos.length) {
        for (int i = anchoMarcos.length - 1; i >= cantidad; i--) {
          anchoMarcos[i].dispose();
          altoMarcos[i].dispose();
          precioMarcos[i].dispose();

          anchoMarcos.removeAt(i);
          altoMarcos.removeAt(i);
          precioMarcos.removeAt(i);
        }
      }

      calcularTotalMarcos();
    });
  }

  // =====================================================
  // CALCULAR TOTAL MARCOS
  // =====================================================

  void calcularTotalMarcos() {
    double total = 0;

    for (var controller in precioMarcos) {
      total += double.tryParse(controller.text) ?? 0;
    }

    totalMarcosController.text = total.toStringAsFixed(2);
  }

  // =====================================================
  // WIDGET CAMPO
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

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    widget.piezasTotalesController
        .removeListener(_actualizarEntradas);

    costoMillarController
        .removeListener(_calcularTotalEntrada);

    cantidadMarcosController.dispose();
    totalMarcosController.dispose();

    for (var c in anchoMarcos) {
      c.dispose();
    }
    for (var c in altoMarcos) {
      c.dispose();
    }
    for (var c in precioMarcos) {
      c.dispose();
    }

    cantidadNegativosController.dispose();
    precioNegativoController.dispose();
    cantidadTintasController.dispose();
    costoTintasController.dispose();
    totalTintasController.dispose();
    numeroEntradasController.dispose();
    costoMillarController.dispose();
    totalEntradaController.dispose();

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
        mainAxisSize: MainAxisSize.min,
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


          // =============================
          // MARCOS
          // =============================

          campo(
            "Cantidad de Marcos",
            cantidadMarcosController,
            onChanged: (_) => actualizarMarcos(),
          ),

          const SizedBox(height: 10),

          ...List.generate(anchoMarcos.length, (index) {
            return Row(
              children: [
                Expanded(
                  child: campo(
                    "Ancho ${index + 1}",
                    anchoMarcos[index],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Alto ${index + 1}",
                    altoMarcos[index],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Precio ${index + 1}",
                    precioMarcos[index],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 10),

          campo(
            "Total Marcos",
            totalMarcosController,
            readOnly: true,
          ),

          const SizedBox(height: 30),

          // =============================
          // NEGATIVOS
          // =============================

          Row(
            children: [
              Expanded(
                child: campo(
                  "Cantidad Negativos",
                  cantidadNegativosController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: campo(
                  "Precio Negativo",
                  precioNegativoController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // =============================
          // TINTAS
          // =============================

          Row(
            children: [
              Expanded(
                child: campo(
                  "Cantidad Tintas",
                  cantidadTintasController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: campo(
                  "Costo por Tinta",
                  costoTintasController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: campo(
                  "Total Tintas",
                  totalTintasController,
                  readOnly: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),


          // =============================
          // ENTRADAS
          // =============================

          Row(
            children: [
              Expanded(
                child: campo(
                  "# de Entrada",
                  numeroEntradasController,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: campo(
                  "Costo por Millar",
                  costoMillarController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: campo(
                  "Total por Entrada",
                  totalEntradaController,
                  readOnly: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),


          ],
        ),
      ),
    );
  }
}