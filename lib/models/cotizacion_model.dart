import 'dart:convert';

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
  final int tintaFrontal;
  final int tintaReverso;
  final int cantidadImpresiones;
  final int totalPliegos;
  final double precioSinIva;
  final double precioUnitario;
  final double precioConIva;
  final String status;
  final DateTime? fechaCreacion;
  final String? tipoCotizacion;

  final Map<String, dynamic>? configAcabadosEspeciales;
  final Map<String, dynamic>? configAcabados;
  final Map<String, dynamic>? configClientes;
  final Map<String, dynamic>? configCorte;
  final Map<String, dynamic>? configCostoPapel;
  final Map<String, dynamic>? configCostoTotal;
  final Map<String, dynamic>? configDatosPapel;
  final Map<String, dynamic>? configGrabado;
  final Map<String, dynamic>? configLaminado;
  final Map<String, dynamic>? configMaquina;
  final Map<String, dynamic>? configPliegos;
  final Map<String, dynamic>? configSerigrafia;
  final Map<String, dynamic>? configSuaje;
  final Map<String, dynamic>? configEmbalaje;

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
    this.tintaFrontal = 0,
    this.tintaReverso = 0,
    required this.cantidadImpresiones,
    this.totalPliegos = 0,
    this.precioSinIva = 0.0,
    this.precioUnitario = 0.0,
    this.precioConIva = 0.0,
    this.status = 'Esperando Aprobacion',
    this.fechaCreacion,
    this.tipoCotizacion,

    this.configAcabadosEspeciales,
    this.configAcabados,
    this.configClientes,
    this.configCorte,
    this.configCostoPapel,
    this.configCostoTotal,
    this.configDatosPapel,
    this.configGrabado,
    this.configLaminado,
    this.configMaquina,
    this.configPliegos,
    this.configSerigrafia,
    this.configSuaje,
    this.configEmbalaje,
  });

  static Map<String, dynamic>? _parseJson(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

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
      tintaFrontal: int.tryParse(map['tinta_frontal'].toString()) ?? 0,
      tintaReverso: int.tryParse(map['tinta_reverso'].toString()) ?? 0,
      cantidadImpresiones:
          int.tryParse(map['cantidad_impresiones'].toString()) ?? 0,
      totalPliegos: int.tryParse(map['total_pliegos'].toString()) ?? 0,
      precioSinIva: double.tryParse(map['precio_sin_iva'].toString()) ?? 0.0,
      precioUnitario: double.tryParse(map['precio_unitario'].toString()) ?? 0.0,
      precioConIva: double.tryParse(map['precio_con_iva'].toString()) ?? 0.0,
      status: map['status']?.toString() ?? 'Esperando Aprobacion',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'].toString())
          : null,
      tipoCotizacion: map['tipo_cotizacion']?.toString(),

      configAcabadosEspeciales: _parseJson(map['config_acabados_especiales']),
      configAcabados: _parseJson(map['config_acabados']),
      configClientes: _parseJson(map['config_clientes']),
      configCorte: _parseJson(map['config_corte']),
      configCostoPapel: _parseJson(map['config_costo_papel']),
      configCostoTotal: _parseJson(map['config_costo_total']),
      configDatosPapel: _parseJson(map['config_datos_papel']),
      configGrabado: _parseJson(map['config_grabado']),
      configLaminado: _parseJson(map['config_laminado']),
      configMaquina: _parseJson(map['config_maquina']),
      configPliegos: _parseJson(map['config_pliegos']),
      configSerigrafia: _parseJson(map['config_serigrafia']),
      configSuaje: _parseJson(map['config_suaje']),
      configEmbalaje: _parseJson(map['config_embalaje']),
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
      'tinta_frontal': tintaFrontal,
      'tinta_reverso': tintaReverso,
      'cantidad_impresiones': cantidadImpresiones,
      'total_pliegos': totalPliegos,
      'precio_sin_iva': precioSinIva,
      'precio_unitario': precioUnitario,
      'precio_con_iva': precioConIva,
      'status': status,
      'tipo_cotizacion': tipoCotizacion,

      'config_acabados_especiales': configAcabadosEspeciales != null
          ? jsonEncode(configAcabadosEspeciales)
          : null,
      'config_acabados': configAcabados != null
          ? jsonEncode(configAcabados)
          : null,
      'config_clientes': configClientes != null
          ? jsonEncode(configClientes)
          : null,
      'config_corte': configCorte != null ? jsonEncode(configCorte) : null,
      'config_costo_papel': configCostoPapel != null
          ? jsonEncode(configCostoPapel)
          : null,
      'config_costo_total': configCostoTotal != null
          ? jsonEncode(configCostoTotal)
          : null,
      'config_datos_papel': configDatosPapel != null
          ? jsonEncode(configDatosPapel)
          : null,
      'config_grabado': configGrabado != null
          ? jsonEncode(configGrabado)
          : null,
      'config_laminado': configLaminado != null
          ? jsonEncode(configLaminado)
          : null,
      'config_maquina': configMaquina != null
          ? jsonEncode(configMaquina)
          : null,
      'config_pliegos': configPliegos != null
          ? jsonEncode(configPliegos)
          : null,
      'config_serigrafia': configSerigrafia != null
          ? jsonEncode(configSerigrafia)
          : null,
      'config_suaje': configSuaje != null ? jsonEncode(configSuaje) : null,
      'config_embalaje': configEmbalaje != null
          ? jsonEncode(configEmbalaje)
          : null,
    };
  }

  String get medidas => "$anchoMedida x $altoMedida";
  String get tintas => "$tintaFrontal x $tintaReverso";
  String get tipoCotizacionLabel {
    switch (tipoCotizacion) {
      case 'P':
        return 'Plana';
      case 'R':
        return 'Revista';
      default:
        return '-';
    }
  }
}
