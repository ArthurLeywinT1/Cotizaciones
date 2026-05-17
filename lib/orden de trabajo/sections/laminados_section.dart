// lib/screens/sections/laminados_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class LaminadosSection extends ConsumerWidget {
  final bool modoProduccion;
  const LaminadosSection({super.key, this.modoProduccion = false});

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
                        readOnly: modoProduccion, // <--- DINÁMICO EN PRODUCCIÓN
                        onChanged: modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoGeneral('proyecto', v),
                        decoration: InputDecoration(
                          hintText: 'Ej: Portada, Tarjetas...',
                          isDense: true,
                          filled: true,
                          fillColor: modoProduccion ? Colors.grey[100] : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                          filled: modoProduccion,
                          fillColor: modoProduccion ? Colors.grey[100] : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        value: [
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
                              style: TextStyle(
                                fontSize: 13,
                                color: modoProduccion ? Colors.black54 : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: modoProduccion // <--- DESACTIVADO EN PRODUCCIÓN
                            ? null
                            : (val) {
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
                  key: ValueKey("laminado_pliegos_${controller.sessionKey}"),
                  initialValue: controller.laminadoPliegos > 0
                      ? controller.laminadoPliegos.toString()
                      : '',
                  readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                  onChanged: modoProduccion
                      ? null
                      : (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateLaminadoGeneral('pliegos', v),
                  decoration: InputDecoration(
                    hintText: 'Cantidad de pliegos...',
                    isDense: true,
                    filled: true,
                    fillColor: modoProduccion ? Colors.grey[100] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 13, 
                    color: modoProduccion ? Colors.black54 : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECCIÓN DE CONFIGURACIÓN (Aplicación y Máquina) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: modoProduccion ? Colors.grey[50] : Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: modoProduccion ? Colors.grey[300]! : Colors.indigo[100]!,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "APLICACIÓN:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: modoProduccion ? Colors.grey[600] : Colors.indigo,
                          ),
                        ),
                      ),
                      _buildCheck(
                        context,
                        "Frente",
                        controller.laminadoAplicacion['frente']!,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoAplicacion('frente', v!),
                      ),
                      _buildCheck(
                        context,
                        "Vuelta",
                        controller.laminadoAplicacion['vuelta']!,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoAplicacion('vuelta', v!),
                      ),
                    ],
                  ),
                  Divider(
                    color: modoProduccion ? Colors.grey[300] : Colors.indigo,
                    thickness: 0.2,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "MÁQUINA:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: modoProduccion ? Colors.grey[600] : Colors.indigo,
                          ),
                        ),
                      ),
                      _buildCheck(
                        context,
                        "Máquina Chica",
                        controller.laminadoMaquinaChica,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateMaquinaLaminado('chica', v!),
                      ),
                      _buildCheck(
                        context,
                        "Máquina Grande",
                        controller.laminadoMaquinaGrande,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateMaquinaLaminado('grande', v!),
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
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateLaminadoGeneral('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales de laminado"
                    : "Ej: Laminado mate, brillante, soft touch, cuidar que no se raye, dejar pinza libre...",
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
                area: 'laminados',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheck(
    BuildContext context,
    String label,
    bool value,
    Function(bool?)? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: onChanged == null ? Colors.black54 : Colors.black,
            ),
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