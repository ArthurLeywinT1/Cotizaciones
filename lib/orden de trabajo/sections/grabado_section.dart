// lib/screens/sections/grabado_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class GrabadoSection extends ConsumerWidget {
  const GrabadoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordenTrabajoProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Row(
              children: [
                Icon(Icons.settings, color: Colors.amber[800]),
                const SizedBox(width: 8),
                const Text(
                  "8. GRABADO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- CAMPO 1: PROYECTO ---
            _buildInput(
              "PROYECTO",
              "Nombre del proyecto de grabado...",
              controller.grabadoProyecto,
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateGrabado('proyecto', v),
            ),
            const SizedBox(height: 12),

            // --- CAMPO 2: PLACAS Y PIEZAS ---
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInput(
                    "PLACAS A UTILIZAR",
                    "Descripción de placas...",
                    controller.grabadoPlacas,
                    onChanged: (v) => ref
                        .read(ordenTrabajoProvider)
                        .updateGrabado('placas', v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildInput(
                    "PIEZAS SOLICITADAS",
                    "0",
                    controller.grabadoPiezas > 0
                        ? controller.grabadoPiezas.toString()
                        : "",
                    esNumero: true,
                    onChanged: (v) => ref
                        .read(ordenTrabajoProvider)
                        .updateGrabado('piezas', v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- RESPONSABLE (Lógica Maquilador) ---
            const Text(
              "RESPONSABLE DEL PROCESO",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildCheck(
                  "Romosso",
                  controller.grabadoEsRomosso,
                  (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateGrabado('romosso', v!),
                ),
                _buildCheck(
                  "Maquilador",
                  controller.grabadoEsMaquilador,
                  (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateGrabado('maquilador', v!),
                ),

                // Cuadro de texto condicional que aparece si es Maquilador
                if (controller.grabadoEsMaquilador)
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      key: ValueKey(controller.grabadoNombreMaquila),
                      initialValue: controller.grabadoNombreMaquila,
                      onChanged: (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateGrabado('nombreMaquila', v),
                      decoration: const InputDecoration(
                        labelText: "Nombre de quien maquila",
                        isDense: true,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.handyman, size: 18),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // --- NOTAS / INSTRUCCIONES EXTRAS ---
            const Text(
              "NOTAS / INSTRUCCIONES EXTRAS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              key: ValueKey(controller.grabadoNotas),
              initialValue: controller.grabadoNotas,
              maxLines: 3,
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateGrabado('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Escribe aquí cualquier instrucción adicional, cuidado especial, o detalle extra para el área de grabado...",
                isDense: true,
                filled: true,
                fillColor: Colors.yellow[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para Inputs
  Widget _buildInput(
    String label,
    String hint,
    String initialValue, {
    bool esNumero = false,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          key: ValueKey(initialValue),
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  // Helper para Checkboxes
  Widget _buildCheck(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.amber[800],
          ),
        ],
      ),
    );
  }
}
