// lib/screens/sections/logistica_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import 'section_buttons.dart';

class LogisticaSection extends ConsumerStatefulWidget {
  final bool modoProduccion;

  const LogisticaSection({super.key, this.modoProduccion = false});

  @override
  ConsumerState<LogisticaSection> createState() => _LogisticaSectionState();
}

class _LogisticaSectionState extends ConsumerState<LogisticaSection> {
  late TextEditingController _fechaController;
  late TextEditingController _transporteController;
  late TextEditingController _direccionController;
  late TextEditingController _totalController;
  late TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(ordenTrabajoProvider);

    _fechaController = TextEditingController(
      text: controller.logisticaFechaEntrega,
    );
    _transporteController = TextEditingController(
      text: controller.logisticaTransporte,
    );
    _direccionController = TextEditingController(
      text: controller.logisticaDireccion,
    );
    _totalController = TextEditingController(
      text: controller.logisticaTotalEntregar > 0
          ? controller.logisticaTotalEntregar.toString()
          : '',
    );
    _notasController = TextEditingController(text: controller.logisticaNotas);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _transporteController.dispose();
    _direccionController.dispose();
    _totalController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Si está en modo producción, se cancela la ejecución del calendario
    if (widget.modoProduccion) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: 'SELECCIONA LA FECHA DE ENTREGA',
    );

    if (picked != null) {
      String dia = picked.day.toString().padLeft(2, '0');
      String mes = picked.month.toString().padLeft(2, '0');
      String anio = picked.year.toString();
      String fechaFormateada = "$dia/$mes/$anio";

      setState(() {
        _fechaController.text = fechaFormateada;
      });

      ref.read(ordenTrabajoProvider).updateLogistica('fecha', fechaFormateada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(ordenTrabajoProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.modoProduccion
              ? Colors.grey[300]!
              : Colors.deepOrange[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: widget.modoProduccion
                      ? Colors.grey[700]
                      : Colors.deepOrange[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "11. LOGÍSTICA Y DESPACHO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const Divider(),

            // --- BLOQUE 1: FECHA Y TRANSPORTE ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.modoProduccion
                          ? Colors.grey[50]
                          : Colors.deepOrange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.modoProduccion
                            ? Colors.grey[300]!
                            : Colors.deepOrange[100]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FECHA MÁX. DE ENTREGA",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.modoProduccion
                                ? Colors.grey[600]
                                : Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _fechaController,
                          readOnly: true, // Siempre bloquea teclado nativo
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            hintText: "DD/MM/AAAA",
                            isDense: true,
                            filled: true,
                            fillColor: widget.modoProduccion
                                ? Colors.grey[100]
                                : Colors.white,
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.modoProduccion
                                    ? Colors.grey[300]!
                                    : Colors.grey[400]!,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: widget.modoProduccion
                                  ? Colors.grey[500]
                                  : Colors.deepOrange,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.modoProduccion
                                ? Colors.black54
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // --- BLOQUE 2: TIPO DE TRANSPORTE ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TIPO DE TRANSPORTE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _transporteController,
                        readOnly: widget.modoProduccion,
                        onChanged: widget.modoProduccion
                            ? null
                            : (v) => ref
                                  .read(ordenTrabajoProvider)
                                  .updateLogistica('transporte', v),
                        decoration: InputDecoration(
                          hintText: "Ej: Camioneta 3.5 Ton, Paquetería...",
                          isDense: true,
                          filled: widget.modoProduccion,
                          fillColor: widget.modoProduccion
                              ? Colors.grey[100]
                              : null,
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.modoProduccion
                                  ? Colors.grey[300]!
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.modoProduccion
                              ? Colors.black54
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- FILA: DIRECCIÓN Y TOTAL ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DIRECCIÓN DE ENTREGA",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _direccionController,
                        maxLines: 2,
                        readOnly: widget.modoProduccion,
                        onChanged: widget.modoProduccion
                            ? null
                            : (v) => ref
                                  .read(ordenTrabajoProvider)
                                  .updateLogistica('direccion', v),
                        decoration: InputDecoration(
                          hintText:
                              "Dirección completa, referencias, horarios...",
                          isDense: true,
                          filled: widget.modoProduccion,
                          fillColor: widget.modoProduccion
                              ? Colors.grey[100]
                              : null,
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.modoProduccion
                                  ? Colors.grey[300]!
                                  : Colors.grey[400]!,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.modoProduccion
                              ? Colors.black54
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // TOTAL A ENTREGAR (Siempre ReadOnly en ambos flujos)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOTAL A ENTREGAR",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _totalController,
                        decoration: InputDecoration(
                          hintText: "0",
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
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
            TextField(
              controller: _notasController,
              maxLines: 3,
              readOnly: widget.modoProduccion,
              onChanged: widget.modoProduccion
                  ? null
                  : (v) => ref
                        .read(ordenTrabajoProvider)
                        .updateLogistica(
                          'notes',
                          v,
                        ), // Mantiene tu mapeo original
              decoration: InputDecoration(
                hintText: widget.modoProduccion
                    ? "Sin notas o especificaciones logísticas adicionales"
                    : "Ej: instrucciones para la entrega, detalles de la dirección, cuidado especial para el transporte...",
                isDense: true,
                filled: true,
                fillColor: widget.modoProduccion
                    ? Colors.grey[100]
                    : Colors.yellow[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.modoProduccion
                        ? Colors.grey[300]!
                        : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.modoProduccion
                        ? Colors.grey[300]!
                        : Colors.yellow[600]!,
                    width: 0.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: widget.modoProduccion ? Colors.black54 : Colors.black,
              ),
            ),

            // --- BOTONES DE PRODUCCIÓN ---
            if (widget.modoProduccion) ...[
              const Divider(height: 32, thickness: 1),
              SectionButtons(
                area: 'logistica',
                ordenTrabajoId: controller.ordenTrabajoDbId ?? '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
