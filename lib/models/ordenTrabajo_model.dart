class OrdenTrabajo {
  final String? id;
  final String? cotizacionId;
  final int? noOrden;
  final String estatus;
  final Map<String, dynamic> datosCompletos;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEntrega;

  OrdenTrabajo({
    this.id,
    this.cotizacionId,
    this.noOrden,
    this.estatus = 'En Proceso',
    required this.datosCompletos,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEntrega,
  });

  factory OrdenTrabajo.fromJson(Map<String, dynamic> json) {
    return OrdenTrabajo(
      id: json['id']?.toString(),
      cotizacionId: json['cotizacion_id']?.toString(),
      noOrden: json['no_orden'] != null
          ? int.tryParse(json['no_orden'].toString())
          : null,
      estatus: json['estatus']?.toString() ?? 'En Proceso',
      datosCompletos: json['datos_completos'] is Map
          ? Map<String, dynamic>.from(json['datos_completos'])
          : {},
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.tryParse(json['fecha_actualizacion'].toString())
          : null,
      fechaEntrega: json['fecha_entrega'] != null
          ? DateTime.tryParse(json['fecha_entrega'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cotizacion_id': cotizacionId,
      if (noOrden != null) 'no_orden': noOrden,
      'estatus': estatus,
      'datos_completos': datosCompletos,
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
      if (fechaActualizacion != null)
        'fecha_actualizacion': fechaActualizacion!.toIso8601String(),
      if (fechaEntrega != null)
        'fecha_entrega': fechaEntrega!.toIso8601String(),
    };
  }

  OrdenTrabajo copyWith({
    String? id,
    String? cotizacionId,
    int? noOrden,
    String? estatus,
    Map<String, dynamic>? datosCompletos,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaEntrega,
  }) {
    return OrdenTrabajo(
      id: id ?? this.id,
      cotizacionId: cotizacionId ?? this.cotizacionId,
      noOrden: noOrden ?? this.noOrden,
      estatus: estatus ?? this.estatus,
      datosCompletos: datosCompletos ?? this.datosCompletos,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
    );
  }
}
