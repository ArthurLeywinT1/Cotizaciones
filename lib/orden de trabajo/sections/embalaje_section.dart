// lib/screens/sections/embalaje_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class EmbalajeSection extends ConsumerWidget {
  final bool modoProduccion;
  const EmbalajeSection({super.key, this.modoProduccion = false});

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
                const Icon(Icons.inventory, color: Colors.brown),
                const SizedBox(width: 8),
                const Text(
                  "11. EMBALAJE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            Row(
              children: [
                // CAMPO: TIPO DE EMPAQUE
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TIPO DE EMPAQUE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        key: ValueKey("embalaje_tipo_${controller.sessionKey}"),
                        initialValue: controller.embalajeTipo,
                        readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                        onChanged: modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateEmbalaje('tipo', v),
                        decoration: InputDecoration(
                          hintText: "Ej: Cajas corrugadas, Playo, Kraft...",
                          isDense: true,
                          filled: modoProduccion,
                          fillColor: modoProduccion ? Colors.grey[100] : null,
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: modoProduccion ? Colors.black54 : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // CAMPO: CANTIDAD DE BULTOS / CAJAS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CANT. BULTOS/CAJAS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        key: ValueKey(
                          "embalaje_cantidad_${controller.sessionKey}",
                        ),
                        initialValue: controller.embalajeCantidadCajas > 0
                            ? controller.embalajeCantidadCajas.toString()
                            : '',
                        keyboardType: TextInputType.number,
                        readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                        onChanged: modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateEmbalaje('cantidad', v),
                        decoration: InputDecoration(
                          hintText: "0",
                          isDense: true,
                          filled: modoProduccion,
                          fillColor: modoProduccion ? Colors.grey[100] : null,
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: modoProduccion ? Colors.black54 : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
              key: ValueKey("embalaje_notas_${controller.sessionKey}"),
              initialValue: controller.embalajeNotas,
              maxLines: 3,
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateEmbalaje('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales para el embalaje"
                    : "Ej: instrucciones para el embalaje, tipo de empaque, si es necesario reforzar las cajas...",
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
              key: ValueKey("embalaje_notas_taller_${controller.sessionKey}"),
              initialValue: controller.embalajeNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion, // <--- EDITABLE SOLO EN PRODUCCIÓN
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateEmbalaje('notasTaller', v),
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

            // --- BOTONES DE ACCIÓN (Solo visibles en taller) ---
            if (modoProduccion) ...[
              const Divider(height: 32, thickness: 1),
              SectionButtons(
                area: 'embalaje',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}