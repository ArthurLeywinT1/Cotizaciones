import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class LaminadosSection extends ConsumerWidget {
  const LaminadosSection({super.key});

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
                const Icon(Icons.layers, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  "5. LAMINADOS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PROYECTO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        key: ValueKey(
                          controller.laminadoProyecto,
                        ), // Reacciona a los cambios en el estado
                        initialValue: controller.laminadoProyecto,
                        onChanged: (v) => ref
                            .read(ordenTrabajoProvider)
                            .updateLaminadoGeneral('proyecto', v),
                        decoration: InputDecoration(
                          hintText: 'Ej: Portada, Tarjetas...',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ACABADO (BD)",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: 'Brillante',
                        items: ['Brillante', 'Mate', 'Otro'].map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECCIÓN DE CONFIGURACIÓN (Aplicación y Máquina) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo[100]!),
              ),
              child: Column(
                // Cambiamos a Column para organizar mejor las dos filas de opciones
                children: [
                  // Fila 1: Aplicación
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "APLICACIÓN:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      _buildCheck(
                        context,
                        "Frente",
                        controller.laminadoAplicacion['frente']!,
                        (v) =>
                            controller.updateLaminadoAplicacion('frente', v!),
                      ),
                      _buildCheck(
                        context,
                        "Vuelta",
                        controller.laminadoAplicacion['vuelta']!,
                        (v) =>
                            controller.updateLaminadoAplicacion('vuelta', v!),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.indigo, thickness: 0.2),
                  // Fila 2: Máquina
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          "MÁQUINA:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      _buildCheck(
                        context,
                        "Máquina Chica",
                        controller.laminadoMaquinaChica,
                        (v) => controller.updateMaquinaLaminado('chica', v!),
                      ),
                      _buildCheck(
                        context,
                        "Máquina Grande",
                        controller.laminadoMaquinaGrande,
                        (v) => controller.updateMaquinaLaminado('grande', v!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
            TextField(
              maxLines: 3,
              onChanged: (v) => ref
                  .read(ordenTrabajoProvider)
                  .updateLaminadoGeneral('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Ej: Laminado mate, brillante, soft touch, cuidar que no se raye, dejar pinza libre...",
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
          ],
        ),
      ),
    );
  }

  // Pequeño widget para no repetir código de checkbox
  Widget _buildCheck(
    BuildContext context,
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}
