class Calendario {
  final String? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? usuarioId;
  final String area;
  final bool completado;

  Calendario({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    this.usuarioId,
    required this.area,
    this.completado = false,
  });

  Calendario copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? usuarioId,
    String? area,
    bool? completado,
  }) {
    return Calendario(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      usuarioId: usuarioId ?? this.usuarioId,
      area: area ?? this.area,
      completado: completado ?? this.completado,
    );
  }

  factory Calendario.fromJson(Map<String, dynamic> json) {
    final rawCompletado = json['completado'];
    final bool isCompletado = rawCompletado == true ||
        rawCompletado?.toString().toLowerCase() == 'true' ||
        rawCompletado?.toString() == '1';

    return Calendario(
      id: json['id']?.toString(),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fechaInicio: DateTime.parse(json['fecha_inicio'].toString()),
      fechaFin: DateTime.parse(json['fecha_fin'].toString()),
      usuarioId: json['usuario_id']?.toString(),
      area: json['area']?.toString() ?? '',
      completado: isCompletado,
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
      'completado': completado,
    };
  }
}