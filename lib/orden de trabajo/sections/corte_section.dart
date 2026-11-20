// lib/screens/sections/corte_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';
import 'section_fecha_entrega.dart';

class CorteSection extends ConsumerWidget {
  final bool modoProduccion;
  const CorteSection({super.key, this.modoProduccion = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordenTrabajoProvider);

    final totalCortes = controller.cuts.length;
    final cortesCompletados =
        controller.cuts.where((c) => c.completado).length;

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
                const Icon(Icons.content_cut, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "4. CORTE Y REFILE",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (totalCortes > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cortesCompletados == totalCortes
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cortesCompletados == totalCortes
                            ? Colors.green[300]!
                            : Colors.red[200]!,
                      ),
                    ),
                    child: Text(
                      "$cortesCompletados / $totalCortes",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: cortesCompletados == totalCortes
                            ? Colors.green[800]
                            : Colors.red[800],
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            SectionFechaEntrega(area: 'corte', modoProduccion: modoProduccion, accentColor: Colors.red),

            const Text(
              "PROCESOS DE CORTE EN GUILLOTINA",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            // --- LISTA DINÁMICA DE CORTES ---
            Column(
              children: controller.cuts.asMap().entries.map((entry) {
                final idx = entry.key;
                final cut = entry.value;

                final Color fondoTarjeta = cut.completado
                    ? Colors.green[50]!
                    : (modoProduccion ? Colors.grey[100]! : Colors.red[50]!);
                final Color bordeTarjeta = cut.completado
                    ? Colors.green[300]!
                    : (modoProduccion ? Colors.grey[300]! : Colors.red[200]!);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: fondoTarjeta,
                    border: Border.all(color: bordeTarjeta),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // BARRA SUPERIOR DEL CORTE: CHECK DEL USUARIO + ELIMINAR (ADMIN)
                      Row(
                        children: [
                          Checkbox(
                            value: cut.completado,
                            activeColor: Colors.green,
                            visualDensity: VisualDensity.compact,
                            onChanged: modoProduccion
                                ? (val) {
                                    if (val == null) return;
                                    ref
                                        .read(ordenTrabajoProvider)
                                        .toggleCutCompletado(cut.id, val);
                                  }
                                : null,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: modoProduccion
                                  ? () => ref
                                      .read(ordenTrabajoProvider)
                                      .toggleCutCompletado(
                                        cut.id,
                                        !cut.completado,
                                      )
                                  : null,
                              child: Text(
                                cut.completado
                                    ? "Corte ${idx + 1} - Completado"
                                    : "Corte ${idx + 1}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: cut.completado
                                      ? Colors.green[800]
                                      : (modoProduccion
                                          ? Colors.black87
                                          : Colors.red[800]),
                                ),
                              ),
                            ),
                          ),
                          if (!modoProduccion)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              tooltip: "Borrar corte",
                              onPressed: () => controller.removeCut(cut.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const Divider(height: 8, thickness: 0.5),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CAMPO 1: TIPO / PRODUCTO
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "PRODUCTO",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextFormField(
                                  key: ValueKey(
                                    "corte_tipo_${cut.id}_${controller.sessionKey}",
                                  ),
                                  initialValue: cut.tipo,
                                  readOnly: modoProduccion,
                                  decoration: const InputDecoration(
                                    hintText: "Ej: Tarjetas, Volantes...",
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: modoProduccion
                                        ? Colors.black54
                                        : Colors.black,
                                  ),
                                  onChanged: (v) => cut.tipo = v,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: bordeTarjeta,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          // CAMPO 2: MOMENTO / DESPUÉS DE
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "MOMENTO DEL CORTE",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextFormField(
                                  key: ValueKey(
                                    "corte_momento_${cut.id}_${controller.sessionKey}",
                                  ),
                                  initialValue: cut.despuesDe,
                                  readOnly: modoProduccion,
                                  decoration: const InputDecoration(
                                    hintText: "Ej: Antes de Offset, Final...",
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: modoProduccion
                                        ? Colors.grey[600]
                                        : Colors.red,
                                  ),
                                  onChanged: (v) => cut.despuesDe = v,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 8, thickness: 0.5),

                      // CAMPO 3: DESCRIPCIÓN Y MEDIDAS
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey(
                                "corte_desc_${cut.id}_${controller.sessionKey}",
                              ),
                              initialValue: cut.desc,
                              readOnly: modoProduccion,
                              decoration: const InputDecoration(
                                hintText:
                                    "Medidas finales y descripción del corte (Ej: Refile a marcas de 9x5 cm)...",
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: modoProduccion
                                    ? Colors.black54
                                    : Colors.black,
                              ),
                              onChanged: (v) => cut.desc = v,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Botón para agregar más cortes (Oculto en modo producción)
            if (!modoProduccion)
              TextButton.icon(
                onPressed: () => controller.addCut(),
                icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                label: const Text(
                  "Agregar Proceso de Corte",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              key: ValueKey("corte_notas_extras_${controller.sessionKey}"),
              initialValue: controller.corteNotas,
              maxLines: 3,
              readOnly: modoProduccion,
              onChanged: modoProduccion
                  ? null
                  : (v) =>
                      ref.read(ordenTrabajoProvider).updateCorte('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales para el corte"
                    : "Escribe aquí instrucciones para el guillotino, como el margen de pinza, sangrados, etc...",
                isDense: true,
                filled: true,
                fillColor: modoProduccion ? Colors.grey[100] : Colors.yellow[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: modoProduccion
                        ? Colors.grey[300]!
                        : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: modoProduccion
                        ? Colors.grey[300]!
                        : Colors.yellow[600]!,
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
              key: ValueKey("corte_notas_taller_${controller.sessionKey}"),
              initialValue: controller.corteNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion,
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateCorte('notasTaller', v),
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
                    color: !modoProduccion
                        ? Colors.grey[300]!
                        : Colors.blue[200]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: !modoProduccion
                        ? Colors.grey[300]!
                        : Colors.blue[200]!,
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
                area: 'corte',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}