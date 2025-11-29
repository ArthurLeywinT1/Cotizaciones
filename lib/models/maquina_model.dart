class Maquina {
  final String id;
  final String nombre;
  final int? cantidadTintas;
  final int? cantidadTamanos;
  final int? anchoMaximo;
  final int? largoMaximo;
  final double costoPorPlaca;
  final DateTime? fechaModificacion;

  Maquina({
    required this.id,
    required this.nombre,
    this.cantidadTintas,
    this.cantidadTamanos,
    this.anchoMaximo,
    this.largoMaximo,
    required this.costoPorPlaca,
    this.fechaModificacion,
  });

  factory Maquina.fromMap(Map<String, dynamic> map) {
    return Maquina(
      id: map['id'].toString(),
      nombre: map['nombre_maquina'].toString(),
      cantidadTintas: map['cantidad_tintas'] != null
          ? int.tryParse(map['cantidad_tintas'].toString())
          : null,
      cantidadTamanos: map['cantidad_tamanos'] != null
          ? int.tryParse(map['cantidad_tamanos'].toString())
          : null,
      anchoMaximo: map['ancho_maximo'] != null
          ? int.tryParse(map['ancho_maximo'].toString())
          : null,
      largoMaximo: map['largo_maximo'] != null
          ? int.tryParse(map['largo_maximo'].toString())
          : null,
      costoPorPlaca: double.tryParse(map['costo_por_placa'].toString()) ?? 0.0,
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.tryParse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre_maquina': nombre,
      'cantidad_tintas': cantidadTintas,
      'cantidad_tamanos': cantidadTamanos,
      'ancho_maximo': anchoMaximo,
      'largo_maximo': largoMaximo,
      'costo_por_placa': costoPorPlaca,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }

  String get tamanoMaximo => "${anchoMaximo ?? '?'}x${largoMaximo ?? '?'} cm";
}
