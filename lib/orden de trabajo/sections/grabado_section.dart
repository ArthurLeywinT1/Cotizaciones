// lib/screens/sections/grabado_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class GrabadoSection extends ConsumerWidget {
  final bool modoProduccion;
  const GrabadoSection({super.key, this.modoProduccion = false});

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
              "grabado_proyecto_${controller.sessionKey}",
              readOnly: modoProduccion, // <--- DINÁMICO EN PRODUCCIÓN
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
                    "grabado_placas_${controller.sessionKey}",
                    readOnly: modoProduccion, // <--- DINÁMICO EN PRODUCCIÓN
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
                    "grabado_piezas_${controller.sessionKey}",
                    esNumero: true,
                    readOnly: modoProduccion, // <--- DINÁMICO EN PRODUCCIÓN
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
                  modoProduccion
                      ? null // <--- DESACTIVADO EN PRODUCCIÓN
                      : (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateGrabado('romosso', v!),
                ),
                _buildCheck(
                  "Maquilador",
                  controller.grabadoEsMaquilador,
                  modoProduccion
                      ? null // <--- DESACTIVADO EN PRODUCCIÓN
                      : (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateGrabado('maquilador', v!),
                ),

                // Cuadro de texto condicional que aparece si es Maquilador
                if (controller.grabadoEsMaquilador)
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      key: ValueKey(
                        "grabado_nombre_maquila_${controller.sessionKey}",
                      ),
                      initialValue: controller.grabadoNombreMaquila,
                      readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                      onChanged: modoProduccion
                          ? null
                          : (v) => ref
                              .read(ordenTrabajoProvider)
                              .updateGrabado('nombreMaquila', v),
                      decoration: InputDecoration(
                        labelText: "Nombre de quien maquila",
                        isDense: true,
                        filled: modoProduccion,
                        fillColor: modoProduccion ? Colors.grey[100] : null,
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.handyman, size: 18),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: modoProduccion ? Colors.black54 : Colors.black,
                      ),
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
              key: ValueKey("grabado_notas_extras_${controller.sessionKey}"),
              initialValue: controller.grabadoNotas,
              maxLines: 3,
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateGrabado('notes', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales de grabado"
                    : "Escribe aquí cualquier instrucción adicional, cuidado especial, o detalle extra para el área de grabado...",
                isDense: true,
                filled: true,
                fillColor: modoProduccion ? Colors.grey[100] : Colors.yellow[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: modoProduccion ? Colors.grey[300]! : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: modoProduccion ? Colors.grey[300]! : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 13, 
                fontStyle: FontStyle.italic,
                color: modoProduccion ? Colors.black54 : Colors.black,
              ),
            ),

            if (modoProduccion) ...[
              const Divider(height: 32, thickness: 1),
              SectionButtons(
                area: 'grabado',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper para Inputs
  Widget _buildInput(
    String label,
    String hint,
    String initialValue,
    String fieldKey, {
    bool esNumero = false,
    bool readOnly = false,
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
          key: ValueKey(fieldKey),
          initialValue: initialValue,
          readOnly: readOnly,
          onChanged: readOnly ? null : onChanged,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? Colors.grey[300]! : Colors.grey[400]!,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: 13,
            color: readOnly ? Colors.black54 : Colors.black,
          ),
        ),
      ],
    );
  }

  // Helper para Checkboxes
  Widget _buildCheck(String label, bool value, Function(bool?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w500,
              color: onChanged == null ? Colors.black54 : Colors.black,
            ),
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