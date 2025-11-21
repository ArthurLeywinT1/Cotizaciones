class Cliente {
  final String id;
  final String razonSocial;
  final String rfc;
  final String calle;
  final String noExterior;
  final String? noInterior;
  final String colonia;
  final String cp;
  final String municipio;
  final String ciudad;
  final String pais;
  final String? correoElectronico;
  final double margenUtilidad;
  final DateTime fechaModificacion;

  Cliente({
    required this.id,
    required this.razonSocial,
    required this.rfc,
    required this.calle,
    required this.noExterior,
    this.noInterior,
    required this.colonia,
    required this.cp,
    required this.municipio,
    required this.ciudad,
    required this.pais,
    this.correoElectronico,
    required this.margenUtilidad,
    required this.fechaModificacion,
  });

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      razonSocial: map['razon_social'],
      rfc: map['rfc'],
      calle: map['calle'],
      noExterior: map['no_exterior'],
      noInterior: map['no_interior'],
      colonia: map['colonia'],
      cp: map['cp'],
      municipio: map['municipio'],
      ciudad: map['ciudad'],
      pais: map['pais'],
      correoElectronico: map['correo_electronico'],
      margenUtilidad: map['margen_utilidad'],
      fechaModificacion: DateTime.parse(map['fecha_modificacion']),
    );
  }
}
