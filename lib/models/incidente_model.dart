class Incidente {
  final String? id;
  final String ordenTrabajoId;
  final String? usuarioId;
  final String area;
  final String mensajeOperario;
  final String? mensajeAdmin;
  final String estatus;
  final DateTime? fechaCreacion;
  final DateTime? fechaRespuesta;

  Incidente({
    this.id,
    required this.ordenTrabajoId,
    this.usuarioId,
    required this.area,
    required this.mensajeOperario,
    this.mensajeAdmin,
    this.estatus = 'Pendiente',
    this.fechaCreacion,
    this.fechaRespuesta,
  });

  factory Incidente.fromJson(Map<String, dynamic> json) {
    return Incidente(
      id: json['id']?.toString(),
      ordenTrabajoId: json['orden_trabajo_id'].toString(),
      usuarioId: json['usuario_id']?.toString(),
      area: json['area'] ?? '',
      mensajeOperario: json['mensaje_operario'] ?? '',
      mensajeAdmin: json['mensaje_admin'],
      estatus: json['estatus'] ?? 'Pendiente',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.tryParse(json['fecha_respuesta'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orden_trabajo_id': ordenTrabajoId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      'area': area,
      'mensaje_operario': mensajeOperario,
      if (mensajeAdmin != null) 'mensaje_admin': mensajeAdmin,
      'estatus': estatus,
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
      if (fechaRespuesta != null)
        'fecha_respuesta': fechaRespuesta!.toIso8601String(),
    };
  }

  Incidente copyWith({
    String? id,
    String? ordenTrabajoId,
    String? usuarioId,
    String? area,
    String? mensajeOperario,
    String? mensajeAdmin,
    String? estatus,
    DateTime? fechaCreacion,
    DateTime? fechaRespuesta,
  }) {
    return Incidente(
      id: id ?? this.id,
      ordenTrabajoId: ordenTrabajoId ?? this.ordenTrabajoId,
      usuarioId: usuarioId ?? this.usuarioId,
      area: area ?? this.area,
      mensajeOperario: mensajeOperario ?? this.mensajeOperario,
      mensajeAdmin: mensajeAdmin ?? this.mensajeAdmin,
      estatus: estatus ?? this.estatus,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }
}
