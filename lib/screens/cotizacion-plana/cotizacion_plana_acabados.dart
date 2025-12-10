import 'package:flutter/material.dart';

class PanelAcabados extends StatefulWidget {
  final bool enabled;

  /// Datos que vienen del padre
  final Map<String, Map<String, bool>> acabados;

  /// ✅ CALLBACK AL PADRE
  final void Function(String nombre, String lado, bool valor)
      onAcabadoChanged;

  const PanelAcabados({
    super.key,
    required this.enabled,
    required this.acabados,
    required this.onAcabadoChanged,
  });

  @override
  State<PanelAcabados> createState() => _PanelAcabadosState();
}

class _PanelAcabadosState extends State<PanelAcabados> {
  late Map<String, bool> frente;
  late Map<String, bool> vuelta;

  @override
  void initState() {
    super.initState();

    frente = {};
    vuelta = {};

    widget.acabados.forEach((key, value) {
      frente[key] = value["frente"] ?? false;
      vuelta[key] = value["vuelta"] ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.acabados.keys
          .map((titulo) => _buildAcabadoBlock(titulo))
          .toList(),
    );
  }

  Widget _buildAcabadoBlock(String titulo) {
    bool activo = frente[titulo]! || vuelta[titulo]!;

    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !widget.enabled,
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
              /// ✅ Checkbox principal
              Row(
                children: [
                  Checkbox(
                    value: activo,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          frente[titulo] = true;
                        } else {
                          frente[titulo] = false;
                          vuelta[titulo] = false;

                          widget.onAcabadoChanged(
                              titulo, "vuelta", false);
                        }

                        widget.onAcabadoChanged(
                            titulo, "frente", frente[titulo]!);
                      });
                    },
                  ),
                  Text(
                    titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// ✅ Frente / Vuelta
              Row(
                children: [
                  Checkbox(
                    value: frente[titulo],
                    onChanged: activo
                        ? (v) {
                            setState(() {
                              frente[titulo] = v ?? false;
                            });
                            widget.onAcabadoChanged(
                                titulo, "frente", v ?? false);
                          }
                        : null,
                  ),
                  const Text("Impresión por el Frente"),
                  const SizedBox(width: 25),
                  Checkbox(
                    value: vuelta[titulo],
                    onChanged: activo
                        ? (v) {
                            setState(() {
                              vuelta[titulo] = v ?? false;
                            });
                            widget.onAcabadoChanged(
                                titulo, "vuelta", v ?? false);
                          }
                        : null,
                  ),
                  const Text("Impresión por la Vuelta"),
                ],
              ),

              const SizedBox(height: 10),

              /// ✅ Costos
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: activo,
                      decoration: const InputDecoration(
                        labelText: "Costo por cm²",
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: "\$ ",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      enabled: activo,
                      decoration: const InputDecoration(
                        labelText: "Costo Total",
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixText: "\$ ",
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
