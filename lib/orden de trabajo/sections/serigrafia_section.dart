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
        // Guardamos el color directamente en el provider
        ref.read(ordenTrabajoProvider.notifier).updateSerigrafiaColor(color);
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text('Selecciona el color', style: Theme.of(context).textTheme.titleSmall),
      subheading: Text('Tonos', style: Theme.of(context).textTheme.titleSmall),
      wheelSubheading: Text('Color personalizado', style: Theme.of(context).textTheme.titleSmall),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(longPressMenu: true),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodyMedium,
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
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.purple),
                const SizedBox(width: 8),
                const Text("7. SERIGRAFÍA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            
            // Selector de Modo (Radios)
            Row(
              children: [
                Radio<String>(
                  value: 'pantone', 
                  groupValue: controller.serigrafiaModo, 
                  onChanged: (v) => controller.updateSerigrafiaModo(v!)
                ),
                const Text("PANTONE / TEXTO", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'directo', 
                  groupValue: controller.serigrafiaModo, 
                  onChanged: (v) => controller.updateSerigrafiaModo(v!)
                ),
                const Text("COLOR DIRECTO", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 10),

            // MODO 1: Texto libre (Pantone)
            if (controller.serigrafiaModo == 'pantone')
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Código Pantone o Descripción',
                  hintText: 'Ej: Pantone 293 C',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                onChanged: (v) => controller.updateSerigrafiaPantone(v),
              ),

            // MODO 2: Selector de Color Visual
            if (controller.serigrafiaModo == 'directo')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _colorPickerDialog(context, ref, controller.serigrafiaColorDirecto),
                      icon: const Icon(Icons.color_lens),
                      label: const Text("Seleccionar Color Exacto"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Muestra visual del color elegido
                  Container(
                    width: 50, 
                    height: 50,
                    decoration: BoxDecoration(
                      color: controller.serigrafiaColorDirecto,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black26),
                      boxShadow: [
                        BoxShadow(
                          color: controller.serigrafiaColorDirecto.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3)
                        )
                      ]
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}