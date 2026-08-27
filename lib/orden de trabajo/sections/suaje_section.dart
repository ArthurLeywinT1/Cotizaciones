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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: modoProduccion ? Colors.grey[300]! : Colors.pink[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Row(
              children: [
                Icon(
                  Icons.dashboard_customize, 
                  color: modoProduccion ? Colors.grey[700] : Colors.pink,
                ),
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
                    "suaje_proyecto_${controller.sessionKey}",
                    readOnly: modoProduccion, // <--- Mutabilidad adaptada al flujo de taller
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
                    "suaje_pliegos_${controller.sessionKey}",
                    esNumero: true,
                    readOnly: modoProduccion, // <--- Mutabilidad adaptada al flujo de taller
                    onChanged: (v) => controller.updateSuaje('pliegos', v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- RESPONSABLE DEL PROCESO ---
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
                  modoProduccion 
                      ? null // <--- Bloqueo físico de la interacción
                      : (v) => controller.updateSuaje('romosso', v!),
                ),
                _buildCheck(
                  "Maquilador",
                  controller.suajeEsMaquilador,
                  modoProduccion 
                      ? null // <--- Bloqueo físico de la interacción
                      : (v) => controller.updateSuaje('maquilador', v!),
                ),

                // CUADRO DE TEXTO CONDICIONAL
                if (controller.suajeEsMaquilador)
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      key: ValueKey(
                        "suaje_nombre_maquila_${controller.sessionKey}",
                      ),
                      initialValue: controller.suajeNombreMaquila,
                      readOnly: modoProduccion,
                      onChanged: modoProduccion 
                          ? null 
                          : (v) => controller.updateSuaje('nombreMaquila', v),
                      decoration: InputDecoration(
                        labelText: "Nombre de quien maquila",
                        isDense: true,
                        filled: true,
                        fillColor: modoProduccion ? Colors.grey[100] : Colors.white,
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.business, size: 18),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: modoProduccion ? Colors.black54 : Colors.black,
                      ),
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
                  modoProduccion 
                      ? null 
                      : (v) => controller.updateSuaje('existente', v!),
                ),
                _buildCheck(
                  "Marco Nuevo",
                  controller.suajeMarcoNuevo,
                  modoProduccion 
                      ? null 
                      : (v) => controller.updateSuaje('nuevo', v!),
                ),
              ],
            ),
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
              key: ValueKey("suaje_notas_extras_${controller.sessionKey}"),
              initialValue: controller.suajeNotas,
              maxLines: 3,
              readOnly: modoProduccion,
              onChanged: modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateSuaje('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones de suajado adicionales"
                    : "Ej: instrucciones para el suaje, tipo de marco, si es necesario reparar el marco existente...",
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

            const SizedBox(height: 16),
            const Text(
              "NOTAS DEL TALLER",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              key: ValueKey("suaje_notas_taller_${controller.sessionKey}"),
              initialValue: controller.suajeNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion,
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateSuaje('notasTaller', v),
              decoration: InputDecoration(
                hintText: !modoProduccion
                    ? "Sin notas del taller"
                    : "Escribe aquí cualquier observación o nota para esta orden...",
                isDense: true,
                filled: true,
                fillColor: !modoProduccion ? Colors.grey[100] : Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: !modoProduccion ? Colors.grey[300]! : Colors.blue[200]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: !modoProduccion ? Colors.grey[300]! : Colors.blue[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 13, 
                fontStyle: FontStyle.italic,
                color: !modoProduccion ? Colors.black54 : Colors.black,
              ),
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

  // Helper para inputs de texto genéricos
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
            filled: true,
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

  // Helper adaptativo para Checkboxes
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
            onChanged: onChanged, // Al pasar null la UI de Flutter lo inhabilita automáticamente
            activeColor: onChanged == null ? Colors.grey : Colors.pink,
          ),
        ],
      ),
    );
  }
}