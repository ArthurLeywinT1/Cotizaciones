class Cotizacion {
  final String? id;
  final String? folio;
  final String clienteId;
  final String? clienteNombre;
  final String usuarioId;
  final String? usuarioNombre;
  final String descripcion;
  final double anchoMedida;
  final double altoMedida;
  final String tipoCotizacion;
  final int tintaFrontal;
  final int tintaReverso;
  final int cantidadImpresiones;
  final double precioSinIva;
  final double precioUnitario;
  final double precioConIva;
  final String status;
  final DateTime? fechaCreacion;

  Cotizacion({
    this.id,
    this.folio,
    required this.clienteId,
    this.clienteNombre,
    required this.usuarioId,
    this.usuarioNombre,
    required this.descripcion,
    required this.anchoMedida,
    required this.altoMedida,
    required this.tipoCotizacion,
    this.tintaFrontal = 0,
    this.tintaReverso = 0,
    required this.cantidadImpresiones,
    this.precioSinIva = 0.0,
    this.precioUnitario = 0.0,
    this.precioConIva = 0.0,
    this.status = 'Esperando Aprobacion',
    this.fechaCreacion,
  });

  factory Cotizacion.fromMap(Map<String, dynamic> map) {
    return Cotizacion(
      id: map['id']?.toString(),
      folio: map['folio']?.toString(),
      clienteId: map['cliente_id'].toString(),
      clienteNombre: map['cliente_nombre']?.toString(),
      usuarioId: map['usuario_id'].toString(),
      usuarioNombre: map['usuario_nombre']?.toString(),
      descripcion: map['descripcion']?.toString() ?? '',
      anchoMedida: double.tryParse(map['ancho_medida'].toString()) ?? 0.0,
      altoMedida: double.tryParse(map['alto_medida'].toString()) ?? 0.0,
      tipoCotizacion: map['tipo_cotizacion']?.toString() ?? 'Plana',
      tintaFrontal: int.tryParse(map['tinta_frontal'].toString()) ?? 0,
      tintaReverso: int.tryParse(map['tinta_reverso'].toString()) ?? 0,
      cantidadImpresiones:
          int.tryParse(map['cantidad_impresiones'].toString()) ?? 0,
      precioSinIva: double.tryParse(map['precio_sin_iva'].toString()) ?? 0.0,
      precioUnitario: double.tryParse(map['precio_unitario'].toString()) ?? 0.0,
      precioConIva: double.tryParse(map['precio_con_iva'].toString()) ?? 0.0,
      status: map['status']?.toString() ?? 'Esperando Aprobacion',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'usuario_id': usuarioId,
      'descripcion': descripcion,
      'ancho_medida': anchoMedida,
      'alto_medida': altoMedida,
      'tipo_cotizacion': tipoCotizacion,
      'tinta_frontal': tintaFrontal,
      'tinta_reverso': tintaReverso,
      'cantidad_impresiones': cantidadImpresiones,
      'precio_sin_iva': precioSinIva,
      'precio_unitario': precioUnitario,
      'precio_con_iva': precioConIva,
      'status': status,
    };
  }

  String get medidas => "$anchoMedida x $altoMedida cm";
  String get tintas => "$tintaFrontal x $tintaReverso";
}
