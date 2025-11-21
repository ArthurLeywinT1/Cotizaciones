class Proveedor {
  final String id;
  final String razonSocial;
  final String rfc;
  final String direccion;
  final String? telefono;
  final String? correoElectronico;
  final DateTime fechaModificacion;

  Proveedor({
    required this.id,
    required this.razonSocial,
    required this.rfc,
    required this.direccion,
    this.telefono,
    this.correoElectronico,
    required this.fechaModificacion,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'],
      razonSocial: map['razon_social'],
      rfc: map['rfc'],
      direccion: map['direccion'],
      telefono: map['telefono'],
      correoElectronico: map['correo_electronico'],
      fechaModificacion: DateTime.parse(map['fecha_modificacion']),
    );
  }
}
