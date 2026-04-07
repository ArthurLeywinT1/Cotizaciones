import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class CorteSection extends ConsumerWidget {
  const CorteSection({super.key});

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
                const Icon(Icons.cut, color: Colors.orange),
                const SizedBox(width: 8),
                const Text("4. CORTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => controller.addCut(), 
                  icon: const Icon(Icons.add), 
                  label: const Text("Agregar Corte")
                )
              ],
            ),
            const Divider(),
            
            // Genera una fila visual por cada elemento en la lista de mentira
            ...controller.cuts.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(child: TextFormField(initialValue: c.tipo, decoration: const InputDecoration(labelText: 'Tipo', isDense: true, border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: TextFormField(initialValue: c.desc, decoration: const InputDecoration(labelText: 'Descripción', isDense: true, border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  // Dropdown visual falso
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: c.despuesDe,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), labelText: 'Después de'),
                      items: ['Adquisiciones', 'Diseño', 'Offset', 'Laminado', 'Suaje', 'grabado', 'serigrafía', 'acabado'].map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {},
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), 
                    onPressed: () => controller.removeCut(c.id),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}