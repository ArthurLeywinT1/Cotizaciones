// lib/screens/sections/adquisiciones_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class AdquisicionesSection extends ConsumerWidget {
  const AdquisicionesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado global
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
                Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text("1. ADQUISICIONES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            
            // Tabla / Lista de Materiales
            ...controller.materials.map((m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: m.nombre, 
                      decoration: const InputDecoration(hintText: 'Material', isDense: true, border: OutlineInputBorder()), 
                      onChanged: (v) => m.nombre = v,
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: m.proveedor, 
                      decoration: const InputDecoration(hintText: 'Proveedor', isDense: true, border: OutlineInputBorder()), 
                      onChanged: (v) => m.proveedor = v,
                    )
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: m.cantidad.toString(), 
                      decoration: const InputDecoration(hintText: 'Cant', isDense: true, border: OutlineInputBorder()), 
                      keyboardType: TextInputType.number, 
                      onChanged: (v) => m.cantidad = int.tryParse(v) ?? 0,
                    )
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), 
                    onPressed: () => controller.removeMaterial(m.id),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => controller.addMaterial(), 
              icon: const Icon(Icons.add), 
              label: const Text("Agregar Material")
            ),
          ],
        ),
      ),
    );
  }
}