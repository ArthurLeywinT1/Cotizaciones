import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';

import 'incidente_service.dart';
import 'ordenTrabajo_service.dart';

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

  Future<void> exportarOrdenTrabajo(Map<String, dynamic> orden) async {
    final excel = Excel.createExcel();

    const sheetOTName = 'Orden de Trabajo';
    excel.rename('Sheet1', sheetOTName);
    final sheetOT = excel[sheetOTName];
    final sheetCrono = excel['Cronograma'];
    final sheetInc = excel['Incidentes'];

    final otId = orden['ot_id']?.toString() ?? '';
    final noOrden = (orden['no_orden']?.toString().isNotEmpty == true)
        ? orden['no_orden'].toString()
        : (orden['folio']?.toString() ?? 'S_F');

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
      'Estatus Diseño',
      'Incidente Diseño',
      'Inicio Diseño',
      'Pausa Diseño',
      'Fin Diseño',
      'Estatus Offset',
      'Incidente Offset',
      'Inicio Offset',
      'Pausa Offset',
      'Fin Offset',
      'Estatus Corte',
      'Incidente Corte',
      'Inicio Corte',
      'Pausa Corte',
      'Fin Corte',
      'Estatus Laminado',
      'Incidente Laminado',
      'Inicio Laminado',
      'Pausa Laminado',
      'Fin Laminado',
      'Estatus Suaje',
      'Incidente Suaje',
      'Inicio Suaje',
      'Pausa Suaje',
      'Fin Suaje',
      'Estatus Serigrafía',
      'Incidente Serigrafía',
      'Inicio Serigrafía',
      'Pausa Serigrafía',
      'Fin Serigrafía',
      'Estatus Grabado',
      'Incidente Grabado',
      'Inicio Grabado',
      'Pausa Grabado',
      'Fin Grabado',
      'Estatus Acabado',
      'Incidente Acabado',
      'Inicio Acabado',
      'Pausa Acabado',
      'Fin Acabado',
      'Estatus Barniz',
      'Incidente Barniz',
      'Inicio Barniz',
      'Pausa Barniz',
      'Fin Barniz',
      'Estatus Embalaje',
      'Incidente Embalaje',
      'Inicio Embalaje',
      'Pausa Embalaje',
      'Fin Embalaje',
      'Estatus Logística',
      'Incidente Logística',
      'Inicio Logística',
      'Pausa Logística',
      'Fin Logística',
    ];
    sheetOT.appendRow(_toRow(headersOT));

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

      orden['estatus_diseno'] ?? 'Pendiente',
      orden['incidente_diseno'] ?? '-',
      _formatearFecha(orden['inicio_diseno']),
      _formatearFecha(orden['pausa_diseno']),
      _formatearFecha(orden['fin_diseno']),

      orden['estatus_offset'] ?? 'Pendiente',
      orden['incidente_offset'] ?? '-',
      _formatearFecha(orden['inicio_offset']),
      _formatearFecha(orden['pausa_offset']),
      _formatearFecha(orden['fin_offset']),

      orden['estatus_corte'] ?? 'Pendiente',
      orden['incidente_corte'] ?? '-',
      _formatearFecha(orden['inicio_corte']),
      _formatearFecha(orden['pausa_corte']),
      _formatearFecha(orden['fin_corte']),

      orden['estatus_laminado'] ?? 'Pendiente',
      orden['incidente_laminado'] ?? '-',
      _formatearFecha(orden['inicio_laminado']),
      _formatearFecha(orden['pausa_laminado']),
      _formatearFecha(orden['fin_laminado']),

      orden['estatus_suaje'] ?? 'Pendiente',
      orden['incidente_suaje'] ?? '-',
      _formatearFecha(orden['inicio_suaje']),
      _formatearFecha(orden['pausa_suaje']),
      _formatearFecha(orden['fin_suaje']),

      orden['estatus_serigrafia'] ?? 'Pendiente',
      orden['incidente_serigrafia'] ?? '-',
      _formatearFecha(orden['inicio_serigrafia']),
      _formatearFecha(orden['pausa_serigrafia']),
      _formatearFecha(orden['fin_serigrafia']),

      orden['estatus_grabado'] ?? 'Pendiente',
      orden['incidente_grabado'] ?? '-',
      _formatearFecha(orden['inicio_grabado']),
      _formatearFecha(orden['pausa_grabado']),
      _formatearFecha(orden['fin_grabado']),

      orden['estatus_acabado'] ?? 'Pendiente',
      orden['incidente_acabado'] ?? '-',
      _formatearFecha(orden['inicio_acabado']),
      _formatearFecha(orden['pausa_acabado']),
      _formatearFecha(orden['fin_acabado']),

      orden['estatus_barniz'] ?? 'Pendiente',
      orden['incidente_barniz'] ?? '-',
      _formatearFecha(orden['inicio_barniz']),
      _formatearFecha(orden['pausa_barniz']),
      _formatearFecha(orden['fin_barniz']),

      orden['estatus_embalaje'] ?? 'Pendiente',
      orden['incidente_embalaje'] ?? '-',
      _formatearFecha(orden['inicio_embalaje']),
      _formatearFecha(orden['pausa_embalaje']),
      _formatearFecha(orden['fin_embalaje']),

      orden['estatus_logistica'] ?? 'Pendiente',
      orden['incidente_logistica'] ?? '-',
      _formatearFecha(orden['inicio_logistica']),
      _formatearFecha(orden['pausa_logistica']),
      _formatearFecha(orden['fin_logistica']),
    ];
    sheetOT.appendRow(_toRow(rowOTValues));

    final ordenCompleta = otId.isNotEmpty
        ? await _otService.obtenerOrdenPorOtId(otId)
        : null;
    final incidentesList = otId.isNotEmpty
        ? await _incidenteService.obtenerIncidentesPorOtId(otId)
        : <Map<String, dynamic>>[];

    sheetCrono.appendRow(_toRow([
      'No. Orden',
      'Estatus',
      'Fecha',
      'Proceso',
    ]));

    final List<Map<String, dynamic>> cronogramaEventos = [];

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

    if (ordenCompleta != null && ordenCompleta.datosCompletos.isNotEmpty) {
      final dbData = ordenCompleta.datosCompletos;

      mapProcesos.forEach((key, nombreArea) {
        if (dbData[key] != null && dbData[key] is Map) {
          final seccion = dbData[key] as Map<String, dynamic>;
          final historial = seccion['historial'] as List?;

          if (historial != null && historial.isNotEmpty) {
            for (var h in historial) {
              if (h is Map && h['fecha'] != null) {
                cronogramaEventos.add({
                  'fecha_raw': _parseFecha(h['fecha']),
                  'fecha_str': _formatearFecha(h['fecha']),
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
              cronogramaEventos.add({
                'fecha_raw': _parseFecha(seccion['inicio']),
                'fecha_str': _formatearFecha(seccion['inicio']),
                'estatus': 'Inicio',
                'proceso': nombreArea,
              });
            }
            if (seccion['pausa'] != null) {
              cronogramaEventos.add({
                'fecha_raw': _parseFecha(seccion['pausa']),
                'fecha_str': _formatearFecha(seccion['pausa']),
                'estatus': 'Pausa',
                'proceso': nombreArea,
              });
            }
            if (seccion['fin'] != null) {
              cronogramaEventos.add({
                'fecha_raw': _parseFecha(seccion['fin']),
                'fecha_str': _formatearFecha(seccion['fin']),
                'estatus': 'Fin',
                'proceso': nombreArea,
              });
            }
          }
        }
      });
    }

    for (var inc in incidentesList) {
      if (inc['fecha_creacion'] != null) {
        cronogramaEventos.add({
          'fecha_raw': _parseFecha(inc['fecha_creacion']),
          'fecha_str': _formatearFecha(inc['fecha_creacion']),
          'estatus': 'Incidente',
          'proceso': inc['area']?.toString() ?? 'General',
        });
      }
    }

    cronogramaEventos.sort((a, b) {
      final fa = a['fecha_raw'] as DateTime? ?? DateTime(1970);
      final fb = b['fecha_raw'] as DateTime? ?? DateTime(1970);
      return fa.compareTo(fb);
    });

    for (var ev in cronogramaEventos) {
      sheetCrono.appendRow(_toRow([
        noOrden,
        ev['estatus'],
        ev['fecha_str'],
        ev['proceso'],
      ]));
    }

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
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: 'Reporte_OT_$noOrden',
        bytes: Uint8List.fromList(fileBytes),
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }
}
