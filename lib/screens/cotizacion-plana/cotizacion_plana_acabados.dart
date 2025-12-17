import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

class PanelAcabados extends ConsumerStatefulWidget {
  final bool read_Only;

  // Datos del padre
  final Map<String, Map<String, bool>> acabados;
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;
  final Map<String, TextEditingController> controllersCostoCm2;
  final Map<String, TextEditingController> controllersCostoTotal;

  // Callback al padre
  final void Function(String nombre, String lado, bool valor) onAcabadoChanged;

  const PanelAcabados({
    super.key,
    required this.read_Only,
    required this.acabados,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.controllersCostoCm2,
    required this.controllersCostoTotal,
    required this.onAcabadoChanged,
  });

  @override
  ConsumerState<PanelAcabados> createState() => _PanelAcabadosState();
}

class _PanelAcabadosState extends ConsumerState<PanelAcabados> {
  late Map<String, bool> frente;
  late Map<String, bool> vuelta;

  @override
  void initState() {
    super.initState();
    _sincronizarEstadoLocal();

    widget.anchoFinalController.addListener(_recalcularTodos);
    widget.altoFinalController.addListener(_recalcularTodos);

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarPreciosDeBD());
  }

  void _sincronizarEstadoLocal() {
    frente = {};
    vuelta = {};
    widget.acabados.forEach((key, value) {
      frente[key] = value["frente"] ?? false;
      vuelta[key] = value["vuelta"] ?? false;
    });
  }

  void _cargarPreciosDeBD() {
    final extrasState = ref.read(extrasProvider);

    for (String nombreAcabado in widget.acabados.keys) {
      try {
        final extra = extrasState.extras.firstWhere(
          (e) =>
              e.nombre.trim().toLowerCase() ==
              nombreAcabado.trim().toLowerCase(),
        );

        if (extra.costoCm2 != null) {
          widget.controllersCostoCm2[nombreAcabado]?.text = extra.costoCm2
              .toString();
          _calcularCostoIndividual(nombreAcabado);
        }
      } catch (e) {}
    }
  }

  void _recalcularTodos() {
    for (var key in widget.acabados.keys) {
      _calcularCostoIndividual(key);
    }
  }

  void _calcularCostoIndividual(String titulo) {
    final double ancho =
        double.tryParse(widget.anchoFinalController.text) ?? 0.0;
    final double alto = double.tryParse(widget.altoFinalController.text) ?? 0.0;
    final double costoCm2 =
        double.tryParse(widget.controllersCostoCm2[titulo]?.text ?? "0") ?? 0.0;

    int lados = 0;
    if (frente[titulo] == true) lados++;
    if (vuelta[titulo] == true) lados++;

    final double areaTotal = (ancho * alto) * lados;
    final double costoTotal = areaTotal * costoCm2;

    widget.controllersCostoTotal[titulo]?.text = costoTotal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) => _cargarPreciosDeBD());

    return Column(
      children: widget.acabados.keys
          .map((titulo) => _buildAcabadoBlock(titulo))
          .toList(),
    );
  }

  Widget _buildAcabadoBlock(String titulo) {
    bool activo = (frente[titulo] ?? false) || (vuelta[titulo] ?? false);

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
              /// Checkbox principal
              Row(
                children: [
                  Checkbox(
                    value: activo,
                    onChanged: (v) {
                      setState(() {
                        bool nuevoValor = v ?? false;
                        frente[titulo] = nuevoValor;
                        if (!nuevoValor) vuelta[titulo] = false;
                        widget.onAcabadoChanged(titulo, "frente", nuevoValor);
                        if (!nuevoValor)
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

              /// Frente / Vuelta
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

              /// Costos
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controllersCostoCm2[titulo],
                      readOnly: !activo,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calcularCostoIndividual(titulo),
                      decoration: const InputDecoration(
                        labelText: "Costo por cm²",
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: "\$ ",
                        fillColor: Colors.white,
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
