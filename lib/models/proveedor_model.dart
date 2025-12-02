class Proveedor {
  final String id;
  final String razonSocial;
  final String? rfc;
  final String? direccion;
  final String? telefono;
  final String? correoElectronico;
  final DateTime? fechaModificacion;

  Proveedor({
    required this.id,
    required this.razonSocial,
    this.rfc,
    this.direccion,
    this.telefono,
    this.correoElectronico,
    this.fechaModificacion,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'].toString(),
      razonSocial: map['razon_social'].toString(),
      rfc: map['rfc']?.toString(),
      direccion: map['direccion']?.toString(),
      telefono: map['telefono']?.toString(),
      correoElectronico: map['correo_electronico']?.toString(),
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.tryParse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'razon_social': razonSocial,
      'rfc': rfc,
      'direccion': direccion,
      'telefono': telefono,
      'correo_electronico': correoElectronico,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }
}
