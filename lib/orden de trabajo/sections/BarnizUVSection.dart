import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class BarnizUVSection extends ConsumerWidget {
  final bool modoProduccion;
  const BarnizUVSection({super.key, this.modoProduccion = false});

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
                  child: _buildLabel(
                    "PROYECTO",
                    TextFormField(
                      key: ValueKey("barniz_proyecto_${controller.sessionKey}"),
                      initialValue: controller.barnizProyecto,
                      onChanged: null,
                      decoration: _inputStyle('Ej: Contraportada...'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLabel(
                    "PLIEGOS",
                    TextFormField(
                      key: ValueKey("barniz_pliegos_${controller.sessionKey}"),
                      initialValue: controller.barnizPliegos > 0
                          ? controller.barnizPliegos.toString()
                          : '',
                      onChanged: null,
                      decoration: _inputStyle('Cant.', readOnly: true),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECCIÓN DE CONFIGURACIÓN ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: modoProduccion ? Colors.grey[100] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: modoProduccion
                      ? Colors.grey[300]!
                      : Colors.orange[100]!,
                ),
              ),
              child: Column(
                children: [
                  // APLICACIÓN (Frente/Vuelta)
                  Row(
                    children: [
                      _buildTitle(
                        "APLICACIÓN:",
                        color: modoProduccion
                            ? Colors.grey[600]
                            : Colors.orange[800],
                      ),
                      _buildCheck(
                        "Frente",
                        controller.barnizAplicacion['frente']!,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                  .read(ordenTrabajoProvider)
                                  .updateBarnizAplicacion('frente', v!),
                      ),
                      _buildCheck(
                        "Vuelta",
                        controller.barnizAplicacion['vuelta']!,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                  .read(ordenTrabajoProvider)
                                  .updateBarnizAplicacion('vuelta', v!),
                      ),
                    ],
                  ),
                  Divider(
                    color: modoProduccion ? Colors.grey[300] : Colors.orange,
                    thickness: 0.2,
                  ),

                  // PRODUCCIÓN (Romosso/Maquilador)
                  Row(
                    children: [
                      _buildTitle(
                        "PRODUCCIÓN:",
                        color: modoProduccion
                            ? Colors.grey[600]
                            : Colors.orange[800],
                      ),
                      _buildCheck(
                        "Romosso",
                        controller.barnizEsRomosso,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                  .read(ordenTrabajoProvider)
                                  .updateBarnizGeneral('romosso', v!),
                      ),
                      _buildCheck(
                        "Maquilador",
                        controller.barnizEsMaquilador,
                        modoProduccion
                            ? null // <--- DESACTIVADO EN PRODUCCIÓN
                            : (v) => ref
                                  .read(ordenTrabajoProvider)
                                  .updateBarnizGeneral('maquilador', v!),
                      ),
                    ],
                  ),

                  // CUADRO DE TEXTO CONDICIONAL
                  if (controller.barnizEsMaquilador) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      key: ValueKey("barniz_maquila_${controller.sessionKey}"),
                      initialValue: controller.barnizNombreMaquila,
                      readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                      onChanged: modoProduccion
                          ? null
                          : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateBarnizGeneral('nombreMaquila', v),
                      decoration:
                          _inputStyle(
                            '¿Quién lo maquila?',
                            readOnly: modoProduccion,
                          ).copyWith(
                            fillColor: modoProduccion
                                ? Colors.grey[200]
                                : Colors.white,
                            filled: true,
                          ),
                      style: TextStyle(
                        fontSize: 13,
                        color: modoProduccion ? Colors.black54 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- NOTAS ---
            _buildLabel(
              "NOTAS / INSTRUCCIONES EXTRAS",
              TextFormField(
                key: ValueKey("barniz_notas_${controller.sessionKey}"),
                initialValue: controller.barnizNotas,
                maxLines: 2,
                readOnly: modoProduccion, // <--- BLOQUEADO EN PRODUCCIÓN
                onChanged: modoProduccion
                    ? null
                    : (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateBarnizGeneral('notas', v),
                decoration:
                    _inputStyle(
                      modoProduccion
                          ? 'Sin instrucciones adicionales'
                          : 'Instrucciones...',
                      readOnly: modoProduccion,
                    ).copyWith(
                      filled: true,
                      fillColor: modoProduccion
                          ? Colors.grey[100]
                          : Colors.yellow[50],
                      enabledBorder: modoProduccion
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: modoProduccion ? Colors.black54 : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel(
              "NOTAS DEL TALLER",
              TextFormField(
                key: ValueKey("barniz_notas_taller_${controller.sessionKey}"),
                initialValue: controller.barnizNotasTaller,
                maxLines: 2,
                readOnly: !modoProduccion, // <--- EDITABLE SOLO EN PRODUCCIÓN
                onChanged: !modoProduccion
                    ? null
                    : (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateBarnizGeneral('notasTaller', v),
                decoration:
                    _inputStyle(
                      !modoProduccion
                          ? 'Sin notas del taller'
                          : 'Escribe aquí cualquier observación o nota para esta orden...',
                      readOnly: !modoProduccion,
                    ).copyWith(
                      filled: true,
                      fillColor: !modoProduccion
                          ? Colors.grey[100]
                          : Colors.blue[50],
                      enabledBorder: !modoProduccion
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: !modoProduccion ? Colors.black54 : Colors.black,
                ),
              ),
            ),

            if (modoProduccion) ...[
              const Divider(height: 32, thickness: 1),
              SectionButtons(
                area: 'barniz',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE ESTILO ---
  InputDecoration _inputStyle(String hint, {bool readOnly = false}) =>
      InputDecoration(
        hintText: hint,
        isDense: true,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: readOnly
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              )
            : null,
      );

  Widget _buildLabel(String label, Widget child) => Column(
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
      child,
    ],
  );

  Widget _buildTitle(String title, {Color? color}) => SizedBox(
    width: 90,
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.orange[800],
      ),
    ),
  );

  Widget _buildCheck(String label, bool val, Function(bool?)? onCh) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: onCh == null ? Colors.black54 : Colors.black,
        ),
      ),
      Checkbox(
        value: val,
        onChanged: onCh,
        activeColor: onCh == null ? Colors.grey : Colors.orange[800],
      ),
      const SizedBox(width: 8),
    ],
  );
}