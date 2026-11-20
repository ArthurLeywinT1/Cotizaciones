// lib/screens/sections/laminados_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';
import 'section_fecha_entrega.dart';

class LaminadosSection extends ConsumerWidget {
  final bool modoProduccion;
  const LaminadosSection({super.key, this.modoProduccion = false});

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
                const Icon(Icons.layers, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  "5. LAMINADOS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            SectionFechaEntrega(area: 'laminados', modoProduccion: modoProduccion, accentColor: Colors.indigo),

            // --- FILA 1: PROYECTO Y ACABADO ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PROYECTO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        key: ValueKey(
                          "laminado_proyecto_${controller.sessionKey}",
                        ),
                        initialValue: controller.laminadoProyecto,
                        readOnly: modoProduccion,
                        onChanged: modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoGeneral('proyecto', v),
                        decoration: InputDecoration(
                          hintText: 'Ej: Portada, Tarjetas...',
                          isDense: true,
                          filled: true,
                          fillColor:
                              modoProduccion ? Colors.grey[100] : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: modoProduccion
                                  ? Colors.grey[300]!
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: modoProduccion ? Colors.black54 : Colors.black,
                        ),
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
                        "ACABADO (BD)",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          isDense: true,
                          filled: modoProduccion,
                          fillColor: modoProduccion ? Colors.grey[100] : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: modoProduccion
                                  ? Colors.grey[300]!
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        value: [
                          'Brillante',
                          'Mate',
                          'Otro',
                        ].contains(controller.laminadoAcabado)
                            ? controller.laminadoAcabado
                            : 'Brillante',
                        items: ['Brillante', 'Mate', 'Otro'].map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: TextStyle(
                                fontSize: 13,
                                color: modoProduccion
                                    ? Colors.black54
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: modoProduccion
                            ? null
                            : (val) {
                                if (val != null) {
                                  ref
                                      .read(ordenTrabajoProvider)
                                      .updateLaminadoGeneral('acabado', val);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- FILA 2: PLIEGOS ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PLIEGOS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  key: ValueKey("laminado_pliegos_${controller.sessionKey}"),
                  initialValue: controller.laminadoPliegos > 0
                      ? controller.laminadoPliegos.toString()
                      : '',
                  readOnly: modoProduccion,
                  onChanged: modoProduccion
                      ? null
                      : (v) => ref
                          .read(ordenTrabajoProvider)
                          .updateLaminadoGeneral('pliegos', v),
                  decoration: InputDecoration(
                    hintText: 'Cantidad de pliegos...',
                    isDense: true,
                    filled: true,
                    fillColor: modoProduccion ? Colors.grey[100] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: modoProduccion
                            ? Colors.grey[300]!
                            : Colors.grey[400]!,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 13,
                    color: modoProduccion ? Colors.black54 : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- FILA 3: BOBINAS (ANCHO, METROS, CANTIDAD) ---
            LayoutBuilder(
              builder: (context, constraints) {
                final campoAncho = _buildBobinaInput(
                  label: "ANCHO DE BOBINAS",
                  hint: "Ej: 50 cm",
                  fieldKey: "laminado_ancho_bobinas_${controller.sessionKey}",
                  initialValue: controller.laminadoAnchoBobinas,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateLaminadoGeneral('anchoBobinas', v),
                );
                final campoMetros = _buildBobinaInput(
                  label: "CANTIDAD EN METROS",
                  hint: "Ej: 200 m",
                  fieldKey: "laminado_cant_metros_${controller.sessionKey}",
                  initialValue: controller.laminadoCantidadMetros,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateLaminadoGeneral('cantidadMetros', v),
                );
                final campoBobinas = _buildBobinaInput(
                  label: "CANTIDAD DE BOBINAS",
                  hint: "Ej: 2",
                  fieldKey: "laminado_cant_bobinas_${controller.sessionKey}",
                  initialValue: controller.laminadoCantidadBobinas,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateLaminadoGeneral('cantidadBobinas', v),
                );

                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      campoAncho,
                      const SizedBox(height: 12),
                      campoMetros,
                      const SizedBox(height: 12),
                      campoBobinas,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: campoAncho),
                    const SizedBox(width: 12),
                    Expanded(child: campoMetros),
                    const SizedBox(width: 12),
                    Expanded(child: campoBobinas),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // --- SECCIÓN DE CONFIGURACIÓN (Aplicación y Máquina) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: modoProduccion ? Colors.grey[50] : Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      modoProduccion ? Colors.grey[300]! : Colors.indigo[100]!,
                ),
              ),
              child: Column(
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "APLICACIÓN:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: modoProduccion
                                ? Colors.grey[600]
                                : Colors.indigo,
                          ),
                        ),
                      ),
                      _buildCheck(
                        context,
                        "Frente",
                        controller.laminadoAplicacion['frente']!,
                        modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoAplicacion('frente', v!),
                      ),
                      _buildCheck(
                        context,
                        "Vuelta",
                        controller.laminadoAplicacion['vuelta']!,
                        modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateLaminadoAplicacion('vuelta', v!),
                      ),
                    ],
                  ),
                  Divider(
                    color: modoProduccion ? Colors.grey[300] : Colors.indigo,
                    thickness: 0.2,
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "MÁQUINA:",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: modoProduccion
                                ? Colors.grey[600]
                                : Colors.indigo,
                          ),
                        ),
                      ),
                      _buildCheck(
                        context,
                        "Máquina Chica",
                        controller.laminadoMaquinaChica,
                        modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateMaquinaLaminado('chica', v!),
                      ),
                      _buildCheck(
                        context,
                        "Máquina Grande",
                        controller.laminadoMaquinaGrande,
                        modoProduccion
                            ? null
                            : (v) => ref
                                .read(ordenTrabajoProvider)
                                .updateMaquinaLaminado('grande', v!),
                      ),
                    ],
                  ),
                ],
              ),
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
              key: ValueKey("laminado_notas_${controller.sessionKey}"),
              initialValue: controller.laminadoNotas,
              maxLines: 3,
              readOnly: modoProduccion,
              onChanged: modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateLaminadoGeneral('notas', v),
              decoration: InputDecoration(
                hintText: modoProduccion
                    ? "Sin notas o especificaciones adicionales de laminado"
                    : "Ej: Laminado mate, brillante, soft touch, cuidar que no se raye, dejar pinza libre...",
                isDense: true,
                filled: true,
                fillColor: modoProduccion ? Colors.grey[100] : Colors.yellow[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: modoProduccion
                        ? Colors.grey[300]!
                        : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: modoProduccion
                        ? Colors.grey[300]!
                        : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: modoProduccion ? Colors.black54 : Colors.black,
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "NOTAS DEL TALLER",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              key: ValueKey("laminado_notas_taller_${controller.sessionKey}"),
              initialValue: controller.laminadoNotasTaller,
              maxLines: 3,
              readOnly: !modoProduccion,
              onChanged: !modoProduccion
                  ? null
                  : (v) => ref
                      .read(ordenTrabajoProvider)
                      .updateLaminadoGeneral('notasTaller', v),
              decoration: InputDecoration(
                hintText: !modoProduccion
                    ? "Sin notas del taller"
                    : "Escribe aquí cualquier observación o nota para esta orden...",
                isDense: true,
                filled: true,
                fillColor: !modoProduccion ? Colors.grey[100] : Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: !modoProduccion
                        ? Colors.grey[300]!
                        : Colors.blue[200]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: !modoProduccion
                        ? Colors.grey[300]!
                        : Colors.blue[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: !modoProduccion ? Colors.black54 : Colors.black,
              ),
            ),

            if (modoProduccion) ...[
              const Divider(height: 32, thickness: 1),
              SectionButtons(
                area: 'laminados',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBobinaInput({
    required String label,
    required String hint,
    required String fieldKey,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
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
        TextFormField(
          key: ValueKey(fieldKey),
          initialValue: initialValue,
          readOnly: modoProduccion,
          onChanged: modoProduccion ? null : onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: modoProduccion ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: modoProduccion ? Colors.grey[300]! : Colors.grey[400]!,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: 13,
            color: modoProduccion ? Colors.black54 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCheck(
    BuildContext context,
    String label,
    bool value,
    Function(bool?)? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: onChanged == null ? Colors.black54 : Colors.black,
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}