// lib/screens/sections/adquisiciones_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class AdquisicionesSection extends ConsumerWidget {
  final bool modoProduccion;
  const AdquisicionesSection({super.key, this.modoProduccion = false});

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
                const Icon(Icons.shopping_cart, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  "1. ADQUISICIONES",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            const Text(
              "MATERIALES REQUERIDOS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),

            // --- LISTA DINÁMICA DE MATERIALES ---
            Column(
              children: controller.materials.map((material) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Mutación de color a gris en modo producción
                    color: modoProduccion ? Colors.grey[100] : Colors.teal[50],
                    border: Border.all(
                      color: modoProduccion ? Colors.grey[300]! : Colors.teal[200]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // CAMPO 1: NOMBRE DEL MATERIAL
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: ValueKey(
                            "adq_nom_${material.id}_${controller.sessionKey}",
                          ),
                          initialValue: material.nombre,
                          readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText: "Descripción del material...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: modoProduccion ? Colors.black54 : Colors.black,
                          ),
                          onChanged: (v) => material.nombre = v,
                        ),
                      ),

                      Container(
                        height: 30,
                        width: 1,
                        color: modoProduccion ? Colors.grey[300] : Colors.teal[200],
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),

                      // CAMPO 2: PROVEEDOR
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: ValueKey(
                            "adq_prov_${material.id}_${controller.sessionKey}",
                          ),
                          initialValue: material.proveedor,
                          readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText: "Proveedor sugerido...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: modoProduccion ? Colors.black54 : Colors.black,
                          ),
                          onChanged: (v) => material.proveedor = v,
                        ),
                      ),

                      Container(
                        height: 30,
                        width: 1,
                        color: modoProduccion ? Colors.grey[300] : Colors.teal[200],
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),

                      // CAMPO 3: CANTIDAD
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          key: ValueKey(
                            "adq_cant_${material.id}_${controller.sessionKey}",
                          ),
                          initialValue: material.cantidad == 0
                              ? ''
                              : material.cantidad.toString(),
                          keyboardType: TextInputType.number,
                          readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText: "Cant.",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: modoProduccion ? Colors.grey[600] : Colors.teal,
                          ),
                          onChanged: (v) =>
                              material.cantidad = int.tryParse(v) ?? 0,
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
                          tooltip: "Borrar material",
                          onPressed: () => controller.removeMaterial(material.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Botón para agregar más materiales (Oculto en modo producción)
            if (!modoProduccion)
              TextButton.icon(
                onPressed: () => controller.addMaterial(),
                icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                label: const Text(
                  "Agregar Material",
                  style: TextStyle(
                    color: Colors.teal,
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
              key: ValueKey("adq_notas_${controller.sessionKey}"),
              initialValue: controller.adquisicionesNotas,
              maxLines: 3,
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateAdquisiciones('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales"
                    : "Escribe aquí especificaciones de compra, tiempos de entrega o detalles de crédito...",
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
                area: 'adquisiciones',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}