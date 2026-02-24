import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

class PanelLaminados extends ConsumerStatefulWidget {
  final bool readOnly;

  final Map<String, Map<String, bool>> laminados;
  final TextEditingController pliegoAnchoController;
  final TextEditingController pliegoAltoController;
  final TextEditingController totalPliegosController;
  final Map<String, TextEditingController> controllersCostoCm2;
  final Map<String, TextEditingController> controllersCostoTotal;
  final TextEditingController cantidadImpresionController;
  final bool isOffset;

  final void Function(String nombre, String lado, bool valor) onLaminadoChanged;

  const PanelLaminados({
    super.key,
    required this.readOnly,
    required this.laminados,
    required this.pliegoAnchoController,
    required this.pliegoAltoController,
    required this.totalPliegosController,
    required this.controllersCostoCm2,
    required this.controllersCostoTotal,
    required this.onLaminadoChanged,
    required this.cantidadImpresionController,
    required this.isOffset,
  });

  @override
  ConsumerState<PanelLaminados> createState() => _PanelLaminadosState();
}

class _PanelLaminadosState extends ConsumerState<PanelLaminados> {
  /// 🔒 SOLO LAMINADOS
  final Set<String> laminadosPermitidos = {
    "Plastificado Brillante",
    "Plastificado Mate",
  };

  late Map<String, bool> frente;
  late Map<String, bool> vuelta;

  Map<String, double> costosMinimos = {};

  @override
  void initState() {
    super.initState();
    _sincronizarEstadoLocal();

    widget.pliegoAnchoController.addListener(_recalcularTodos);
    widget.pliegoAltoController.addListener(_recalcularTodos);
    widget.totalPliegosController.addListener(_recalcularTodos);
    widget.cantidadImpresionController.addListener(_recalcularTodos);

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarPreciosDeBD());
  }

  void _sincronizarEstadoLocal() {
    frente = {};
    vuelta = {};

    for (final nombre in laminadosPermitidos) {
      final data = widget.laminados[nombre];
      frente[nombre] = data?["frente"] ?? false;
      vuelta[nombre] = data?["vuelta"] ?? false;
    }
  }

  void _cargarPreciosDeBD() {
    final extrasState = ref.read(extrasProvider);

    for (final nombre in laminadosPermitidos) {
      try {
        final extra = extrasState.extras.firstWhere(
          (e) => e.nombre.trim().toLowerCase() == nombre.trim().toLowerCase(),
        );

        if (extra.costoCm2 != null) {
          widget.controllersCostoCm2[nombre]?.text = (extra.costoCm2 ?? 0)
              .toString();
        }

        costosMinimos[nombre] = extra.costoMinimoTotal ?? 0.0;
        _calcularCostoIndividual(nombre);
      } catch (e) {
        costosMinimos[nombre] = 0.0;
        debugPrint("No se encontró laminado: $nombre");
      }
    }
  }

  void _recalcularTodos() {
    for (final nombre in laminadosPermitidos) {
      _calcularCostoIndividual(nombre);
    }
  }

  void _calcularCostoIndividual(String titulo) {
    final double ancho =
        double.tryParse(widget.pliegoAnchoController.text) ?? 0.0;
    final double alto =
        double.tryParse(widget.pliegoAltoController.text) ?? 0.0;
    final double totalPliegos =
        double.tryParse(widget.totalPliegosController.text) ?? 0.0;
    final double costoCm2 =
        double.tryParse(widget.controllersCostoCm2[titulo]?.text ?? "0") ?? 0.0;
    final double cantidadImpresion =
        double.tryParse(widget.cantidadImpresionController.text) ?? 0.0;

    final int lados =
        (frente[titulo] == true ? 1 : 0) + (vuelta[titulo] == true ? 1 : 0);

    double costoCalculado = 0.0;

    if (widget.isOffset) {
      costoCalculado =
          cantidadImpresion * (ancho * .01) * (alto * .01) * costoCm2 * lados;
    } else {
      final double areaUnitariaxLados = (ancho * .01 * alto * .01) * lados;
      costoCalculado = areaUnitariaxLados * costoCm2 * totalPliegos;
    }

    final double costoMinimo = costosMinimos[titulo] ?? 0.0;
    double costoFinal = 0.0;

    if (lados > 0) {
      if (costoCalculado < costoMinimo) {
        costoFinal = costoMinimo;
      } else {
        costoFinal = costoCalculado;
      }
    }

    widget.controllersCostoTotal[titulo]?.text = costoFinal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (_, __) => _cargarPreciosDeBD());

    return Column(
      children: [
        if (!widget.isOffset) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Medidas Manuales para Laminado",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildManualInput(
                        controller: widget.pliegoAnchoController,
                        label: "Ancho (cm)",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildManualInput(
                        controller: widget.pliegoAltoController,
                        label: "Alto (cm)",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ...laminadosPermitidos
            .map((titulo) => _buildLaminadoBlock(titulo))
            .toList(),
      ],
    );
  }

  Widget _buildManualInput({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (_) => _recalcularTodos(),
    );
  }

  Widget _buildLaminadoBlock(String titulo) {
    final bool activo = (frente[titulo] ?? false) || (vuelta[titulo] ?? false);

    return Opacity(
      opacity: widget.readOnly ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !widget.readOnly,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// CHECKBOX PRINCIPAL
              Row(
                children: [
                  Checkbox(
                    value: activo,
                    onChanged: (v) {
                      final bool nuevoValor = v ?? false;
                      setState(() {
                        frente[titulo] = nuevoValor;
                        vuelta[titulo] = false;

                        widget.onLaminadoChanged(titulo, "frente", nuevoValor);
                        widget.onLaminadoChanged(titulo, "vuelta", false);

                        _calcularCostoIndividual(titulo);
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// FRENTE / VUELTA
              Row(
                children: [
                  Checkbox(
                    value: frente[titulo],
                    onChanged: activo
                        ? (v) {
                            setState(() {
                              frente[titulo] = v ?? false;
                              widget.onLaminadoChanged(
                                titulo,
                                "frente",
                                v ?? false,
                              );
                              _calcularCostoIndividual(titulo);
                            });
                          }
                        : null,
                  ),
                  const Text("Frente"),
                  const SizedBox(width: 25),
                  Checkbox(
                    value: vuelta[titulo],
                    onChanged: activo
                        ? (v) {
                            setState(() {
                              vuelta[titulo] = v ?? false;
                              widget.onLaminadoChanged(
                                titulo,
                                "vuelta",
                                v ?? false,
                              );
                              _calcularCostoIndividual(titulo);
                            });
                          }
                        : null,
                  ),
                  const Text("Vuelta"),
                ],
              ),

              const SizedBox(height: 10),

              /// COSTOS
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controllersCostoCm2[titulo],
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calcularCostoIndividual(titulo),
                      decoration: const InputDecoration(
                        labelText: "Costo por cm²",
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: "\$ ",
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: widget.controllersCostoTotal[titulo],
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Costo Total",
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: "\$ ",
                        fillColor: Color(0xFFEEEEEE),
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
