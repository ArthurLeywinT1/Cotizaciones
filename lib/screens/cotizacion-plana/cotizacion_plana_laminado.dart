import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

class PanelLaminados extends ConsumerStatefulWidget {
  final bool readOnly;

  final Map<String, Map<String, bool>> laminados;
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;
  final Map<String, TextEditingController> controllersCostoCm2;
  final Map<String, TextEditingController> controllersCostoTotal;

  final void Function(String nombre, String lado, bool valor)
      onLaminadoChanged;

  const PanelLaminados({
    super.key,
    required this.readOnly,
    required this.laminados,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.controllersCostoCm2,
    required this.controllersCostoTotal,
    required this.onLaminadoChanged,
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

  @override
  void initState() {
    super.initState();
    _sincronizarEstadoLocal();

    widget.anchoFinalController.addListener(_recalcularTodos);
    widget.altoFinalController.addListener(_recalcularTodos);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cargarPreciosDeBD(),
    );
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
        (e) => e.nombre.trim().toLowerCase() ==
               nombre.trim().toLowerCase(),
      );

      widget.controllersCostoCm2[nombre]?.text =
          (extra.costoCm2 ?? 0).toString();

      _calcularCostoIndividual(nombre);
    } catch (e) {
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
        double.tryParse(widget.anchoFinalController.text) ?? 0.0;
    final double alto =
        double.tryParse(widget.altoFinalController.text) ?? 0.0;
    final double costoCm2 =
        double.tryParse(
              widget.controllersCostoCm2[titulo]?.text ?? "0",
            ) ??
            0.0;

    final int lados =
        (frente[titulo] == true ? 1 : 0) +
        (vuelta[titulo] == true ? 1 : 0);

    final double areaTotal = (ancho * alto) * lados;
    final double costoTotal = areaTotal * costoCm2;

    widget.controllersCostoTotal[titulo]?.text =
        costoTotal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (_, __) => _cargarPreciosDeBD());

    return Column(
      children: laminadosPermitidos
          .map((titulo) => _buildLaminadoBlock(titulo))
          .toList(),
    );
  }

  Widget _buildLaminadoBlock(String titulo) {
    final bool activo =
        (frente[titulo] ?? false) || (vuelta[titulo] ?? false);

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

                        widget.onLaminadoChanged(
                            titulo, "frente", nuevoValor);
                        widget.onLaminadoChanged(
                            titulo, "vuelta", false);

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
                      controller:
                          widget.controllersCostoCm2[titulo],
                      readOnly: !activo,
                      keyboardType: TextInputType.number,
                      onChanged: (_) =>
                          _calcularCostoIndividual(titulo),
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
                      controller:
                          widget.controllersCostoTotal[titulo],
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
