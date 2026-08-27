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
                  readOnly: modoProduccion,
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
                  readOnly: modoProduccion,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('piezas', v),
                ),
                _buildInput(
                  "NOMBRE DEL PAPEL",
                  "Ej: Couché 150g",
                  200,
                  controller.offsetNombrePapel,
                  "offset_nombre_papel_${controller.sessionKey}",
                  readOnly: modoProduccion,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('nombre_papel', v),
                ),
                _buildInput(
                  "PAPEL NECESARIO",
                  "Ej: 1500 pliegos",
                  150,
                  controller.offsetPapelNecesario,
                  "offset_papel_necesario_${controller.sessionKey}",
                  readOnly: modoProduccion,
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
                  readOnly: modoProduccion,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('llegara', v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- MATRIZ DE TINTAS PRINCIPAL ---
            Text(
              "TINTAS REQUERIDAS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: modoProduccion ? Colors.grey[600] : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),

            // Fila de Frente Principal
            _buildInkRow(
              context,
              ref,
              'FRENTE',
              controller.offsetData['frente'],
              "frente_${controller.sessionKey}",
              modoProduccion,
              onChanged: (colorKey, value) => ref
                  .read(ordenTrabajoProvider)
                  .updateOffsetInk('frente', colorKey, value),
            ),
            const Divider(height: 16),
            
            // Fila de Vuelta Principal
            _buildInkRow(
              context,
              ref,
              'VUELTA',
              controller.offsetData['vuelta'],
              "vuelta_${controller.sessionKey}",
              modoProduccion,
              onChanged: (colorKey, value) => ref
                  .read(ordenTrabajoProvider)
                  .updateOffsetInk('vuelta', colorKey, value),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // --- NOTAS / INSTRUCCIONES EXTRAS ---
            const Text(
              "NOTAS / INSTRUCCIONES EXTRAS",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextFormField(
              key: ValueKey("offset_notas_extras_${controller.sessionKey}"),
              initialValue: controller.offsetNotas,
              maxLines: 3,
              readOnly: modoProduccion,
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: TextStyle(fontSize: 13, color: modoProduccion ? Colors.black54 : Colors.black),
            ),

            const SizedBox(height: 16),
            const Text(
              "NOTAS DEL TALLER",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 4),
            TextFormField(
              key: ValueKey("offset_notas_taller_${controller.sessionKey}"),
              initialValue: controller.offsetNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion,
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateOffsetTexto('notasTaller', v),
              decoration: InputDecoration(
                hintText: !modoProduccion
                    ? "Sin notas del taller"
                    : "Escribe aquí cualquier observación o nota para esta orden...",
                isDense: true,
                filled: true,
                fillColor: !modoProduccion ? Colors.grey[100] : Colors.blue[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: TextStyle(fontSize: 13, color: !modoProduccion ? Colors.black54 : Colors.black),
            ),
            const Divider(height: 32),

            // --- REPETICIÓN DE PIEZAS / PAPELES ---
            const Text(
              "REPETICIÓN DE PIEZAS / PAPELES ADICIONALES",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...controller.papelesExtra.asMap().entries.map((entry) {
              int idx = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Set Adicional ${idx + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: modoProduccion
                                ? null
                                : () => ref
                                    .read(ordenTrabajoProvider)
                                    .eliminarPapelExtra(item.id),
                          )
                        ],
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildInput(
                            "NOMBRE PAPEL",
                            "Ej: Couché",
                            140,
                            item.nombrePapel,
                            "n_${item.id}",
                            readOnly: modoProduccion,
                            onChanged: (v) => ref
                                .read(ordenTrabajoProvider)
                                .updatePapelExtra(idx, 'nombre', v),
                          ),
                          _buildInput(
                            "PIEZAS",
                            "0",
                            80,
                            item.piezas,
                            "p_${item.id}",
                            esNumero: true,
                            readOnly: modoProduccion,
                            onChanged: (v) => ref
                                .read(ordenTrabajoProvider)
                                .updatePapelExtra(idx, 'piezas', v),
                          ),
                          _buildInput(
                            "NECESARIO",
                            "0",
                            100,
                            item.papelNecesario,
                            "ncs_${item.id}",
                            readOnly: modoProduccion,
                            onChanged: (v) => ref
                                .read(ordenTrabajoProvider)
                                .updatePapelExtra(idx, 'necesario', v),
                          ),
                          _buildInput(
                            "LLEGARÁ",
                            "0",
                            100,
                            item.papelLlegara,
                            "lgr_${item.id}",
                            readOnly: modoProduccion,
                            onChanged: (v) => ref
                                .read(ordenTrabajoProvider)
                                .updatePapelExtra(idx, 'llegara', v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // >>> REPETICIÓN DE LA MATRIZ DE TINTAS PARA EL SET ADICIONAL <<<
                      const Text(
                        "TINTAS REQUERIDAS PARA ESTE SET",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInkRow(
                        context,
                        ref,
                        'FRENTE',
                        item.tintas['frente'],
                        "frente_${item.id}",
                        modoProduccion,
                        onChanged: (colorKey, value) => ref
                            .read(ordenTrabajoProvider)
                            .updatePapelExtraInk(idx, 'frente', colorKey, value),
                      ),
                      const Divider(height: 16),
                      _buildInkRow(
                        context,
                        ref,
                        'VUELTA',
                        item.tintas['vuelta'],
                        "vuelta_${item.id}",
                        modoProduccion,
                        onChanged: (colorKey, value) => ref
                            .read(ordenTrabajoProvider)
                            .updatePapelExtraInk(idx, 'vuelta', colorKey, value),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            
            if (!modoProduccion)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Agregar otro set de piezas"),
                  onPressed: () => ref.read(ordenTrabajoProvider).agregarPapelExtra(),
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
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                borderSide: BorderSide(color: readOnly ? Colors.grey[300]! : Colors.grey[400]!),
              ),
            ),
            style: TextStyle(fontSize: 13, color: readOnly ? Colors.black54 : Colors.black),
          ),
        ],
      ),
    );
  }

  // >>> HELPER REFACTORIZADO CON CALLBACK "onChanged" DESACOPLADO <<<
  Widget _buildInkRow(
    BuildContext context,
    WidgetRef ref,
    String label,
    Map<String, dynamic> data,
    String uniqueId,
    bool modoProd, {
    required Function(String colorKey, dynamic value) onChanged,
  }) {
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
        _buildInkCheck('C', Colors.cyan, data['C'] ?? false, modoProd, (v) => onChanged('C', v)),
        _buildInkCheck('M', Colors.pink, data['M'] ?? false, modoProd, (v) => onChanged('M', v)),
        _buildInkCheck('Y', Colors.yellow[700]!, data['Y'] ?? false, modoProd, (v) => onChanged('Y', v)),
        _buildInkCheck('K', Colors.black, data['K'] ?? false, modoProd, (v) => onChanged('K', v)),
        const SizedBox(width: 8),
        _buildInkCheck('Especial', Colors.deepPurple, data['especial'] ?? false, modoProd, (v) => onChanged('especial', v)),
        _buildInkCheck('Pantone', Colors.orange, data['pantone'] ?? false, modoProd, (v) => onChanged('pantone', v)),

        if ((data['especial'] ?? false) || (data['pantone'] ?? false))
          Container(
            width: 150,
            margin: const EdgeInsets.only(left: 8, top: 4),
            child: TextFormField(
              key: ValueKey("offset_tinta_esp_${uniqueId}"),
              initialValue: data['tinta_esp'] ?? '',
              readOnly: modoProd,
              onChanged: modoProd ? null : (v) => onChanged('tinta_esp', v),
              decoration: InputDecoration(
                hintText: "Especifique tinta...",
                isDense: true,
                filled: modoProd,
                fillColor: modoProd ? Colors.grey[100] : Colors.white,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: modoProd ? Colors.grey[300]! : Colors.grey[400]!),
                ),
              ),
              style: TextStyle(fontSize: 12, color: modoProd ? Colors.black54 : Colors.black),
            ),
          ),
      ],
    );
  }

  // Helper para los checkboxes individuales
  Widget _buildInkCheck(
    String label,
    Color color,
    bool value,
    bool modoProd,
    Function(bool?) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: color,
          onChanged: modoProd ? null : onChanged,
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