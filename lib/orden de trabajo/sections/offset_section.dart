// lib/screens/sections/offset_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class OffsetSection extends ConsumerWidget {
  const OffsetSection({super.key});

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
                const Icon(Icons.print, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  "3. IMPRESIÓN OFFSET",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- DATOS GENERALES ---
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInput(
                  "TIPO DE TRABAJO",
                  "Ej: Catálogo, Caja...",
                  200,
                  controller.offsetTipoTrabajo,
                  "offset_tipo_trabajo_${controller.sessionKey}",
                  readOnly: true,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('tipo', v),
                ),
                _buildInput(
                  "PIEZAS PEDIDAS",
                  "0",
                  120,
                  controller.offsetPiezasPedidas > 0
                      ? controller.offsetPiezasPedidas.toString()
                      : "",
                  "offset_piezas_pedidas_${controller.sessionKey}",
                  esNumero: true,
                  readOnly: true,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('piezas', v),
                ),
                _buildInput(
                  "PAPEL NECESARIO",
                  "Ej: 1500 pliegos",
                  150,
                  controller.offsetPapelNecesario,
                  "offset_papel_necesario_${controller.sessionKey}",
                  readOnly: true,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('necesario', v),
                ),
                _buildInput(
                  "PAPEL QUE LLEGARÁ",
                  "Ej: 1600 pliegos",
                  150,
                  controller.offsetPapelLlegara,
                  "offset_papel_llegara_${controller.sessionKey}",
                  readOnly: true,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('llegara', v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- MATRIZ DE TINTAS ---
            const Text(
              "TINTAS REQUERIDAS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),

            // Fila de Frente
            _buildInkRow(
              context,
              ref,
              'frente',
              'FRENTE',
              controller.offsetData['frente'],
              controller.sessionKey,
            ),
            const Divider(height: 16),
            // Fila de Vuelta
            _buildInkRow(
              context,
              ref,
              'vuelta',
              'VUELTA',
              controller.offsetData['vuelta'],
              controller.sessionKey,
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
              key: ValueKey("offset_notas_extras_${controller.sessionKey}"),
              initialValue: controller.offsetNotas,
              maxLines: 3,
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateOffsetTexto('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Escribe aquí la secuencia de colores, tiempos de secado, tipo de barniz de máquina...",
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

  // Helper para los cuadros de texto superiores
  Widget _buildInput(
    String label,
    String hint,
    double width,
    String initialValue,
    String fieldKey, {
    bool esNumero = false,
    bool readOnly = false,
    required Function(String) onChanged,
  }) {
    return SizedBox(
      width: width,
      child: Column(
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
              fillColor: readOnly ? Colors.grey[200] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(
              fontSize: 13,
              color: readOnly ? Colors.black54 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper para crear las filas de tintas (Frente / Vuelta)
  Widget _buildInkRow(
    BuildContext context,
    WidgetRef ref,
    String caraKey,
    String label,
    Map<String, dynamic> data,
    String sessionKey,
  ) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        _buildInkCheck(ref, caraKey, 'C', 'C', Colors.cyan, data['C']),
        _buildInkCheck(ref, caraKey, 'M', 'M', Colors.pink, data['M']),
        _buildInkCheck(ref, caraKey, 'Y', 'Y', Colors.yellow[700]!, data['Y']),
        _buildInkCheck(ref, caraKey, 'K', 'K', Colors.black, data['K']),
        const SizedBox(width: 8),
        _buildInkCheck(
          ref,
          caraKey,
          'especial',
          'Especial',
          Colors.deepPurple,
          data['especial'],
        ),
        _buildInkCheck(
          ref,
          caraKey,
          'pantone',
          'Pantone',
          Colors.orange,
          data['pantone'],
        ),

        // El cuadro de texto aparece solo si marcan Especial o Pantone
        if (data['especial'] || data['pantone'])
          Container(
            width: 150,
            margin: const EdgeInsets.only(left: 8, top: 4),
            child: TextFormField(
              key: ValueKey("offset_tinta_esp_${caraKey}_$sessionKey"),
              initialValue: data['tinta_esp'] ?? '',
              onChanged: (v) => ref
                  .read(ordenTrabajoProvider)
                  .updateOffsetInk(caraKey, 'tinta_esp', v),
              decoration: const InputDecoration(
                hintText: "Especifique tinta...",
                isDense: true,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Helper para los checkboxes de cada color
  Widget _buildInkCheck(
    WidgetRef ref,
    String cara,
    String colorKey,
    String label,
    Color color,
    bool value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: color,
          onChanged: (v) =>
              ref.read(ordenTrabajoProvider).updateOffsetInk(cara, colorKey, v),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
