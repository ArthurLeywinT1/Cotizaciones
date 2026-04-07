// lib/screens/sections/serigrafia_section.dart
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class SerigrafiaSection extends ConsumerWidget {
  const SerigrafiaSection({super.key});

  // Función para abrir el diálogo de ColorPicker
  Future<bool> _colorPickerDialog(BuildContext context, WidgetRef ref, Color currentColor) async {
    return ColorPicker(
      color: currentColor,
      onColorChanged: (Color color) {
        ref.read(ordenTrabajoProvider).updateSerigrafiaColor(color);
      },
      width: 40, height: 40, borderRadius: 4, spacing: 5, runSpacing: 5, wheelDiameter: 155,
      heading: Text('Selecciona el color', style: Theme.of(context).textTheme.titleSmall),
      subheading: Text('Tonos', style: Theme.of(context).textTheme.titleSmall),
      wheelSubheading: Text('Color personalizado', style: Theme.of(context).textTheme.titleSmall),
      showMaterialName: true, showColorName: true, showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(longPressMenu: true),
      pickerTypeLabels: const <ColorPickerType, String>{
        ColorPickerType.both: 'Ambos', ColorPickerType.primary: 'Primario', ColorPickerType.accent: 'Acento',
        ColorPickerType.bw: 'B&N', ColorPickerType.custom: 'Personalizado', ColorPickerType.wheel: 'Rueda',
      },
    ).showPickerDialog(
      context,
      constraints: const BoxConstraints(minHeight: 480, minWidth: 300, maxWidth: 320),
    );
  }

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
                const Icon(Icons.palette, color: Colors.purple),
                const SizedBox(width: 8),
                const Text("7. SERIGRAFÍA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),

            // --- 1. PROYECTO Y PIEZAS ---
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInput(
                    "PROYECTO", "Nombre del proyecto...", 
                    onChanged: (v) => controller.updateSerigrafiaGeneral('proyecto', v)
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildInput(
                    "PIEZAS SOLICITADAS", "0", esNumero: true, 
                    onChanged: (v) => controller.updateSerigrafiaGeneral('piezas', v)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 2. SELECTOR DE COLOR ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CONFIGURACIÓN DE COLOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
                  Row(
                    children: [
                      Radio<String>(value: 'pantone', groupValue: controller.serigrafiaModo, onChanged: (v) => controller.updateSerigrafiaModo(v!)),
                      const Text("PANTONE / TEXTO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Radio<String>(value: 'directo', groupValue: controller.serigrafiaModo, onChanged: (v) => controller.updateSerigrafiaModo(v!)),
                      const Text("COLOR DIRECTO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  // Modo Pantone (Texto libre)
                  if (controller.serigrafiaModo == 'pantone')
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Ej: Pantone 293 C, Blanco Mate...',
                        isDense: true, filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (v) => controller.updateSerigrafiaPantone(v),
                    ),

                  // Modo Color Directo (Selector Visual)
                  if (controller.serigrafiaModo == 'directo')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _colorPickerDialog(context, ref, controller.serigrafiaColorDirecto),
                            icon: const Icon(Icons.color_lens),
                            label: const Text("Abrir Paleta de Colores"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.purple),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 45, height: 45,
                          decoration: BoxDecoration(
                            color: controller.serigrafiaColorDirecto,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black26),
                            boxShadow: [BoxShadow(color: controller.serigrafiaColorDirecto.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))]
                          ),
                        )
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
                    "DETALLE DE MARCOS", "Descripción o medidas...", 
                    onChanged: (v) => controller.updateSerigrafiaGeneral('marcos', v)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("ESTADO DEL MARCO: ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                _buildCheck("Existente", controller.serigrafiaMarcoExistente, (v) => controller.updateSerigrafiaGeneral('marcoExistente', v!)),
                _buildCheck("Nuevo", controller.serigrafiaMarcoNuevo, (v) => controller.updateSerigrafiaGeneral('marcoNuevo', v!)),
              ],
            ),
            
            const Divider(height: 24),

            // --- 4. RESPONSABLE (Romosso / Maquilador) ---
            const Text("RESPONSABLE DEL PROCESO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildCheck("Romosso", controller.serigrafiaEsRomosso, (v) => controller.updateSerigrafiaGeneral('romosso', v!)),
                _buildCheck("Maquilador", controller.serigrafiaEsMaquilador, (v) => controller.updateSerigrafiaGeneral('maquilador', v!)),
                
                // Cuadro condicional de Maquilador
                if (controller.serigrafiaEsMaquilador)
                  SizedBox(
                    width: 250,
                    child: TextField(
                      onChanged: (v) => controller.updateSerigrafiaGeneral('nombreMaquila', v),
                      decoration: const InputDecoration(
                        labelText: "Nombre de quien maquila",
                        isDense: true, border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business, size: 18),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
            // --- NOTAS / INSTRUCCIONES EXTRAS ---
            const Text("NOTAS / INSTRUCCIONES EXTRAS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(
              maxLines: 3,
              onChanged: (v) => ref.read(ordenTrabajoProvider).updateSerigrafiaGeneral('notas', v),
              decoration: InputDecoration(
                hintText: "Ej: Serigrafía a mano, digital, colores específicos...",
                isDense: true,
                filled: true,
                fillColor: Colors.yellow[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow[600]!, width: 0.5)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow[600]!, width: 0.5)
                ),
              ),
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),

          ],
        ),
      ),
    );
  }

  // Helpers para ahorrar código
  Widget _buildInput(String label, String hint, {bool esNumero = false, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          onChanged: onChanged,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint, isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCheck(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Checkbox(value: value, onChanged: onChanged, activeColor: Colors.purple),
        ],
      ),
    );
  }
}