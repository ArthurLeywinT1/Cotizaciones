// lib/screens/ordenTrabajo.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orden_trabajo_provider.dart';
import 'sections/adquisiciones_section.dart';

class OrdenTrabajoScreen extends ConsumerWidget {
  const OrdenTrabajoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor
    final controller = ref.watch(ordenTrabajoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Selector de Secciones (Filtros)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: controller.activeSections.keys.map((key) {
                    final isActive = controller.activeSections[key]!;
                    return FilterChip(
                      label: Text(key.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      selected: isActive,
                      onSelected: (_) => controller.toggleSection(key),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

           //Renderizado Condicional de las Hojas (Secciones)
            if (controller.activeSections['adquisiciones']!) const AdquisicionesSection(),
            
          ],
        ),
      ),
    );
  }
}