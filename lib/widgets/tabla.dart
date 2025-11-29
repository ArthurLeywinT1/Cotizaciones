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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              headerColor ?? const Color(0xFF1976D2),
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
              return Colors.white;
            }),
            columnSpacing: 20,
            horizontalMargin: 10,
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
    );
  }
}
