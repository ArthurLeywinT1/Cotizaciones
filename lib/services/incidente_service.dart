import '../models/incidente_model.dart';
import 'db.dart';

class IncidenteService {
  final DatabaseService _db = DatabaseService();

  Future<bool> crearIncidente(Incidente incidente) async {
    try {
      final rowsAffected = await _db.execute(
        """
        INSERT INTO incidentes
        (orden_trabajo_id, usuario_id, area, mensaje_operario, estatus)
        VALUES
        (CAST(@ot_id AS uuid), CAST(@u_id AS uuid), @area, @mensaje, @estatus)
        """,
        params: {
          'ot_id': incidente.ordenTrabajoId,
          'u_id': incidente.usuarioId,
          'area': incidente.area,
          'mensaje': incidente.mensajeOperario,
          'estatus': incidente.estatus,
        },
      );

      return rowsAffected > 0;
    } catch (e) {
      print('Excepción en crearIncidente: $e');
      return false;
    }
  }

  Future<Incidente?> obtenerIncidentePorOtYArea(
    String ordenTrabajoId,
    String area,
  ) async {
    try {
      final results = await _db.query(
        """
        SELECT * FROM incidentes
        WHERE orden_trabajo_id = CAST(@ot_id AS uuid)
        AND area = @area
        ORDER BY fecha_creacion DESC
        LIMIT 1
        """,
        params: {'ot_id': ordenTrabajoId, 'area': area},
      );

      if (results.isNotEmpty) {
        return Incidente.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Excepción en obtenerIncidentePorOtYArea: $e');
      return null;
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
