// lib/screens/sections/offset_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class OffsetSection extends ConsumerWidget {
  final bool modoProduccion;
  const OffsetSection({super.key, this.modoProduccion = false});

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
                Icon(
                  Icons.print, 
                  color: modoProduccion ? Colors.grey[700] : Colors.blue,
                ),
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
                  readOnly: modoProduccion, // <--- DINÁMICO
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
                  readOnly: modoProduccion, // <--- DINÁMICO
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
                  readOnly: modoProduccion, // <--- DINÁMICO
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
                  readOnly: modoProduccion, // <--- DINÁMICO
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('llegara', v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- MATRIZ DE TINTAS ---
            Text(
              "TINTAS REQUERIDAS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: modoProduccion ? Colors.grey[600] : Colors.blue,
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
              modoProduccion, // <--- INYECTADO
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
              modoProduccion, // <--- INYECTADO
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
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales de offset"
                    : "Escribe aquí la secuencia de colores, tiempos de secado, tipo de barniz de máquina...",
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
                area: 'offset',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
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
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
    bool modoProd,
  ) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              color: modoProd ? Colors.black54 : Colors.black,
            ),
          ),
        ),
        _buildInkCheck(ref, caraKey, 'C', 'C', Colors.cyan, data['C'], modoProd),
        _buildInkCheck(ref, caraKey, 'M', 'M', Colors.pink, data['M'], modoProd),
        _buildInkCheck(ref, caraKey, 'Y', 'Y', Colors.yellow[700]!, data['Y'], modoProd),
        _buildInkCheck(ref, caraKey, 'K', 'K', Colors.black, data['K'], modoProd),
        const SizedBox(width: 8),
        _buildInkCheck(
          ref,
          caraKey,
          'especial',
          'Especial',
          Colors.deepPurple,
          data['especial'],
          modoProd,
        ),
        _buildInkCheck(
          ref,
          caraKey,
          'pantone',
          'Pantone',
          Colors.orange,
          data['pantone'],
          modoProd,
        ),

        // El cuadro de texto aparece solo si marcan Especial o Pantone
        if (data['especial'] || data['pantone'])
          Container(
            width: 150,
            margin: const EdgeInsets.only(left: 8, top: 4),
            child: TextFormField(
              key: ValueKey("offset_tinta_esp_${caraKey}_$sessionKey"),
              initialValue: data['tinta_esp'] ?? '',
              readOnly: modoProd,
              onChanged: modoProd
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetInk(caraKey, 'tinta_esp', v),
              decoration: InputDecoration(
                hintText: "Especifique tinta...",
                isDense: true,
                filled: modoProd,
                fillColor: modoProd ? Colors.grey[100] : Colors.white,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: modoProd ? Colors.grey[300]! : Colors.grey[400]!,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 12,
                color: modoProd ? Colors.black54 : Colors.black,
              ),
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
    bool modoProd,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: color,
          onChanged: modoProd
              ? null // <--- DESACTIVADO EN PRODUCCIÓN
              : (v) => ref.read(ordenTrabajoProvider).updateOffsetInk(cara, colorKey, v),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: modoProd ? color.withOpacity(0.6) : color,
          ),
        ),
      ],
    );
  }
}