// lib/screens/sections/serigrafia_section.dart
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class SerigrafiaSection extends ConsumerWidget {
  final bool modoProduccion;
  const SerigrafiaSection({super.key, this.modoProduccion = false});

  // Función para abrir el diálogo de ColorPicker
  Future<bool> _colorPickerDialog(
    BuildContext context,
    WidgetRef ref,
    Color currentColor,
  ) async {
    // Si está en modo producción, se cancela la ejecución de la paleta
    if (modoProduccion) return false;

    return ColorPicker(
      color: currentColor,
      onColorChanged: (Color color) {
        ref.read(ordenTrabajoProvider).updateSerigrafiaColor(color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Selecciona el color',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text('Tonos', style: Theme.of(context).textTheme.titleSmall),
      wheelSubheading: Text(
        'Color personalizado',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      pickerTypeLabels: const <ColorPickerType, String>{
        ColorPickerType.both: 'Ambos',
        ColorPickerType.primary: 'Primario',
        ColorPickerType.accent: 'Acento',
        ColorPickerType.bw: 'B&N',
        ColorPickerType.custom: 'Personalizado',
        ColorPickerType.wheel: 'Rueda',
      },
    ).showPickerDialog(
      context,
      constraints: const BoxConstraints(
        minHeight: 480,
        minWidth: 300,
        maxWidth: 320,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordenTrabajoProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: modoProduccion ? Colors.grey[300]! : Colors.purple[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Row(
              children: [
                Icon(
                  Icons.palette, 
                  color: modoProduccion ? Colors.grey[700] : Colors.purple,
                ),
                const SizedBox(width: 8),
                const Text(
                  "7. SERIGRAFÍA",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- 1. PROYECTO Y PIEZAS ---
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInput(
                    "PROYECTO",
                    "Nombre del proyecto...",
                    controller.serigrafiaProyecto,
                    "serigrafia_proyecto_${controller.sessionKey}",
                    readOnly: modoProduccion, // <--- DINÁMICO
                    onChanged: (v) =>
                        controller.updateSerigrafiaGeneral('proyecto', v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildInput(
                    "PIEZAS SOLICITADAS",
                    "0",
                    controller.serigrafiaPiezas > 0
                        ? controller.serigrafiaPiezas.toString()
                        : "",
                    "serigrafia_piezas_${controller.sessionKey}",
                    esNumero: true,
                    readOnly: modoProduccion, // <--- DINÁMICO
                    onChanged: (v) =>
                        controller.updateSerigrafiaGeneral('piezas', v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 2. SELECTOR DE COLOR ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: modoProduccion ? Colors.grey[50] : Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: modoProduccion ? Colors.grey[300]! : Colors.purple[100]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CONFIGURACIÓN DE COLOR",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: modoProduccion ? Colors.grey[600] : Colors.purple,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'pantone',
                        groupValue: controller.serigrafiaModo,
                        onChanged: modoProduccion 
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => controller.updateSerigrafiaModo(v!),
                      ),
                      Text(
                        "PANTONE / TEXTO",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: modoProduccion ? Colors.black54 : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'directo',
                        groupValue: controller.serigrafiaModo,
                        onChanged: modoProduccion 
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => controller.updateSerigrafiaModo(v!),
                      ),
                      Text(
                        "COLOR DIRECTO",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: modoProduccion ? Colors.black54 : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Modo Pantone (Texto libre)
                  if (controller.serigrafiaModo == 'pantone')
                    TextFormField(
                      key: ValueKey(
                        "serigrafia_pantone_code_${controller.sessionKey}",
                      ),
                      initialValue: controller.serigrafiaPantoneCode,
                      readOnly: modoProduccion,
                      onChanged: modoProduccion 
                          ? null 
                          : (v) => controller.updateSerigrafiaPantone(v),
                      decoration: InputDecoration(
                        hintText: 'Ej: Pantone 293 C, Blanco Mate...',
                        isDense: true,
                        filled: true,
                        fillColor: modoProduccion ? Colors.grey[100] : Colors.white,
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

                  // Modo Color Directo (Selector Visual)
                  if (controller.serigrafiaModo == 'directo')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: modoProduccion 
                                ? null // <--- DESACTIVADO EN PRODUCCIÓN
                                : () => _colorPickerDialog(
                                      context,
                                      ref,
                                      controller.serigrafiaColorDirecto,
                                    ),
                            icon: const Icon(Icons.color_lens),
                            label: const Text("Abrir Paleta de Colores"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: modoProduccion ? Colors.grey[200] : Colors.white,
                              foregroundColor: modoProduccion ? Colors.grey[500] : Colors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: controller.serigrafiaColorDirecto,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black26),
                            boxShadow: [
                              BoxShadow(
                                color: controller.serigrafiaColorDirecto
                                    .withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. MARCOS ---
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "DETALLE DE MARCOS",
                    "Descripción o medidas...",
                    controller.serigrafiaMarcos,
                    "serigrafia_marcos_${controller.sessionKey}",
                    readOnly: modoProduccion, // <--- DINÁMICO
                    onChanged: (v) =>
                        controller.updateSerigrafiaGeneral('marcos', v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "ESTADO DEL MARCO: ",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                _buildCheck(
                  "Existente",
                  controller.serigrafiaMarcoExistente,
                  modoProduccion 
                      ? null // <--- BLOQUEADO EN PRODUCCIÓN
                      : (v) => controller.updateSerigrafiaGeneral('marcoExistente', v!),
                ),
                _buildCheck(
                  "Nuevo",
                  controller.serigrafiaMarcoNuevo,
                  modoProduccion 
                      ? null // <--- BLOQUEADO EN PRODUCCIÓN
                      : (v) => controller.updateSerigrafiaGeneral('marcoNuevo', v!),
                ),
              ],
            ),

            const Divider(height: 24),

            // --- 4. RESPONSABLE (Romosso / Maquilador) ---
            const Text(
              "RESPONSABLE DEL PROCESO",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildCheck(
                  "Romosso",
                  controller.serigrafiaEsRomosso,
                  modoProduccion 
                      ? null // <--- BLOQUEADO EN PRODUCCIÓN
                      : (v) => controller.updateSerigrafiaGeneral('romosso', v!),
                ),
                _buildCheck(
                  "Maquilador",
                  controller.serigrafiaEsMaquilador,
                  modoProduccion 
                      ? null // <--- BLOQUEADO EN PRODUCCIÓN
                      : (v) => controller.updateSerigrafiaGeneral('maquilador', v!),
                ),

                // Cuadro condicional de Maquilador
                if (controller.serigrafiaEsMaquilador)
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      key: ValueKey(
                        "serigrafia_nombre_maquila_${controller.sessionKey}",
                      ),
                      initialValue: controller.serigrafiaNombreMaquila,
                      readOnly: modoProduccion, // <--- DINÁMICO
                      onChanged: modoProduccion 
                          ? null 
                          : (v) => controller.updateSerigrafiaGeneral('nombreMaquila', v),
                      decoration: InputDecoration(
                        labelText: "Nombre de quien maquila",
                        isDense: true,
                        filled: modoProduccion,
                        fillColor: modoProduccion ? Colors.grey[100] : null,
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.business, size: 18),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: modoProduccion ? Colors.black54 : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
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
              key: ValueKey("serigrafia_notas_extras_${controller.sessionKey}"),
              initialValue: controller.serigrafiaNotas,
              maxLines: 3,
              readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
              onChanged: modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateSerigrafiaGeneral('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales de serigrafía"
                    : "Ej: Serigrafía a mano, digital, colores específicos...",
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
                area: 'serigrafia',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helpers para ahorrar código
  Widget _buildInput(
    String label,
    String hint,
    String initialValue,
    String fieldKey, {
    bool esNumero = false,
    bool readOnly = false,
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
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? Colors.grey[300]! : Colors.grey[400]!,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: 13,
            color: readOnly ? Colors.black54 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCheck(String label, bool value, Function(bool?)? onChanged) {
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
            onChanged: onChanged, // Si es null, el control se deshabilita automáticamente
            activeColor: onChanged == null ? Colors.grey : Colors.purple,
          ),
        ],
      ),
    );
  }
}