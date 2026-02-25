import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';
// Panel específico para el cálculo de acabados (barnices UV)
class PanelAcabados extends ConsumerStatefulWidget {
  final bool read_Only;

  final Map<String, Map<String, bool>> acabados;
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;
  final TextEditingController totalPliegosController;
  final Map<String, TextEditingController> controllersCostoCm2;
  final Map<String, TextEditingController> controllersCostoTotal;

  final void Function(String nombre, String lado, bool valor) onAcabadoChanged;

  const PanelAcabados({
    super.key,
    required this.read_Only,
    required this.acabados,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.totalPliegosController,
    required this.controllersCostoCm2,
    required this.controllersCostoTotal,
    required this.onAcabadoChanged,
  });

  @override
  ConsumerState<PanelAcabados> createState() => _PanelAcabadosState();
}

class _PanelAcabadosState extends ConsumerState<PanelAcabados> {
  /// 🔒 SOLO BARNICES UV PERMITIDOS
  final Set<String> barnicesPermitidos = {
    "Barniz UV a Registro",
    "Barniz UV Brillante a Plasta",
    "Barniz UV Mate Plasta",
  };

  late Map<String, bool> frente;
  late Map<String, bool> vuelta;
  Map<String, double> costosMinimos = {};

  @override
  void initState() {
    super.initState();
    _sincronizarEstadoLocal();

    widget.anchoFinalController.addListener(_recalcularTodos);
    widget.altoFinalController.addListener(_recalcularTodos);
    widget.totalPliegosController.addListener(_recalcularTodos);

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarPreciosDeBD());
  }

  void _sincronizarEstadoLocal() {
    frente = {};
    vuelta = {};

    for (final nombre in barnicesPermitidos) {
      final data = widget.acabados[nombre];
      frente[nombre] = data?["frente"] ?? false;
      vuelta[nombre] = data?["vuelta"] ?? false;
    }
  }

  void _cargarPreciosDeBD() {
    final extrasState = ref.read(extrasProvider);

    for (final nombre in barnicesPermitidos) {
      try {
        final extra = extrasState.extras.firstWhere(
          (e) => e.nombre.trim().toLowerCase() == nombre.trim().toLowerCase(),
        );

        if (extra.costoCm2 != null) {
          widget.controllersCostoCm2[nombre]?.text = extra.costoCm2.toString();
        }

        costosMinimos[nombre] = extra.costoMinimoTotal ?? 0.0;
        _calcularCostoIndividual(nombre);
      } catch (_) {
        costosMinimos[nombre] = 0.0;
      }
    }
  }

  void _recalcularTodos() {
    for (final nombre in barnicesPermitidos) {
      _calcularCostoIndividual(nombre);
    }
  }

  void _calcularCostoIndividual(String titulo) {
    final double ancho =
        double.tryParse(widget.anchoFinalController.text) ?? 0.0;
    final double alto = double.tryParse(widget.altoFinalController.text) ?? 0.0;
    final double totalPliegos =
        double.tryParse(widget.totalPliegosController.text) ?? 0.0;
    final double costoCm2 =
        double.tryParse(widget.controllersCostoCm2[titulo]?.text ?? "0") ?? 0.0;

    final int lados =
        (frente[titulo] == true ? 1 : 0) + (vuelta[titulo] == true ? 1 : 0);

    final double areaUnitariaxLados = (ancho * .01 * alto * .01) * lados;
    final double costoCalculado = areaUnitariaxLados * costoCm2 * totalPliegos;
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
      children: barnicesPermitidos
          .map((titulo) => _buildAcabadoBlock(titulo))
          .toList(),
    );
  }

  Widget _buildAcabadoBlock(String titulo) {
    final bool activo = (frente[titulo] ?? false) || (vuelta[titulo] ?? false);

    return Opacity(
      opacity: widget.read_Only ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !widget.read_Only,
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

                        widget.onAcabadoChanged(titulo, "frente", nuevoValor);
                        widget.onAcabadoChanged(titulo, "vuelta", false);

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
                              widget.onAcabadoChanged(
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
                              widget.onAcabadoChanged(
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
