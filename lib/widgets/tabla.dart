import 'package:flutter/material.dart';

class Tabla extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Color? headerColor;

  // Debajo de este ancho se muestra la vista de tarjetas en vez de la tabla.
  static const double _anchoPuntoQuiebre = 700;

  const Tabla({
    super.key,
    required this.columns,
    required this.rows,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool esPantallaChica = constraints.maxWidth < _anchoPuntoQuiebre;
        return esPantallaChica ? _buildVistaTarjetas(context) : _buildVistaTabla();
      },
    );
  }

  // ================= VISTA TABLA (Escritorio / Tablet ancha) =================
  Widget _buildVistaTabla() {
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

  // ================= VISTA TARJETAS (Celular / pantalla angosta) =================
  //
  // Convierte cada DataRow en una tarjeta con pares "etiqueta: valor" (una
  // columna por línea, en vez de columnas lado a lado), para que no haya
  // que hacer scroll horizontal ni forzar texto diminuto en el celular.
  //
  // Detecta automáticamente si alguna columna es de "Acciones" (encabezado
  // vacío, "Acciones" o "Acción") y en ese caso no le pone etiqueta: en su
  // lugar muestra su contenido (normalmente botones de editar/eliminar)
  // alineado a la derecha, al final de la tarjeta.
  Widget _buildVistaTarjetas(BuildContext context) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            "No hay datos para mostrar",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final Color colorEncabezado = headerColor ?? const Color(0xFF1976D2);
    final ScrollController controller = ScrollController();

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: List.generate(rows.length, (rowIndex) {
            return _buildTarjeta(rows[rowIndex], colorEncabezado);
          }),
        ),
      ),
    );
  }

  bool _esColumnaAcciones(int index) {
    final label = columns[index].label;
    if (label is Text) {
      final texto = (label.data ?? '').trim().toLowerCase();
      return texto.isEmpty || texto == 'acciones' || texto == 'acción';
    }
    return false;
  }

  Widget _buildEtiqueta(Widget label, Color color) {
    // Si la etiqueta es un Text simple usamos su texto con nuestro propio
    // estilo (evita heredar, por ejemplo, el color blanco pensado para el
    // encabezado azul de la tabla, que sería invisible sobre una tarjeta
    // blanca).
    if (label is Text && label.data != null) {
      return Text(
        label.data!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      child: label,
    );
  }

  Widget _buildTarjeta(DataRow row, Color colorEncabezado) {
    final List<Widget> camposNormales = [];
    final List<Widget> camposAcciones = [];

    for (int i = 0; i < columns.length && i < row.cells.length; i++) {
      final DataCell celda = row.cells[i];

      if (_esColumnaAcciones(i)) {
        camposAcciones.add(celda.child);
        continue;
      }

      Widget valor = DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        child: celda.child,
      );

      // Algunas tablas ponen el "ver/editar" en una celda individual
      // (DataCell.onTap) en vez de en toda la fila; lo respetamos igual.
      if (celda.onTap != null) {
        valor = InkWell(onTap: celda.onTap, child: valor);
      }

      camposNormales.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: _buildEtiqueta(columns[i].label, colorEncabezado),
              ),
              const SizedBox(width: 8),
              Expanded(child: valor),
            ],
          ),
        ),
      );
    }

    final Color colorFondo = row.selected
        ? colorEncabezado.withOpacity(0.08)
        : (row.color?.resolve(<WidgetState>{}) ?? Colors.white);

    final Widget contenido = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...camposNormales,
          if (camposAcciones.isNotEmpty) ...[
            const Divider(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: camposAcciones,
              ),
            ),
          ],
        ],
      ),
    );

    // Si la fila tenía "onSelectChanged" (tocar la fila para ver/editar en
    // la tabla original), tocar toda la tarjeta hace lo mismo aquí. Además
    // se resalta con el color del encabezado cuando row.selected es true.
    final Widget interior = row.onSelectChanged != null
        ? InkWell(
            onTap: () => row.onSelectChanged!(!row.selected),
            child: contenido,
          )
        : contenido;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: row.selected ? colorEncabezado : Colors.grey.shade300,
          width: row.selected ? 1.5 : 1,
        ),
      ),
      color: colorFondo,
      child: interior,
    );
  }
}