import '../models/incidente_model.dart';
import 'db.dart';

class IncidenteService {
  final DatabaseService _db = DatabaseService();

  Future<bool> crearIncidente(Incidente incidente) async {
    try {
      final rows = await _db.execute(
        """
        INSERT INTO incidentes (orden_trabajo_id, usuario_id, area, mensaje_operario)
        VALUES (CAST(@otId AS uuid), CAST(@userId AS uuid), @area, @mensaje)
        """,
        params: {
          'otId': incidente.ordenTrabajoId,
          'userId': incidente.usuarioId,
          'area': incidente.area,
          'mensaje': incidente.mensajeOperario,
        },
      );

      return rows > 0;
    } catch (e) {
      print('Error al crear incidente: $e');
      return false;
    }
  }

  Future<List<Incidente>> obtenerIncidentesPorOtYArea(
    String ordenTrabajoId,
    String area,
  ) async {
    try {
      final results = await _db.query(
        """
        SELECT * FROM incidentes
        WHERE orden_trabajo_id = CAST(@ot_id AS uuid)
        AND LOWER(area) = LOWER(@area)
        ORDER BY fecha_creacion ASC
        """,
        params: {'ot_id': ordenTrabajoId, 'area': area},
      );

      return results.map((json) => Incidente.fromJson(json)).toList();
    } catch (e) {
      print('Excepción en obtenerIncidentesPorOtYArea: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerIncidentesPendientes() async {
    try {
      final results = await _db.query("""
        SELECT
          i.id as incidente_id,
          i.area,
          i.mensaje_operario,
          i.fecha_creacion,
          i.estatus,
          u.nombre as operario_nombre,
          c.folio as folio_ot
        FROM incidentes i
        LEFT JOIN usuarios u ON i.usuario_id = u.id
        LEFT JOIN ordenes_trabajo ot ON i.orden_trabajo_id = ot.id
        LEFT JOIN cotizaciones c ON ot.cotizacion_id::TEXT = c.id::TEXT
        WHERE i.estatus = 'Pendiente'
        ORDER BY i.fecha_creacion ASC
        """);

      return results;
    } catch (e) {
      print('Excepción en obtenerIncidentesPendientes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerHistorialResueltosAdmin() async {
    try {
      final results = await _db.query('''
        SELECT
          i.id as incidente_id,
          i.area,
          i.mensaje_operario,
          i.mensaje_admin,
          i.fecha_creacion,
          i.fecha_respuesta,
          i.estatus,
          u.nombre as operario_nombre,
          c.folio as folio_ot
        FROM incidentes i
        LEFT JOIN usuarios u ON i.usuario_id = u.id
        LEFT JOIN ordenes_trabajo ot ON i.orden_trabajo_id = ot.id
        LEFT JOIN cotizaciones c ON ot.cotizacion_id::TEXT = c.id::TEXT
        WHERE i.estatus = 'Resuelto'
        ORDER BY i.fecha_respuesta DESC
        LIMIT 50
      ''');
      return results;
    } catch (e) {
      print('Excepción en obtenerHistorialResueltosAdmin: $e');
      return [];
    }
  }

  Future<bool> responderIncidente(
    String incidenteId,
    String respuestaAdmin,
  ) async {
    try {
      final rowsAffected = await _db.execute(
        """
        UPDATE incidentes
        SET
          mensaje_admin = @respuesta,
          estatus = 'Resuelto',
          fecha_respuesta = CURRENT_TIMESTAMP
        WHERE id = CAST(@id AS uuid)
        """,
        params: {'id': incidenteId, 'respuesta': respuestaAdmin},
      );

      return rowsAffected > 0;
    } catch (e) {
      print('Excepción en responderIncidente: $e');
      return false;
    }
  }
}
