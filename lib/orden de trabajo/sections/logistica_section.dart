// lib/screens/sections/logistica_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class LogisticaSection extends ConsumerStatefulWidget {
  const LogisticaSection({super.key});

  @override
  ConsumerState<LogisticaSection> createState() => _LogisticaSectionState();
}

class _LogisticaSectionState extends ConsumerState<LogisticaSection> {
  // Controlador para mostrar la fecha en el TextField
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

  // Función para mostrar el calendario
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Opcional: evita seleccionar fechas pasadas
      lastDate: DateTime(2030),
      helpText: 'SELECCIONA LA FECHA DE ENTREGA',
    );

    if (picked != null) {
      // Formateamos la fecha a DD/MM/AAAA manualmente
      String dia = picked.day.toString().padLeft(2, '0');
      String mes = picked.month.toString().padLeft(2, '0');
      String anio = picked.year.toString();
      String fechaFormateada = "$dia/$mes/$anio";

      // Actualizamos el campo de texto en la pantalla
      setState(() {
        _fechaController.text = fechaFormateada;
      });

      // Guardamos la fecha en tu provider usando tu método original
      ref.read(ordenTrabajoProvider).updateLogistica('fecha', fechaFormateada);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controlador para mostrar la fecha en el TextField
    final controller = ref.watch(ordenTrabajoProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.deepOrange[200]!, width: 1),
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
                  color: Colors.deepOrange[700],
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  "11. LOGÍSTICA Y DESPACHO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),

            // --- BLOQUE 1: FECHA Y TRANSPORTE ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepOrange[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "FECHA MÁX. DE ENTREGA",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // TEXTFIELD MODIFICADO PARA EL CALENDARIO
                        TextField(
                          controller: _fechaController,
                          readOnly: true, // Bloquea el teclado nativo
                          onTap: () =>
                              _selectDate(context), // Abre el calendario
                          decoration: const InputDecoration(
                            hintText: "DD/MM/AAAA",
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.deepOrange,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        onChanged: (v) => ref
                            .read(ordenTrabajoProvider)
                            .updateLogistica('transporte', v),
                        decoration: const InputDecoration(
                          hintText: "Ej: Camioneta 3.5 Ton, Paquetería...",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- BLOQUE 2: DIRECCIÓN Y TOTAL A ENTREGAR ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DIRECCIÓN
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
                        onChanged: (v) => ref
                            .read(ordenTrabajoProvider)
                            .updateLogistica('direccion', v),
                        decoration: const InputDecoration(
                          hintText:
                              "Dirección completa, referencias, horarios...",
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // TOTAL A ENTREGAR
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
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "0",
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
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

            const SizedBox(height: 24),

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
              onChanged: (v) =>
                  ref.read(ordenTrabajoProvider).updateLogistica('notas', v),
              decoration: InputDecoration(
                hintText:
                    "Ej: instrucciones para la entrega, detalles de la dirección, cuidado especial para el transporte...",
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
