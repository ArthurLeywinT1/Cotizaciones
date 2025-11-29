class Cliente {
  final String id;
  final String razonSocial;
  final String? rfc;
  final String? calle;
  final String? noExterior;
  final String? noInterior;
  final String? colonia;
  final String? cp;
  final String? municipio;
  final String? ciudad;
  final String pais;
  final String? correoElectronico;
  final double margenUtilidad;
  final DateTime? fechaModificacion;

  Cliente({
    required this.id,
    required this.razonSocial,
    this.rfc,
    this.calle,
    this.noExterior,
    this.noInterior,
    this.colonia,
    this.cp,
    this.municipio,
    this.ciudad,
    this.pais = 'México',
    this.correoElectronico,
    this.margenUtilidad = 0.0,
    this.fechaModificacion,
  });

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'].toString(),
      razonSocial: map['razon_social'].toString(),
      rfc: map['rfc']?.toString(),
      calle: map['calle']?.toString(),
      noExterior: map['no_exterior']?.toString(),
      noInterior: map['no_interior']?.toString(),
      colonia: map['colonia']?.toString(),
      cp: map['cp']?.toString(),
      municipio: map['municipio']?.toString(),
      ciudad: map['ciudad']?.toString(),
      pais: map['pais']?.toString() ?? 'México',
      correoElectronico: map['correo_electronico']?.toString(),
      margenUtilidad: double.tryParse(map['margen_utilidad'].toString()) ?? 0.0,
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
      'calle': calle,
      'no_exterior': noExterior,
      'no_interior': noInterior,
      'colonia': colonia,
      'cp': cp,
      'municipio': municipio,
      'ciudad': ciudad,
      'pais': pais,
      'correo_electronico': correoElectronico,
      'margen_utilidad': margenUtilidad,
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }
}
