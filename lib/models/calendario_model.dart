class Calendario {
  final String? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? usuarioId;
  final String area;

  Calendario({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    this.usuarioId,
    required this.area,
  });

  factory Calendario.fromJson(Map<String, dynamic> json) {
    return Calendario(
      id: json['id']?.toString(),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fechaInicio: DateTime.parse(json['fecha_inicio'].toString()),
      fechaFin: DateTime.parse(json['fecha_fin'].toString()),
      usuarioId: json['usuario_id']?.toString(),
      area: json['area']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      if (usuarioId != null) 'usuario_id': usuarioId,
      'area': area,
    };
  }
}
