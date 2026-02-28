import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

class CotizacionPlanaSerigrafia extends ConsumerStatefulWidget {
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
  final TextEditingController totalNegativosController;

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
    required this.totalNegativosController,
  });

  @override
  ConsumerState<CotizacionPlanaSerigrafia> createState() =>
      _CotizacionPlanaSerigrafiaState();
}

class _CotizacionPlanaSerigrafiaState
    extends ConsumerState<CotizacionPlanaSerigrafia> {
  @override
  void initState() {
    super.initState();

    widget.piezasTotalesController.addListener(_actualizarEntradas);
    widget.costoMillarController.addListener(_calcularTotalEntrada);
    widget.cantidadTintasController.addListener(_calcularTotalTintas);
    widget.costoTintasController.addListener(_calcularTotalTintas);
    widget.cantidadNegativosController.addListener(_calcularTotalNegativos);
    widget.precioNegativoController.addListener(_calcularTotalNegativos);

    for (int i = 0; i < widget.anchoMarcos.length; i++) {
      widget.anchoMarcos[i].addListener(calcularTotalMarcos);
      widget.altoMarcos[i].addListener(calcularTotalMarcos);
      widget.precioMarcos[i].addListener(calcularTotalMarcos);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarCostosBD());
  }

  void _cargarCostosBD() {
    final extrasState = ref.read(extrasProvider);

    try {
      final extraNegativos = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'negativos',
      );
      final double valorActual =
          double.tryParse(widget.precioNegativoController.text) ?? 0.0;
      if (valorActual == 0) {
        widget.precioNegativoController.text = (extraNegativos.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    try {
      final extraTinta = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'tinta serigrafia',
      );
      final double valorActual =
          double.tryParse(widget.costoTintasController.text) ?? 0.0;
      if (valorActual == 0) {
        widget.costoTintasController.text = (extraTinta.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    try {
      final extraMillar = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'entrada suaje por millar',
      );
      final double valorActual =
          double.tryParse(widget.costoMillarController.text) ?? 0.0;
      if (valorActual == 0) {
        widget.costoMillarController.text = (extraMillar.costoFijo ?? 0.0)
            .toStringAsFixed(2);
      }
    } catch (_) {}

    try {
      final extraMarco = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'marco serigrafia',
      );
      final double costoCm2Marco = extraMarco.costoCm2 ?? 0.0;

      for (var ctrl in widget.precioMarcos) {
        final double valorActual = double.tryParse(ctrl.text) ?? 0.0;
        if (valorActual == 0) {
          ctrl.text = costoCm2Marco.toStringAsFixed(2);
        }
      }
    } catch (_) {}

    _calcularTotalEntrada();
    _calcularTotalTintas();
    calcularTotalMarcos();
    _calcularTotalNegativos();
  }

  // =====================================================
  // ENTRADAS
  // =====================================================

  void _actualizarEntradas() {
    widget.numeroEntradasController.text = widget.piezasTotalesController.text;
    _calcularTotalEntrada();
  }

  void _calcularTotalEntrada() {
    final entradas = double.tryParse(widget.numeroEntradasController.text) ?? 0;
    final costoMillar = double.tryParse(widget.costoMillarController.text) ?? 0;

    final total = (entradas / 1000) * costoMillar;
    widget.totalEntradaController.text = total.toStringAsFixed(2);
  }

  // =====================================================
  // MARCOS
  // =====================================================

  void actualizarMarcos() {
    final cantidad = int.tryParse(widget.cantidadMarcosController.text) ?? 0;

    final extrasState = ref.read(extrasProvider);
    double costoCm2Marco = 0.0;
    try {
      final extraMarco = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'marco serigrafia',
      );
      costoCm2Marco = extraMarco.costoCm2 ?? 0.0;
    } catch (_) {}

    setState(() {
      if (cantidad > widget.anchoMarcos.length) {
        for (int i = widget.anchoMarcos.length; i < cantidad; i++) {
          final anchoCtrl = TextEditingController();
          final altoCtrl = TextEditingController();
          final precioCtrl = TextEditingController(
            text: costoCm2Marco.toStringAsFixed(2),
          );

          anchoCtrl.addListener(calcularTotalMarcos);
          altoCtrl.addListener(calcularTotalMarcos);
          precioCtrl.addListener(calcularTotalMarcos);

          widget.anchoMarcos.add(anchoCtrl);
          widget.altoMarcos.add(altoCtrl);
          widget.precioMarcos.add(precioCtrl);
        }
      } else if (cantidad < widget.anchoMarcos.length) {
        for (int i = widget.anchoMarcos.length - 1; i >= cantidad; i--) {
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

    for (int i = 0; i < widget.precioMarcos.length; i++) {
      final double ancho = double.tryParse(widget.anchoMarcos[i].text) ?? 0;
      final double alto = double.tryParse(widget.altoMarcos[i].text) ?? 0;
      final double costoUnidad =
          double.tryParse(widget.precioMarcos[i].text) ?? 0;

      total += (ancho * alto * costoUnidad);
    }

    widget.totalMarcosController.text = total.toStringAsFixed(2);
  }


    void _calcularTotalNegativos() {
      final cantidad =
          double.tryParse(widget.cantidadNegativosController.text) ?? 0;

      final precio =
          double.tryParse(widget.precioNegativoController.text) ?? 0;

      final total = cantidad * precio;

      widget.totalNegativosController.text =
          total.toStringAsFixed(2);
    }

  // =====================================================
  // TINTAS
  // =====================================================

  void _calcularTotalTintas() {
    final cantidad = double.tryParse(widget.cantidadTintasController.text) ?? 0;
    final costo = double.tryParse(widget.costoTintasController.text) ?? 0;

    final total = cantidad * costo;
    widget.totalTintasController.text = total.toStringAsFixed(2);
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    widget.piezasTotalesController.removeListener(_actualizarEntradas);
    widget.costoMillarController.removeListener(_calcularTotalEntrada);
    widget.cantidadTintasController.removeListener(_calcularTotalTintas);
    widget.costoTintasController.removeListener(_calcularTotalTintas);
    widget.cantidadNegativosController.removeListener(_calcularTotalNegativos);
    widget.precioNegativoController.removeListener(_calcularTotalNegativos);
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) => _cargarCostosBD());

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            campo(
              "Cantidad de Marcos",
              widget.cantidadMarcosController,
              onChanged: (_) => actualizarMarcos(),
            ),

            const SizedBox(height: 10),

            ...List.generate(widget.anchoMarcos.length, (index) {
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
                    child: campo("Alto ${index + 1}", widget.altoMarcos[index]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: campo(
                      readOnly: true,
                      "Precio ${index + 1}",
                      widget.precioMarcos[index], //precio en extras
                    ),
                  ),
                ],
              );
            }),

            campo("Total Marcos", widget.totalMarcosController, readOnly: true),

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
                    readOnly: true
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Total Negativos",
                    widget.totalNegativosController,
                    readOnly: true,
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
                    widget.cantidadTintasController, //precio en extras
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    "Costo por Tinta",
                    widget.costoTintasController,
                    readOnly: true,
                  ), //precio en extras
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
                  child: campo("# de Entrada", widget.numeroEntradasController),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: campo(
                    readOnly: true,
                    "Costo por Millar",
                    widget.costoMillarController, //precio en extras
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
