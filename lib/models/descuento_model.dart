class DescuentoPapel {
  final String id;
  final String papelId;
  final int cantidadDesde;
  final int cantidadHasta;
  final double descuento;
  final DateTime? fechaModificacion;

  DescuentoPapel({
    required this.id,
    required this.papelId,
    required this.cantidadDesde,
    required this.cantidadHasta,
    required this.descuento,
    this.fechaModificacion,
  });

  factory DescuentoPapel.fromMap(Map<String, dynamic> map) {
    return DescuentoPapel(
      id: map['id'].toString(),
      papelId: map['papel_id'].toString(),
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
      'papel_id': papelId,
      'cantidad_desde': cantidadDesde,
      'cantidad_hasta': cantidadHasta,
      'descuento': descuento,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }
}
