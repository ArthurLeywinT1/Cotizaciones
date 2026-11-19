import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

            // --- ENCABEZADO TINTAS + CUADRO DE TEXTO "PLIEGOS" ---
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "TINTAS REQUERIDAS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: modoProduccion ? Colors.grey[600] : Colors.blue,
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    key: ValueKey(
                      "offset_cant_pliegos_${controller.sessionKey}",
                    ),
                    initialValue: controller.offsetCantidadPliegos.toString(),
                    readOnly: modoProduccion,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: modoProduccion
                        ? null
                        : (v) => ref
                            .read(ordenTrabajoProvider)
                            .updateOffsetCantidadPliegos(v),
                    decoration: InputDecoration(
                      labelText: "Pliegos",
                      hintText: "1",
                      isDense: true,
                      filled: true,
                      fillColor:
                          modoProduccion ? Colors.grey[100] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: modoProduccion
                              ? Colors.grey[300]!
                              : Colors.blue[300]!,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: modoProduccion ? Colors.black54 : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- MATRIZ DE TINTAS POR CADA PLIEGO (FRENTE Y VUELTA LADO A LADO) ---
            ...controller.offsetPliegosTintas.asMap().entries.map((entry) {
              final int idx = entry.key;
              final OffsetPliegoTintas pliego = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: modoProduccion
                      ? Colors.grey[50]
                      : Colors.blue[50]?.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: modoProduccion
                        ? Colors.grey[300]!
                        : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre editable del pliego (por defecto: Pliego 1, Pliego 2, ...)
                    SizedBox(
                      width: 260,
                      child: TextFormField(
                        key: ValueKey(
                          "offset_pliego_nombre_${pliego.id}_${controller.sessionKey}",
                        ),
                        initialValue: pliego.nombre,
                        readOnly: modoProduccion,
                        onChanged: modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateOffsetPliegoNombre(idx, v),
                        decoration: InputDecoration(
                          labelText: "Identificador del pliego",
                          hintText: "Pliego ${idx + 1}",
                          isDense: true,
                          filled: true,
                          fillColor: modoProduccion
                              ? Colors.grey[100]
                              : Colors.white,
                          prefixIcon: Icon(
                            Icons.layers_outlined,
                            size: 18,
                            color: modoProduccion
                                ? Colors.grey[600]
                                : Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: modoProduccion
                                  ? Colors.grey[300]!
                                  : Colors.blue[200]!,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: modoProduccion
                              ? Colors.black54
                              : Colors.blue[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // FRENTE y VUELTA lado a lado
                    _buildFrenteVueltaLadoALado(
                      frenteData: pliego.frente,
                      vueltaData: pliego.vuelta,
                      uniquePrefix: "${pliego.id}_${controller.sessionKey}",
                      modoProd: modoProduccion,
                      onChanged: (cara, colorKey, value) => ref
                          .read(ordenTrabajoProvider)
                          .updateOffsetPliegoInk(idx, cara, colorKey, value),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
                color: !modoProduccion ? Colors.black54 : Colors.black,
              ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
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

                      // Tintas para el set adicional (FRENTE y VUELTA lado a lado)
                      const Text(
                        "TINTAS REQUERIDAS PARA ESTE SET",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFrenteVueltaLadoALado(
                        frenteData: item.tintas['frente'],
                        vueltaData: item.tintas['vuelta'],
                        uniquePrefix: "extra_${item.id}",
                        modoProd: modoProduccion,
                        onChanged: (cara, colorKey, value) => ref
                            .read(ordenTrabajoProvider)
                            .updatePapelExtraInk(idx, cara, colorKey, value),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (!modoProduccion)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Agregar otro set de piezas"),
                  onPressed: () =>
                      ref.read(ordenTrabajoProvider).agregarPapelExtra(),
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
      ),
    );
  }

  // Paneles de FRENTE y VUELTA colocados lado a lado
  Widget _buildFrenteVueltaLadoALado({
    required Map<String, dynamic> frenteData,
    required Map<String, dynamic> vueltaData,
    required String uniquePrefix,
    required bool modoProd,
    required Function(String cara, String colorKey, dynamic value) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInkPanel(
            label: 'FRENTE',
            data: frenteData,
            uniqueId: 'frente_$uniquePrefix',
            modoProd: modoProd,
            onChanged: (colorKey, value) =>
                onChanged('frente', colorKey, value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInkPanel(
            label: 'VUELTA',
            data: vueltaData,
            uniqueId: 'vuelta_$uniquePrefix',
            modoProd: modoProd,
            onChanged: (colorKey, value) =>
                onChanged('vuelta', colorKey, value),
          ),
        ),
      ],
    );
  }

  // Panel individual de tintas (Frente o Vuelta)
  Widget _buildInkPanel({
    required String label,
    required Map<String, dynamic> data,
    required String uniqueId,
    required bool modoProd,
    required Function(String colorKey, dynamic value) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: modoProd ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: modoProd ? Colors.grey[300]! : Colors.blue[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: modoProd ? Colors.black54 : Colors.blue[800],
            ),
          ),
          const Divider(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              _buildInkCheck('C', Colors.cyan, data['C'] ?? false, modoProd,
                  (v) => onChanged('C', v)),
              _buildInkCheck('M', Colors.pink, data['M'] ?? false, modoProd,
                  (v) => onChanged('M', v)),
              _buildInkCheck('Y', Colors.yellow[700]!, data['Y'] ?? false,
                  modoProd, (v) => onChanged('Y', v)),
              _buildInkCheck('K', Colors.black, data['K'] ?? false, modoProd,
                  (v) => onChanged('K', v)),
              _buildInkCheck('Especial', Colors.deepPurple,
                  data['especial'] ?? false, modoProd,
                  (v) => onChanged('especial', v)),
              _buildInkCheck('Pantone', Colors.orange, data['pantone'] ?? false,
                  modoProd, (v) => onChanged('pantone', v)),
            ],
          ),
          if ((data['especial'] ?? false) || (data['pantone'] ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                key: ValueKey("offset_tinta_esp_$uniqueId"),
                initialValue: data['tinta_esp'] ?? '',
                readOnly: modoProd,
                onChanged: modoProd ? null : (v) => onChanged('tinta_esp', v),
                decoration: InputDecoration(
                  hintText: "Especifique tinta...",
                  isDense: true,
                  filled: true,
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
      ),
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
          visualDensity: VisualDensity.compact,
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