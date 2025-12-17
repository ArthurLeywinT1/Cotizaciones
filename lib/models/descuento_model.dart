class DescuentoPapel {
  final String id;
  final int cantidadDesde;
  final int cantidadHasta;
  final double descuento;
  final DateTime? fechaModificacion;

  DescuentoPapel({
    required this.id,
    required this.cantidadDesde,
    required this.cantidadHasta,
    required this.descuento,
    this.fechaModificacion,
  });

  factory DescuentoPapel.fromMap(Map<String, dynamic> map) {
    return DescuentoPapel(
      id: map['id'].toString(),
      cantidadDesde: int.tryParse(map['cantidad_desde'].toString()) ?? 0,
      cantidadHasta: int.tryParse(map['cantidad_hasta'].toString()) ?? 0,
      descuento: double.tryParse(map['descuento'].toString()) ?? 0.0,
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.tryParse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cantidad_desde': cantidadDesde,
      'cantidad_hasta': cantidadHasta,
      'descuento': descuento,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }
}
