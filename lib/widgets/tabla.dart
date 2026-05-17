import 'package:flutter/material.dart';

class Tabla extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Color? headerColor;

  const Tabla({
    super.key,
    required this.columns,
    required this.rows,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los controladores de scroll para evitar conflictos con los Scrollbars
    final ScrollController horizontalController = ScrollController();
    final ScrollController verticalController = ScrollController();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      // 1. Scroll Vertical Primero
      child: Scrollbar(
        controller: verticalController,
        thumbVisibility: true, // Cambiar a false si no quieres que sea siempre visible
        child: SingleChildScrollView(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: horizontalController,
            thumbVisibility: true, // Muestra la barra de scroll horizontal
            notificationPredicate: (notif) => notif.depth == 0,
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                // Actualizado a WidgetStateProperty (MaterialStateProperty está obsoleto en versiones recientes)
                headingRowColor: WidgetStateProperty.all(
                  headerColor ?? const Color(0xFF1976D2),
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  return Colors.white;
                }),
                columnSpacing: 24, // Un poco más de espacio ayuda a la lectura en scrolls largos
                horizontalMargin: 12,
                border: TableBorder.all(color: Colors.grey.shade300),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}