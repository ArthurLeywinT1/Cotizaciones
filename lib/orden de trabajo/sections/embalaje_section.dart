// lib/screens/sections/embalaje_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class EmbalajeSection extends ConsumerWidget {
  const EmbalajeSection({super.key});

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
                const Icon(Icons.inventory, color: Colors.brown),
                const SizedBox(width: 8),
                const Text(
                  "11. EMBALAJE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TIPO DE EMPAQUE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        key: ValueKey("embalaje_tipo_${controller.sessionKey}"),
                        initialValue: controller.embalajeTipo,
                        onChanged: (v) => ref
                            .read(ordenTrabajoProvider)
                            .updateEmbalaje('tipo', v),
                        decoration: const InputDecoration(
                          hintText: "Ej: Cajas corrugadas, Playo, Kraft...",
                          isDense: true,
                          border: OutlineInputBorder(),
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
                        "CANT. BULTOS/CAJAS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        key: ValueKey(
                          "embalaje_cantidad_${controller.sessionKey}",
                        ),
                        initialValue: controller.embalajeCantidadCajas > 0
                            ? controller.embalajeCantidadCajas.toString()
                            : '',
                        keyboardType: TextInputType.number,
                        onChanged: (v) => ref
                            .read(ordenTrabajoProvider)
                            .updateEmbalaje('cantidad', v),
                        decoration: const InputDecoration(
                          hintText: "0",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              key: ValueKey("embalaje_notas_${controller.sessionKey}"),
              initialValue: controller.embalajeNotas,
              maxLines: 3,
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateEmbalaje('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Ej: instrucciones para el embalaje, tipo de empaque, si es necesario reforzar las cajas...",
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
}
