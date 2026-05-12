// lib/screens/sections/adquisiciones_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class AdquisicionesSection extends ConsumerWidget {
  const AdquisicionesSection({super.key});

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
                    color: Colors.teal[50],
                    border: Border.all(color: Colors.teal[200]!),
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
                          decoration: const InputDecoration(
                            hintText: "Descripción del material...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (v) => material.nombre = v,
                        ),
                      ),

                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.teal[200],
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
                          decoration: const InputDecoration(
                            hintText: "Proveedor sugerido...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (v) => material.proveedor = v,
                        ),
                      ),

                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.teal[200],
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),

                      // CAMPO 3: CANTIDAD
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          // Para que no muestre un "0" inicial si está vacío
                          key: ValueKey(
                            "adq_cant_${material.id}_${controller.sessionKey}",
                          ),
                          initialValue: material.cantidad == 0
                              ? ''
                              : material.cantidad.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Cant.",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          onChanged: (v) =>
                              material.cantidad = int.tryParse(v) ?? 0,
                        ),
                      ),

                      // BOTÓN DE BORRAR
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

            // Botón para agregar más materiales
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
              onChanged: (v) => ref
                  .read(ordenTrabajoProvider)
                  .updateAdquisiciones('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Escribe aquí especificaciones de compra, tiempos de entrega o detalles de crédito...",
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
            // --- BOTONES (OCULTOS) ---
            // Usamos Visibility con false para que no ocupen espacio ni se vean
            const Visibility(
              visible: true, 
              child: SectionButtons(),
            ),
          ],
        ),
      ),
    );
  }
}
