import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class BarnizUVSection extends ConsumerWidget {
  const BarnizUVSection({super.key});

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
                const Icon(Icons.opacity, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  "10. BARNIZ UV",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- PROYECTO Y PLIEGOS ---
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildLabel("PROYECTO", TextFormField(
                    initialValue: controller.barnizProyecto,
                    onChanged: (v) => controller.updateBarnizGeneral('proyecto', v),
                    decoration: _inputStyle('Ej: Contraportada...'),
                    style: const TextStyle(fontSize: 13),
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLabel("PLIEGOS", TextFormField(
                    initialValue: controller.barnizPliegos.toString(),
                    onChanged: (v) => controller.updateBarnizGeneral('pliegos', v),
                    decoration: _inputStyle('Cant.'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECCIÓN DE CONFIGURACIÓN ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Column(
                children: [
                  // APLICACIÓN (Frente/Vuelta)
                  Row(
                    children: [
                      _buildTitle("APLICACIÓN:"),
                      _buildCheck("Frente", controller.barnizAplicacion['frente']!, 
                        (v) => controller.updateBarnizAplicacion('frente', v!)),
                      _buildCheck("Vuelta", controller.barnizAplicacion['vuelta']!, 
                        (v) => controller.updateBarnizAplicacion('vuelta', v!)),
                    ],
                  ),
                  const Divider(color: Colors.orange, thickness: 0.2),

                  // PRODUCCIÓN (Romosso/Maquilador)
                  Row(
                    children: [
                      _buildTitle("PRODUCCIÓN:"),
                      _buildCheck("Romosso", controller.barnizEsRomosso, 
                        (v) => controller.updateBarnizGeneral('romosso', v!)),
                      _buildCheck("Maquilador", controller.barnizEsMaquilador, 
                        (v) => controller.updateBarnizGeneral('maquilador', v!)),
                    ],
                  ),

                  // CUADRO DE TEXTO CONDICIONAL
                  if (controller.barnizEsMaquilador) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: controller.barnizNombreMaquila,
                      onChanged: (v) => controller.updateBarnizGeneral('nombreMaquila', v),
                      decoration: _inputStyle('¿Quién lo maquila?').copyWith(
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- NOTAS ---
            _buildLabel("NOTAS / INSTRUCCIONES EXTRAS", TextField(
              maxLines: 2,
              onChanged: (v) => controller.updateBarnizGeneral('notas', v),
              decoration: _inputStyle('Instrucciones...').copyWith(
                filled: true,
                fillColor: Colors.yellow[50],
              ),
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            )),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE ESTILO ---
  InputDecoration _inputStyle(String hint) => InputDecoration(
    hintText: hint, isDense: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _buildLabel(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 4), child,
    ],
  );

  Widget _buildTitle(String title) => SizedBox(width: 90,
    child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange[800])),
  );

  Widget _buildCheck(String label, bool val, Function(bool?) onCh) => Row(
    children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      Checkbox(value: val, onChanged: onCh, activeColor: Colors.orange[800]),
      const SizedBox(width: 8),
    ],
  );
}