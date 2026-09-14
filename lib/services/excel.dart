import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'incidente_service.dart';
import 'ordenTrabajo_service.dart';
import '../models/cotizacion_model.dart';

class ExcelExportService {
  final OrdenTrabajoService _otService = OrdenTrabajoService();
  final IncidenteService _incidenteService = IncidenteService();

  static String _formatearFecha(dynamic fecha) {
    if (fecha == null ||
        fecha.toString().isEmpty ||
        fecha.toString() == 'null') {
      return '-';
    }
    if (fecha is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha.toLocal());
    }
    try {
      final parsed = DateTime.parse(fecha.toString()).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return fecha.toString();
    }
  }

  static String _formatearSoloFecha(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty || fecha.toString() == 'null') {
      return '-';
    }
    final dt = _parseFecha(fecha);
    if (dt == null) return fecha.toString();
    return DateFormat('dd/MM/yyyy').format(dt.toLocal());
  }

  static String _formatearSoloHora(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty || fecha.toString() == 'null') {
      return '-';
    }
    final dt = _parseFecha(fecha);
    if (dt == null) return '-';
    return DateFormat('HH:mm').format(dt.toLocal());
  }

  static DateTime? _parseFecha(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty) return null;
    if (fecha is DateTime) return fecha;
    try {
      return DateTime.parse(fecha.toString());
    } catch (_) {
      return null;
    }
  }

  List<CellValue> _toRow(List<dynamic> values) {
    return values.map((v) => TextCellValue(v?.toString() ?? '-')).toList();
  }

  String _obtenerNota(Map<String, dynamic>? dbData, String seccionKey, String tipoNota) {
    if (dbData == null || dbData[seccionKey] == null) return '-';
    final sec = dbData[seccionKey];
    if (sec is Map) {
      final val = sec[tipoNota]?.toString().trim();
      if (val != null && val.isNotEmpty) return val;
    }
    return '-';
  }

  Future<bool> exportarOrdenesTrabajo(List<Map<String, dynamic>> ordenes) async {
    if (ordenes.isEmpty) return false;

    final excel = Excel.createExcel();

    const sheetOTName = 'Orden de Trabajo';
    excel.rename('Sheet1', sheetOTName);
    final sheetOT = excel[sheetOTName];
    final sheetCrono = excel['Cronograma'];
    final sheetInc = excel['Incidentes'];

    final headersOT = [
      'Folio',
      'No. Orden',
      'Fecha Creación',
      'Cliente',
      'Descripción',
      'Fecha Entrega',

      'Estatus Adq.',
      'Incidente Adq.',
      'Inicio Adq.',
      'Pausa Adq.',
      'Fin Adq.',
      'Notas Adq.',
      'Notas Taller Adq.',

      'Estatus Diseño',
      'Incidente Diseño',
      'Inicio Diseño',
      'Pausa Diseño',
      'Fin Diseño',
      'Notas Diseño',
      'Notas Taller Diseño',

      'Estatus Offset',
      'Incidente Offset',
      'Inicio Offset',
      'Pausa Offset',
      'Fin Offset',
      'Notas Offset',
      'Notas Taller Offset',

      'Estatus Corte',
      'Incidente Corte',
      'Inicio Corte',
      'Pausa Corte',
      'Fin Corte',
      'Notas Corte',
      'Notas Taller Corte',

      'Estatus Laminado',
      'Incidente Laminado',
      'Inicio Laminado',
      'Pausa Laminado',
      'Fin Laminado',
      'Notas Laminado',
      'Notas Taller Laminado',

      'Estatus Suaje',
      'Incidente Suaje',
      'Inicio Suaje',
      'Pausa Suaje',
      'Fin Suaje',
      'Notas Suaje',
      'Notas Taller Suaje',

      'Estatus Serigrafía',
      'Incidente Serigrafía',
      'Inicio Serigrafía',
      'Pausa Serigrafía',
      'Fin Serigrafía',
      'Notas Serigrafía',
      'Notas Taller Serigrafía',

      'Estatus Grabado',
      'Incidente Grabado',
      'Inicio Grabado',
      'Pausa Grabado',
      'Fin Grabado',
      'Notas Grabado',
      'Notas Taller Grabado',

      'Estatus Acabado',
      'Incidente Acabado',
      'Inicio Acabado',
      'Pausa Acabado',
      'Fin Acabado',
      'Notas Acabado',
      'Notas Taller Acabado',

      'Estatus Barniz',
      'Incidente Barniz',
      'Inicio Barniz',
      'Pausa Barniz',
      'Fin Barniz',
      'Notas Barniz',
      'Notas Taller Barniz',

      'Estatus Embalaje',
      'Incidente Embalaje',
      'Inicio Embalaje',
      'Pausa Embalaje',
      'Fin Embalaje',
      'Notas Embalaje',
      'Notas Taller Embalaje',

      'Estatus Logística',
      'Incidente Logística',
      'Inicio Logística',
      'Pausa Logística',
      'Fin Logística',
      'Notas Logística',
      'Notas Taller Logística',
    ];
    sheetOT.appendRow(_toRow(headersOT));

    sheetCrono.appendRow(_toRow([
      'No. Orden',
      'Estatus',
      'Fecha',
      'Hora',
      'Proceso',
    ]));

    sheetInc.appendRow(_toRow([
      'No. Orden',
      'Usuario',
      'Area',
      'Mensaje Operario',
      'Mensaje Admin',
      'Estatus',
      'Fecha Creacion',
      'Fecha Respuesta',
    ]));

    final List<Map<String, dynamic>> cronogramaTotalEventos = [];

    final mapProcesos = {
      'adquisiciones': 'Adquisiciones',
      'diseno': 'Diseño',
      'offset': 'Offset',
      'corte': 'Corte',
      'laminados': 'Laminado',
      'suaje': 'Suaje',
      'serigrafia': 'Serigrafía',
      'grabado': 'Grabado',
      'acabado': 'Acabado',
      'barniz': 'Barniz',
      'embalaje': 'Embalaje',
      'logistica': 'Logística',
    };

    for (final orden in ordenes) {
      final otId = orden['ot_id']?.toString() ?? '';
      final noOrden = (orden['no_orden']?.toString().isNotEmpty == true)
          ? orden['no_orden'].toString()
          : (orden['folio']?.toString() ?? 'S_F');

      final ordenCompleta = otId.isNotEmpty
          ? await _otService.obtenerOrdenPorOtId(otId)
          : null;
      final dbData = ordenCompleta?.datosCompletos;

      final rowOTValues = [
        orden['folio'] ?? '-',
        orden['no_orden']?.toString() ?? '-',
        _formatearFecha(orden['fecha_creacion']),
        orden['cliente'] ?? '-',
        orden['descripcion'] ?? '-',
        _formatearFecha(orden['fecha_entrega']),

        orden['estatus_adquisiciones'] ?? 'Pendiente',
        orden['incidente_adquisiciones'] ?? '-',
        _formatearFecha(orden['inicio_adquisiciones']),
        _formatearFecha(orden['pausa_adquisiciones']),
        _formatearFecha(orden['fin_adquisiciones']),
        _obtenerNota(dbData, 'adquisiciones', 'notas'),
        _obtenerNota(dbData, 'adquisiciones', 'notasTaller'),

        orden['estatus_diseno'] ?? 'Pendiente',
        orden['incidente_diseno'] ?? '-',
        _formatearFecha(orden['inicio_diseno']),
        _formatearFecha(orden['pausa_diseno']),
        _formatearFecha(orden['fin_diseno']),
        _obtenerNota(dbData, 'diseno', 'notas'),
        _obtenerNota(dbData, 'diseno', 'notasTaller'),

        orden['estatus_offset'] ?? 'Pendiente',
        orden['incidente_offset'] ?? '-',
        _formatearFecha(orden['inicio_offset']),
        _formatearFecha(orden['pausa_offset']),
        _formatearFecha(orden['fin_offset']),
        _obtenerNota(dbData, 'offset', 'notas'),
        _obtenerNota(dbData, 'offset', 'notasTaller'),

        orden['estatus_corte'] ?? 'Pendiente',
        orden['incidente_corte'] ?? '-',
        _formatearFecha(orden['inicio_corte']),
        _formatearFecha(orden['pausa_corte']),
        _formatearFecha(orden['fin_corte']),
        _obtenerNota(dbData, 'corte', 'notas'),
        _obtenerNota(dbData, 'corte', 'notasTaller'),

        orden['estatus_laminado'] ?? 'Pendiente',
        orden['incidente_laminado'] ?? '-',
        _formatearFecha(orden['inicio_laminado']),
        _formatearFecha(orden['pausa_laminado']),
        _formatearFecha(orden['fin_laminado']),
        _obtenerNota(dbData, 'laminados', 'notas'),
        _obtenerNota(dbData, 'laminados', 'notasTaller'),

        orden['estatus_suaje'] ?? 'Pendiente',
        orden['incidente_suaje'] ?? '-',
        _formatearFecha(orden['inicio_suaje']),
        _formatearFecha(orden['pausa_suaje']),
        _formatearFecha(orden['fin_suaje']),
        _obtenerNota(dbData, 'suaje', 'notas'),
        _obtenerNota(dbData, 'suaje', 'notasTaller'),

        orden['estatus_serigrafia'] ?? 'Pendiente',
        orden['incidente_serigrafia'] ?? '-',
        _formatearFecha(orden['inicio_serigrafia']),
        _formatearFecha(orden['pausa_serigrafia']),
        _formatearFecha(orden['fin_serigrafia']),
        _obtenerNota(dbData, 'serigrafia', 'notas'),
        _obtenerNota(dbData, 'serigrafia', 'notasTaller'),

        orden['estatus_grabado'] ?? 'Pendiente',
        orden['incidente_grabado'] ?? '-',
        _formatearFecha(orden['inicio_grabado']),
        _formatearFecha(orden['pausa_grabado']),
        _formatearFecha(orden['fin_grabado']),
        _obtenerNota(dbData, 'grabado', 'notas'),
        _obtenerNota(dbData, 'grabado', 'notasTaller'),

        orden['estatus_acabado'] ?? 'Pendiente',
        orden['incidente_acabado'] ?? '-',
        _formatearFecha(orden['inicio_acabado']),
        _formatearFecha(orden['pausa_acabado']),
        _formatearFecha(orden['fin_acabado']),
        _obtenerNota(dbData, 'acabado', 'notas'),
        _obtenerNota(dbData, 'acabado', 'notasTaller'),

        orden['estatus_barniz'] ?? 'Pendiente',
        orden['incidente_barniz'] ?? '-',
        _formatearFecha(orden['inicio_barniz']),
        _formatearFecha(orden['pausa_barniz']),
        _formatearFecha(orden['fin_barniz']),
        _obtenerNota(dbData, 'barniz', 'notas'),
        _obtenerNota(dbData, 'barniz', 'notasTaller'),

        orden['estatus_embalaje'] ?? 'Pendiente',
        orden['incidente_embalaje'] ?? '-',
        _formatearFecha(orden['inicio_embalaje']),
        _formatearFecha(orden['pausa_embalaje']),
        _formatearFecha(orden['fin_embalaje']),
        _obtenerNota(dbData, 'embalaje', 'notas'),
        _obtenerNota(dbData, 'embalaje', 'notasTaller'),

        orden['estatus_logistica'] ?? 'Pendiente',
        orden['incidente_logistica'] ?? '-',
        _formatearFecha(orden['inicio_logistica']),
        _formatearFecha(orden['pausa_logistica']),
        _formatearFecha(orden['fin_logistica']),
        _obtenerNota(dbData, 'logistica', 'notas'),
        _obtenerNota(dbData, 'logistica', 'notasTaller'),
      ];
      sheetOT.appendRow(_toRow(rowOTValues));

      final incidentesList = otId.isNotEmpty
          ? await _incidenteService.obtenerIncidentesPorOtId(otId)
          : <Map<String, dynamic>>[];

      for (var inc in incidentesList) {
        sheetInc.appendRow(_toRow([
          noOrden,
          inc['usuario_nombre'] ?? 'Sin usuario',
          inc['area'] ?? '-',
          inc['mensaje_operario'] ?? '-',
          inc['mensaje_admin'] ?? '-',
          inc['estatus'] ?? '-',
          _formatearFecha(inc['fecha_creacion']),
          _formatearFecha(inc['fecha_respuesta']),
        ]));

        if (inc['fecha_creacion'] != null) {
          cronogramaTotalEventos.add({
            'no_orden': noOrden,
            'fecha_raw': _parseFecha(inc['fecha_creacion']),
            'fecha_str': _formatearSoloFecha(inc['fecha_creacion']),
            'hora_str': _formatearSoloHora(inc['fecha_creacion']),
            'estatus': 'Incidente',
            'proceso': inc['area']?.toString() ?? 'General',
          });
        }
      }

      if (dbData != null) {
        mapProcesos.forEach((key, nombreArea) {
          if (dbData[key] != null && dbData[key] is Map) {
            final seccion = dbData[key] as Map<String, dynamic>;
            final historial = seccion['historial'] as List?;

            if (historial != null && historial.isNotEmpty) {
              for (var h in historial) {
                if (h is Map && h['fecha'] != null) {
                  cronogramaTotalEventos.add({
                    'no_orden': noOrden,
                    'fecha_raw': _parseFecha(h['fecha']),
                    'fecha_str': _formatearSoloFecha(h['fecha']),
                    'hora_str': _formatearSoloHora(h['fecha']),
                    'estatus': (h['evento']?.toString().toUpperCase() == 'FIN')
                        ? 'Fin'
                        : (h['evento']?.toString().toUpperCase() == 'PAUSA')
                        ? 'Pausa'
                        : 'Inicio',
                    'proceso': nombreArea,
                  });
                }
              }
            } else {
              if (seccion['inicio'] != null) {
                cronogramaTotalEventos.add({
                  'no_orden': noOrden,
                  'fecha_raw': _parseFecha(seccion['inicio']),
                  'fecha_str': _formatearSoloFecha(seccion['inicio']),
                  'hora_str': _formatearSoloHora(seccion['inicio']),
                  'estatus': 'Inicio',
                  'proceso': nombreArea,
                });
              }
              if (seccion['pausa'] != null) {
                cronogramaTotalEventos.add({
                  'no_orden': noOrden,
                  'fecha_raw': _parseFecha(seccion['pausa']),
                  'fecha_str': _formatearSoloFecha(seccion['pausa']),
                  'estatus': 'Pausa',
                  'proceso': nombreArea,
                });
              }
              if (seccion['fin'] != null) {
                cronogramaTotalEventos.add({
                  'no_orden': noOrden,
                  'fecha_raw': _parseFecha(seccion['fin']),
                  'fecha_str': _formatearSoloFecha(seccion['fin']),
                  'estatus': 'Fin',
                  'proceso': nombreArea,
                });
              }
            }
          }
        });
      }
    }

    cronogramaTotalEventos.sort((a, b) {
      final fa = a['fecha_raw'] as DateTime? ?? DateTime(1970);
      final fb = b['fecha_raw'] as DateTime? ?? DateTime(1970);
      return fa.compareTo(fb);
    });

    for (var ev in cronogramaTotalEventos) {
      sheetCrono.appendRow(_toRow([
        ev['no_orden'],
        ev['estatus'],
        ev['fecha_str'],
        ev['hora_str'],
        ev['proceso'],
      ]));
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final String nombreSugerido = (ordenes.length == 1)
          ? 'Reporte_OT_${ordenes.first['no_orden']?.toString().isNotEmpty == true ? ordenes.first['no_orden'] : ordenes.first['folio'] ?? 'SF'}.xlsx'
          : 'Reporte_General_OT_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';

      final String? rutaSeleccionada = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Reporte Excel',
        fileName: nombreSugerido,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (rutaSeleccionada == null || rutaSeleccionada.isEmpty) {
        return false;
      }

      final rutaFinal = rutaSeleccionada.toLowerCase().endsWith('.xlsx')
          ? rutaSeleccionada
          : '$rutaSeleccionada.xlsx';

      final file = File(rutaFinal);
      await file.writeAsBytes(fileBytes, flush: true);
      return true;
    }
    return false;
  }

  Future<bool> exportarCotizaciones(List<Cotizacion> cotizaciones) async {
    if (cotizaciones.isEmpty) return false;

    final excel = Excel.createExcel();

    const sheetName = 'Cotizaciones';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final headers = [
      'Folio',
      'Fecha Creación',
      'Tipo',
      'Cliente',
      'Descripción',
      'Medida Trabajo (cm)',
      'Tintas',
      'Cantidad Impresiones',
      'Número de Pliegos',
      'Total Pliegos',
      'Precio sin IVA',
      'Precio Unitario',
      'Precio con IVA',
      'Estatus',
      'Usuario',
    ];
    sheet.appendRow(_toRow(headers));

    for (final c in cotizaciones) {
      final rowValues = [
        c.folio ?? '-',
        c.fechaCreacion != null ? _formatearFecha(c.fechaCreacion) : '-',
        c.tipoCotizacionLabel,
        c.clienteNombre ?? 'Desconocido',
        c.descripcion,
        c.medidas,
        c.tintas,
        c.cantidadImpresiones.toString(),
        c.numPliegos.toString(),
        c.totalPliegos.toString(),
        '\$${c.precioSinIva.toStringAsFixed(2)}',
        '\$${c.precioUnitario.toStringAsFixed(4)}',
        '\$${c.precioConIva.toStringAsFixed(2)}',
        c.status,
        c.usuarioNombre ?? 'Desconocido',
      ];
      sheet.appendRow(_toRow(rowValues));
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final String nombreSugerido = (cotizaciones.length == 1)
          ? 'Cotizacion_${cotizaciones.first.folio ?? "SF"}.xlsx'
          : 'Reporte_Cotizaciones_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';

      final String? rutaSeleccionada = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Reporte de Cotizaciones',
        fileName: nombreSugerido,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (rutaSeleccionada == null || rutaSeleccionada.isEmpty) {
        return false;
      }

      final rutaFinal = rutaSeleccionada.toLowerCase().endsWith('.xlsx')
          ? rutaSeleccionada
          : '$rutaSeleccionada.xlsx';

      final file = File(rutaFinal);
      await file.writeAsBytes(fileBytes, flush: true);
      return true;
    }
    return false;
  }
}
