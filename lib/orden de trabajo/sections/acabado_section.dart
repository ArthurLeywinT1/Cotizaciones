// lib/screens/sections/acabado_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class AcabadoSection extends ConsumerWidget {
  final bool modoProduccion;
  const AcabadoSection({super.key, this.modoProduccion = false});

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
                const Icon(Icons.auto_awesome, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  "9. ACABADO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- 1. PROYECTO ---
            _buildInput(
              "PROYECTO",
              "Nombre del proyecto...",
              controller.acabadoProyecto,
              "acabado_proyecto_${controller.sessionKey}",
              // Es readOnly si ya venía así O si está en modo producción
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateAcabado('proyecto', v),
            ),
            const SizedBox(height: 12),

            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 16),

            // --- 3. ACABADOS MANUALES (AGREGADOS POR EL USUARIO) ---
            const Text(
              "ACABADOS MANUALES ADICIONALES",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),

            // Lista de cajitas generadas dinámicamente
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.acabadosManuales.map((acabado) {
                return Container(
                  width: MediaQuery.of(context).size.width > 600
                      ? 350
                      : double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Cambia el fondo a gris si es modo producción para dar feedback visual
                    color: modoProduccion ? Colors.grey[100] : Colors.green[50],
                    border: Border.all(
                      color: modoProduccion
                          ? Colors.grey[300]!
                          : Colors.green[200]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // CAMPO 1: DESCRIPCIÓN
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: ValueKey(
                            "acabado_desc_${acabado.id}_${controller.sessionKey}",
                          ),
                          initialValue: acabado.desc,
                          readOnly:
                              modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText: "Ej: Poner fajilla...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: modoProduccion
                                ? Colors.black54
                                : Colors.black,
                          ),
                          onChanged: (v) => acabado.desc = v,
                        ),
                      ),

                      // Divisor visual
                      Container(
                        height: 30,
                        width: 1,
                        color: modoProduccion
                            ? Colors.grey[300]
                            : Colors.green[200],
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),

                      // CAMPO 2: PIEZAS
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          key: ValueKey(
                            "acabado_piezas_${acabado.id}_${controller.sessionKey}",
                          ),
                          initialValue: acabado.piezas,
                          keyboardType: TextInputType.number,
                          readOnly:
                              modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                          decoration: const InputDecoration(
                            hintText: "Piezas",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: modoProduccion
                                ? Colors.grey[600]
                                : Colors.green,
                          ),
                          onChanged: (v) => acabado.piezas = v,
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
                          tooltip: "Borrar acabado",
                          onPressed: () =>
                              controller.removeAcabadoManual(acabado.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Botón para agregar más (Oculto en modo producción)
            if (!modoProduccion) ...[
              TextButton.icon(
                onPressed: () => controller.addAcabadoManual(),
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                label: const Text(
                  "Agregar Acabado Manual",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // --- 4. NOTAS / INSTRUCCIONES EXTRAS ---
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
              key: ValueKey("acabado_notas_${controller.sessionKey}"),
              initialValue: controller.acabadoNotas,
              maxLines: 3,
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref
                        .read(ordenTrabajoProvider)
                        .updateAcabado('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas adicionales"
                    : "Ej: Doblez especial, intercalado manual, compaginado, refile final...",
                isDense: true,
                filled: true,
                fillColor: modoProduccion
                    ? Colors.grey[100]
                    : Colors.yellow[50],
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
              key: ValueKey("acabado_notas_taller_${controller.sessionKey}"),
              initialValue: controller.acabadoNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion, // <--- EDITABLE SOLO EN PRODUCCIÓN
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref
                        .read(ordenTrabajoProvider)
                        .updateAcabado('notasTaller', v),
              decoration: InputDecoration(
                hintText: !modoProduccion
                    ? "Sin notas del taller"
                    : "Escribe aquí cualquier observación o nota para esta orden...",
                isDense: true,
                filled: true,
                fillColor: !modoProduccion
                    ? Colors.grey[100]
                    : Colors.blue[50],
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
                area: 'acabado',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper para no repetir código de los TextFields sencillos
  Widget _buildInput(
    String label,
    String hint,
    String initialValue,
    String fieldKey, {
    bool esNumero = false,
    bool readOnly = false,
    Color? colorFondo,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          key: ValueKey(fieldKey),
          initialValue: initialValue,
          readOnly: readOnly,
          onChanged: readOnly ? null : onChanged,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: readOnly || colorFondo != null,
            fillColor: readOnly
                ? Colors.grey[200]
                : (colorFondo ?? Colors.white),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: TextStyle(
            fontSize: 13,
            color: readOnly ? Colors.black54 : Colors.black,
          ),
        ),
      ],
    );
  }
}