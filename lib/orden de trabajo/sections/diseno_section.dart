// lib/screens/sections/diseno_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class DisenoSection extends ConsumerWidget {
  final bool modoProduccion;
  const DisenoSection({super.key, this.modoProduccion = false});

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
                const Icon(Icons.design_services, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  "2. DISEÑO Y PRE-PRENSA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            const Text(
              "TAREAS DE DISEÑO REQUERIDAS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),

            // --- LISTA DINÁMICA DE TAREAS ---
            Column(
              children: controller.designTasks.map((task) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Mutación de color a gris en modo producción
                    color: modoProduccion ? Colors.grey[100] : Colors.indigo[50],
                    border: Border.all(
                      color: modoProduccion ? Colors.grey[300]! : Colors.indigo[200]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // CAMPO: DESCRIPCIÓN DE LA TAREA
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(
                            "diseno_task_${task.id}_${controller.sessionKey}",
                          ),
                          initialValue: task.desc,
                          readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText:
                                "Ej: Ajustar rebases, revisar tipografías...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: modoProduccion ? Colors.black54 : Colors.black,
                          ),
                          onChanged: (v) => task.desc = v,
                        ),
                      ),

                      // BOTÓN DE BORRAR (Oculto en modo producción)
                      if (!modoProduccion)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          tooltip: "Borrar tarea",
                          onPressed: () => controller.removeDesignTask(task.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Botón para agregar más tareas (Oculto en modo producción)
            if (!modoProduccion)
              TextButton.icon(
                onPressed: () => controller.addDesignTask(),
                icon: const Icon(Icons.add_circle_outline, color: Colors.indigo),
                label: const Text(
                  "Agregar Tarea",
                  style: TextStyle(
                    color: Colors.indigo,
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
              key: ValueKey("diseno_notas_${controller.sessionKey}"),
              initialValue: controller.disenoNotas,
              maxLines: 3,
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateDiseno('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales de diseño"
                    : "Escribe aquí links a la nube, nombres de archivos originales, perfiles de color...",
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
              key: ValueKey("diseno_notas_taller_${controller.sessionKey}"),
              initialValue: controller.disenoNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion, // <--- EDITABLE SOLO EN PRODUCCIÓN
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref.read(ordenTrabajoProvider).updateDiseno('notasTaller', v),
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
                area: 'diseño',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}