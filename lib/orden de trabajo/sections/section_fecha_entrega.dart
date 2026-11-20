import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';

class SectionFechaEntrega extends ConsumerWidget {
  final String area;
  final bool modoProduccion;
  final Color accentColor;

  const SectionFechaEntrega({
    super.key,
    required this.area,
    this.modoProduccion = false,
    this.accentColor = Colors.blueGrey,
  });

  DateTime _obtenerFechaInicial(String fechaTexto) {
    if (fechaTexto.isNotEmpty) {
      final partes = fechaTexto.split('/');
      if (partes.length == 3) {
        final dia = int.tryParse(partes[0]);
        final mes = int.tryParse(partes[1]);
        final anio = int.tryParse(partes[2]);
        if (dia != null && mes != null && anio != null) {
          final parsed = DateTime(anio, mes, dia);
          if (!parsed.isBefore(DateTime(2020)) &&
              !parsed.isAfter(DateTime(2035))) {
            return parsed;
          }
        }
      }
    }
    return DateTime.now();
  }

  Future<void> _seleccionarFecha(
    BuildContext context,
    WidgetRef ref,
    String fechaActual,
  ) async {
    if (modoProduccion) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _obtenerFechaInicial(fechaActual),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'FECHA DE ENTREGA - ${area.toUpperCase()}',
    );

    if (picked != null) {
      final dia = picked.day.toString().padLeft(2, '0');
      final mes = picked.month.toString().padLeft(2, '0');
      final anio = picked.year.toString();
      ref
          .read(ordenTrabajoProvider)
          .updateFechaEntregaSeccion(area, '$dia/$mes/$anio');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordenTrabajoProvider);
    final fecha = controller.getFechaEntregaSeccion(area);

    final Color colorBorde =
        modoProduccion ? Colors.grey[300]! : accentColor.withOpacity(0.35);
    final Color colorFondo =
        modoProduccion ? Colors.grey[100]! : accentColor.withOpacity(0.06);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorBorde),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            size: 18,
            color: modoProduccion ? Colors.grey[600] : accentColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: modoProduccion
                  ? null
                  : () => _seleccionarFecha(context, ref, fecha),
              borderRadius: BorderRadius.circular(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FECHA DE ENTREGA DEL ÁREA",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: modoProduccion ? Colors.grey[600] : accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fecha.isNotEmpty
                        ? fecha
                        : (modoProduccion
                            ? "Sin fecha asignada"
                            : "Seleccionar fecha (DD/MM/AAAA)"),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          fecha.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                      color: fecha.isNotEmpty
                          ? (modoProduccion ? Colors.black87 : Colors.black)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!modoProduccion && fecha.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: "Limpiar fecha",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => ref
                  .read(ordenTrabajoProvider)
                  .updateFechaEntregaSeccion(area, ''),
            )
          else if (!modoProduccion)
            IconButton(
              icon: Icon(Icons.calendar_today, size: 18, color: accentColor),
              tooltip: "Elegir fecha",
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _seleccionarFecha(context, ref, fecha),
            ),
        ],
      ),
    );
  }
}