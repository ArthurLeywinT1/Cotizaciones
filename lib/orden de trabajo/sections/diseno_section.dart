import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class DisenoSection extends ConsumerWidget {
  const DisenoSection({super.key});

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
            Row(
              children: [
                const Icon(Icons.draw, color: Colors.purple),
                const SizedBox(width: 8),
                const Text("2. DISEÑO Y PRE-PRENSA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                // Fechas generales del departamento (HUD Visual)
                Row(
                  children: [
                    const Text("Inicio: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    SizedBox(
                      width: 90, 
                      child: TextField(decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.all(4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))))
                    ),
                    const SizedBox(width: 8),
                    const Text("Fin: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    SizedBox(
                      width: 90, 
                      child: TextField(decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.all(4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))))
                    ),
                  ],
                )
              ],
            ),
            const Divider(),
            
            // Cuadros dinámicos de tareas
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.designTasks.map((dp) {
                // Layout responsivo para que mida la mitad en pantallas grandes
                return Container(
                  width: MediaQuery.of(context).size.width > 600 ? 300 : double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: dp.desc,
                          decoration: const InputDecoration(
                            hintText: "Ej: Placas Offset, Negativos...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (v) => dp.desc = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        tooltip: "Borrar tarea",
                        onPressed: () => controller.removeDesignTask(dp.id),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => controller.addDesignTask(),
              icon: const Icon(Icons.add, color: Colors.purple),
              label: const Text("Agregar Proceso de Diseño", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}