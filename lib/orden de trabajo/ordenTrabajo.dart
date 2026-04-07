// lib/screens/ordenTrabajo.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orden_trabajo_provider.dart';
import 'sections/adquisiciones_section.dart';
import 'sections/corte_section.dart';
import 'sections/serigrafia_section.dart';
import 'sections/diseno_section.dart';
import 'sections/offset_section.dart';
import 'sections/laminados_section.dart';
import 'sections/suaje_section.dart';
import 'sections/grabado_section.dart';
import 'sections/acabado_section.dart';
import 'sections/embalaje_section.dart';
import 'sections/logistica_section.dart';

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
          if (controller.activeSections['adquisiciones'] == true) const AdquisicionesSection(),
          if (controller.activeSections['diseño'] == true) const DisenoSection(),
          if (controller.activeSections['offset'] == true) const OffsetSection(),
          if (controller.activeSections['corte'] == true) const CorteSection(),
          if (controller.activeSections['laminados'] == true) const LaminadosSection(),
          if (controller.activeSections['suaje'] == true) const SuajeSection(),
          if (controller.activeSections['grabado'] == true) const GrabadoSection(),
          if (controller.activeSections['serigrafia'] == true) const SerigrafiaSection(),
          if (controller.activeSections['acabado'] == true) const AcabadoSection(),
          if (controller.activeSections['embalaje'] == true) const EmbalajeSection(),
          if (controller.activeSections['logistica'] == true) const LogisticaSection(),

          ],
        ),
      ),
    );
  }
}