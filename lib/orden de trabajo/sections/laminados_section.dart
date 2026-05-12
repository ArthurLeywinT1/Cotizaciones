import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

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

            // --- FILA 1: PROYECTO Y ACABADO ---
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
                          "laminado_proyecto_${controller.sessionKey}",
                        ),
                        initialValue: controller.laminadoProyecto,
                        readOnly: true,
                        onChanged: null,
                        decoration: InputDecoration(
                          hintText: 'Ej: Portada, Tarjetas...',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
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
                        value:
                            [
                              'Brillante',
                              'Mate',
                              'Otro',
                            ].contains(controller.laminadoAcabado)
                            ? controller.laminadoAcabado
                            : 'Brillante',
                        items: ['Brillante', 'Mate', 'Otro'].map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoGeneral('acabado', val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- NUEVA FILA: PLIEGOS ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PLIEGOS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  // Asumiendo que tienes 'pliegos' en tu provider, si no, cámbialo por el campo correcto
                  initialValue: controller.laminadoPliegos > 0
                      ? controller.laminadoPliegos.toString()
                      : '',
                  readOnly: true,
                  onChanged: null,
                  decoration: InputDecoration(
                    hintText: 'Cantidad de pliegos...',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number, // Teclado numérico
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                children: [
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
              key: ValueKey("laminado_notas_${controller.sessionKey}"),
              initialValue: controller.laminadoNotas,
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
            // --- BOTONES (OCULTOS) ---
            // Usamos Visibility con false para que no ocupen espacio ni se vean
            const Visibility(
              visible: false, 
              child: SectionButtons(),
            ),
          ],
        ),
      ),
    );
  }

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
