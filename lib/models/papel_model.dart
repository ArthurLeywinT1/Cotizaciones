class Papel {
  final String id;
  final String nombre;
  final String? tipo;
  final double? ancho;
  final double? largo;
  final int? peso;
  final double costoMillar;
  final String? proveedorId;
  final DateTime? fechaModificacion;

  Papel({
    required this.id,
    required this.nombre,
    this.tipo,
    this.ancho,
    this.largo,
    this.peso,
    required this.costoMillar,
    this.proveedorId,
    this.fechaModificacion,
  });

  factory Papel.fromMap(Map<String, dynamic> map) {
    return Papel(
      id: map['id'].toString(),
      nombre: map['nombre_papel'].toString(),
      tipo: map['tipo_papel']?.toString(),
      ancho: map['medida_ancho'] != null
          ? double.tryParse(map['medida_ancho'].toString())
          : null,
      largo: map['medida_largo'] != null
          ? double.tryParse(map['medida_largo'].toString())
          : null,
      peso: map['peso_gramaje'] != null
          ? int.tryParse(map['peso_gramaje'].toString())
          : null,
      costoMillar: double.tryParse(map['costo_millar'].toString()) ?? 0.0,
      proveedorId: map['proveedor_id']?.toString(),
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.tryParse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre_papel': nombre,
      'tipo_papel': tipo,
      'medida_ancho': ancho,
      'medida_largo': largo,
      'peso_gramaje': peso,
      'costo_millar': costoMillar,
      'proveedor_id': proveedorId,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }

  String get medidas => "${ancho ?? '?'}x${largo ?? '?'} cm";
}
