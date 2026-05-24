import 'dart:convert';
import '../models/ordenTrabajo_model.dart';
import 'db.dart';

class OrdenTrabajoService {
  final DatabaseService _db = DatabaseService();

  Future<String> obtenerFolioPorCotizacionId(String cotizacionId) async {
    try {
      final results = await _db.query(
        "SELECT folio FROM cotizaciones WHERE id = CAST(@id AS uuid) LIMIT 1",
        params: {'id': cotizacionId},
      );
      if (results.isNotEmpty) {
        return results.first['folio']?.toString() ?? "S/F";
      }
      return "S/F";
    } catch (e) {
      return "S/F";
    }
  }

  Future<OrdenTrabajo?> obtenerOrdenPorCotizacionId(String cotizacionId) async {
    try {
      final results = await _db.query(
        "SELECT * FROM ordenes_trabajo WHERE cotizacion_id::TEXT = @id LIMIT 1",
        params: {'id': cotizacionId},
      );

      if (results.isNotEmpty) {
        return OrdenTrabajo.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Excepción en obtenerOrdenPorCotizacionId: $e');
      return null;
    }
  }

  Future<bool> crearOrden(OrdenTrabajo orden) async {
    try {
      final rowsAffected = await _db.execute(
        """
        INSERT INTO ordenes_trabajo (cotizacion_id, estatus, datos_completos, fecha_entrega)
        VALUES (@cotizacionId, @estatus, CAST(@datosCompletos AS jsonb), @fechaEntrega)
        """,
        params: {
          'cotizacionId': orden.cotizacionId,
          'estatus': orden.estatus,
          'datosCompletos': jsonEncode(orden.datosCompletos),
          'fechaEntrega': orden.fechaEntrega?.toIso8601String(),
        },
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Excepción en crearOrden: $e');
      return false;
    }
  }

  Future<bool> actualizarOrden(OrdenTrabajo orden) async {
    if (orden.id == null) return false;

    try {
      final rowsAffected = await _db.execute(
        """
        UPDATE ordenes_trabajo
        SET estatus = @estatus,
            datos_completos = CAST(@datosCompletos AS jsonb),
            fecha_entrega = @fechaEntrega
        WHERE id = CAST(@id AS uuid)
        """,
        params: {
          'id': orden.id,
          'estatus': orden.estatus,
          'datosCompletos': jsonEncode(orden.datosCompletos),
          'fechaEntrega': orden.fechaEntrega?.toIso8601String(),
        },
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Excepción en actualizarOrden: $e');
      return false;
    }
  }

  Future<OrdenTrabajo?> obtenerOrdenPorOtId(String otId) async {
    try {
      final results = await _db.query(
        "SELECT * FROM ordenes_trabajo WHERE id::TEXT = @id LIMIT 1",
        params: {'id': otId},
      );

      if (results.isNotEmpty) {
        return OrdenTrabajo.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Excepción en obtenerOrdenPorOtId: $e');
      return null;
    }
  }
}
