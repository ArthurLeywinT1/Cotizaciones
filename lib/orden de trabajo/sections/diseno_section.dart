// lib/screens/sections/diseno_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';
import 'section_fecha_entrega.dart';

class DisenoSection extends ConsumerWidget {
  final bool modoProduccion;
  const DisenoSection({super.key, this.modoProduccion = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordenTrabajoProvider);

    final checklistVisible = modoProduccion
        ? controller.disenoChecklist.where((item) => item.activo).toList()
        : controller.disenoChecklist;

    final totalActivos =
        controller.disenoChecklist.where((item) => item.activo).length;
    final totalCompletados = controller.disenoChecklist
        .where((item) => item.activo && item.completado)
        .length;

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
                const Expanded(
                  child: Text(
                    "2. DISEÑO Y PRE-PRENSA",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (totalActivos > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: totalCompletados == totalActivos
                          ? Colors.green[50]
                          : Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: totalCompletados == totalActivos
                            ? Colors.green[300]!
                            : Colors.indigo[200]!,
                      ),
                    ),
                    child: Text(
                      "$totalCompletados / $totalActivos",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: totalCompletados == totalActivos
                            ? Colors.green[800]
                            : Colors.indigo[800],
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            SectionFechaEntrega(area: 'diseno', modoProduccion: modoProduccion, accentColor: Colors.indigo),

            // --- CHECKLIST DE PRE-PRENSA Y DISEÑO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CHECKLIST DE PRE-PRENSA Y DISEÑO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                if (!modoProduccion)
                  Text(
                    "Activa / desactiva pasos",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (checklistVisible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No hay pasos del checklist habilitados para esta orden.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: modoProduccion ? Colors.white : Colors.indigo[50]?.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: modoProduccion
                        ? Colors.grey[300]!
                        : Colors.indigo[100]!,
                  ),
                ),
                child: Column(
                  children: checklistVisible.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final subItemsVisibles = modoProduccion
                        ? item.subItems.where((s) => s.activo).toList()
                        : item.subItems;

                    return Column(
                      children: [
                        if (index > 0)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey[300],
                          ),
                        _buildChecklistRow(
                          ref: ref,
                          item: item,
                          isSubItem: false,
                          parentActivo: true,
                        ),
                        if (subItemsVisibles.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(
                              left: 24,
                              right: 12,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: (!modoProduccion && !item.activo)
                                  ? Colors.grey[100]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: subItemsVisibles.asMap().entries.map((subEntry) {
                                final subIndex = subEntry.key;
                                final subItem = subEntry.value;
                                return Column(
                                  children: [
                                    if (subIndex > 0)
                                      Divider(
                                        height: 1,
                                        thickness: 0.5,
                                        color: Colors.grey[200],
                                      ),
                                    _buildChecklistRow(
                                      ref: ref,
                                      item: subItem,
                                      parentId: item.id,
                                      isSubItem: true,
                                      parentActivo: item.activo,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // --- TAREAS DE DISEÑO REQUERIDAS (CONSERVADO) ---
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
                      color: modoProduccion
                          ? Colors.grey[300]!
                          : Colors.indigo[200]!,
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
                          readOnly:
                              modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText:
                                "Ej: Ajustar rebases, revisar tipografías...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                modoProduccion ? Colors.black54 : Colors.black,
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
                  : (v) =>
                      ref.read(ordenTrabajoProvider).updateDiseno('notas', v),
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
              key: ValueKey("diseno_notas_taller_${controller.sessionKey}"),
              initialValue: controller.disenoNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion, // <--- EDITABLE SOLO EN PRODUCCIÓN
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateDiseno('notasTaller', v),
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
                area: 'diseño',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistRow({
    required WidgetRef ref,
    required ChecklistItem item,
    String? parentId,
    required bool isSubItem,
    required bool parentActivo,
  }) {
    final bool efectivamenteActivo = parentActivo && item.activo;

    // En modo producción, tocar la fila también palomea el paso.
    final Widget contenido = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSubItem ? 8 : 10,
        vertical: isSubItem ? 4 : 6,
      ),
      child: Row(
        children: [
          // Checkbox de avance: editable solo por el usuario de taller (modoProduccion).
          Checkbox(
            value: item.completado,
            activeColor: Colors.green,
            visualDensity: VisualDensity.compact,
            onChanged: modoProduccion
                ? (val) {
                    if (val == null) return;
                    ref
                        .read(ordenTrabajoProvider)
                        .toggleDisenoChecklistCompletado(
                          parentId ?? item.id,
                          val,
                          subItemId: parentId != null ? item.id : null,
                        );
                  }
                : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              item.titulo,
              style: TextStyle(
                fontSize: isSubItem ? 12.5 : 13.5,
                fontWeight: isSubItem ? FontWeight.normal : FontWeight.w600,
                color: !efectivamenteActivo
                    ? Colors.grey[400]
                    : (modoProduccion && item.completado
                        ? Colors.green[800]
                        : Colors.black87),
                decoration: !efectivamenteActivo
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          // En modo admin: interruptor para activar/desactivar si el paso aplica o no.
          if (!modoProduccion)
            Transform.scale(
              scale: isSubItem ? 0.78 : 0.85,
              child: Switch(
                value: item.activo,
                activeColor: Colors.indigo,
                onChanged: parentActivo
                    ? (val) {
                        ref
                            .read(ordenTrabajoProvider)
                            .toggleDisenoChecklistActivo(
                              parentId ?? item.id,
                              val,
                              subItemId: parentId != null ? item.id : null,
                            );
                      }
                    : null,
              ),
            ),
        ],
      ),
    );

    if (modoProduccion) {
      return InkWell(
        onTap: () {
          ref.read(ordenTrabajoProvider).toggleDisenoChecklistCompletado(
                parentId ?? item.id,
                !item.completado,
                subItemId: parentId != null ? item.id : null,
              );
        },
        child: contenido,
      );
    }

    return contenido;
  }
}