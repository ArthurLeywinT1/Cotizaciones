// lib/screens/sections/acabado_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class AcabadoSection extends ConsumerWidget {
  const AcabadoSection({super.key});

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
                const Text("9. ACABADO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            
            // --- 1. PROYECTO ---
            _buildInput(
              "PROYECTO", 
              "Nombre del proyecto...", 
              onChanged: (v) => ref.read(ordenTrabajoProvider).updateAcabado('proyecto', v)
            ),
            const SizedBox(height: 12),

            // --- 2. DATOS DE BASE DE DATOS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DESCRIPCIÓN DEL PROCESO (BD)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      TextField(
                        maxLines: 2,
                        onChanged: (v) => ref.read(ordenTrabajoProvider).updateAcabado('descripcion', v),
                        decoration: InputDecoration(
                          hintText: "Datos que vienen del sistema...",
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[50], 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildInput(
                    "CANTIDAD (BD)", 
                    "0", 
                    esNumero: true,
                    colorFondo: Colors.grey[50],
                    onChanged: (v) => ref.read(ordenTrabajoProvider).updateAcabado('cantidad', v)
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 16),

            // --- 3. ACABADOS MANUALES (AGREGADOS POR EL USUARIO) ---
            const Text("ACABADOS MANUALES ADICIONALES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            
            // Lista de cajitas generadas dinámicamente
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.acabadosManuales.map((acabado) {
                return Container(
                  width: MediaQuery.of(context).size.width > 600 ? 350 : double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // CAMPO 1: DESCRIPCIÓN
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: acabado.desc,
                          decoration: const InputDecoration(
                            hintText: "Ej: Poner fajilla...",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (v) => acabado.desc = v,
                        ),
                      ),
                      
                      // Divisor visual
                      Container(height: 30, width: 1, color: Colors.green[200], margin: const EdgeInsets.symmetric(horizontal: 4)),
                      
                      // CAMPO 2: PIEZAS
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: acabado.piezas, // Ya es seguro contra errores de memoria
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Piezas",
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                          onChanged: (v) => acabado.piezas = v,
                        ),
                      ),

                      // BOTÓN DE BORRAR
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        tooltip: "Borrar acabado",
                        onPressed: () => controller.removeAcabadoManual(acabado.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            
            // Botón para agregar más
            TextButton.icon(
              onPressed: () => controller.addAcabadoManual(),
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              label: const Text("Agregar Acabado Manual", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // --- 4. NOTAS / INSTRUCCIONES EXTRAS ---
            const Text("NOTAS / INSTRUCCIONES EXTRAS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(
              maxLines: 3, 
              onChanged: (v) => ref.read(ordenTrabajoProvider).updateAcabado('notas', v), 
              decoration: InputDecoration(
                hintText: "Escribe aquí cualquier instrucción adicional, cuidado especial, o detalle extra...",
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

  // Helper para no repetir código de los TextFields sencillos
  Widget _buildInput(String label, String hint, {bool esNumero = false, Color? colorFondo, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          onChanged: onChanged,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: colorFondo != null,
            fillColor: colorFondo,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}