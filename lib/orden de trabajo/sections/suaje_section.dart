// lib/screens/sections/suaje_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class SuajeSection extends ConsumerWidget {
  final bool modoProduccion;
  const SuajeSection({super.key, this.modoProduccion = false});

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
            Row(
              children: [
                const Icon(Icons.dashboard_customize, color: Colors.pink),
                const SizedBox(width: 8),
                const Text(
                  "6. SUAJE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- PROYECTO Y PLIEGOS ---
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "PROYECTO",
                    "Nombre del proyecto...",
                    controller.suajeProyecto,
                    "suaje_proyecto_${controller.sessionKey}", // <--- Valor inicial inyectado
                    readOnly: true,
                    onChanged: (v) => controller.updateSuaje('proyecto', v),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  child: _buildInput(
                    "PLIEGOS",
                    "0",
                    controller.suajePliegos > 0
                        ? controller.suajePliegos.toString()
                        : "",
                    "suaje_pliegos_${controller.sessionKey}", // <--- Valor inicial inyectado
                    esNumero: true,
                    readOnly: true,
                    onChanged: (v) => controller.updateSuaje('pliegos', v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- QUIÉN REALIZA EL TRABAJO ---
            const Text(
              "RESPONSABLE DEL PROCESO",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildCheck(
                  "Romosso",
                  controller.suajeEsRomosso,
                  (v) => controller.updateSuaje('romosso', v!),
                ),
                _buildCheck(
                  "Maquilador",
                  controller.suajeEsMaquilador,
                  (v) => controller.updateSuaje('maquilador', v!),
                ),

                // CUADRO DE TEXTO CONDICIONAL
                if (controller.suajeEsMaquilador)
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      key: ValueKey(
                        "suaje_nombre_maquila_${controller.sessionKey}",
                      ), // <--- Key reactiva
                      initialValue:
                          controller.suajeNombreMaquila, // <--- Valor inicial
                      onChanged: (v) =>
                          controller.updateSuaje('nombreMaquila', v),
                      decoration: const InputDecoration(
                        labelText: "Nombre de quien maquila",
                        isDense: true,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business, size: 18),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 30),

            // --- ESTADO DEL MARCO ---
            const Text(
              "ESTADO DEL MARCO",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                _buildCheck(
                  "Marco Existente",
                  controller.suajeMarcoExistente,
                  (v) => controller.updateSuaje('existente', v!),
                ),
                _buildCheck(
                  "Marco Nuevo",
                  controller.suajeMarcoNuevo,
                  (v) => controller.updateSuaje('nuevo', v!),
                ),
              ],
            ),
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
              key: ValueKey(
                "suaje_notas_extras_${controller.sessionKey}",
              ), // <--- Key reactiva
              initialValue: controller.suajeNotas, // <--- Valor inicial
              maxLines: 3,
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateSuaje('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Ej: instruciones para el suaje, tipo de marco, si es necesario reparar el marco existente...",
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
            if (modoProduccion) ...[
              const Divider(height: 32, thickness: 1),
              SectionButtons(
                area: 'suaje',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper para inputs de texto (Convertido a TextFormField)
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
          key: ValueKey(
            fieldKey,
          ), // <--- Permite actualizar el campo si llegan nuevos datos
          initialValue: initialValue,
          readOnly: readOnly,
          onChanged: readOnly ? null : onChanged,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[200] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: TextStyle(
            fontSize: 13,
            color: readOnly ? Colors.black54 : Colors.black,
          ),
        ),
        // --- BOTONES (OCULTOS) ---
        // Usamos Visibility con false para que no ocupen espacio ni se vean
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
            activeColor: Colors.pink,
          ),
        ],
      ),
    );
  }
}
