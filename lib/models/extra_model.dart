class Extra {
  final String id;
  final String nombre;
  final double? costoCm2;
  final double? costoMinimoTotal;
  final double? costoFijo;
  final DateTime? fechaModificacion;

  Extra({
    required this.id,
    required this.nombre,
    this.costoCm2,
    this.costoMinimoTotal,
    this.costoFijo,
    this.fechaModificacion,
  });

  factory Extra.fromMap(Map<String, dynamic> map) {
    return Extra(
      id: map['id'].toString(),
      nombre: map['nombre'].toString(),
      costoCm2: map['costo_cm2'] != null
          ? double.tryParse(map['costo_cm2'].toString())
          : null,
      costoMinimoTotal: map['costo_minimo_total'] != null
          ? double.tryParse(map['costo_minimo_total'].toString())
          : null,
      costoFijo: map['costo_fijo'] != null
          ? double.tryParse(map['costo_fijo'].toString())
          : null,
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.tryParse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'costo_cm2': costoCm2,
      'costo_minimo_total': costoMinimoTotal,
      'costo_fijo': costoFijo,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }
}
