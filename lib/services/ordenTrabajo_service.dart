import 'dart:convert';
import '../models/ordenTrabajo_model.dart';
import 'db.dart';

class OrdenTrabajoService {
  final DatabaseService _db = DatabaseService();

  Future<List<OrdenTrabajo>> obtenerOrdenes() async {
    try {
      final results = await _db.query(
        "SELECT * FROM ordenes_trabajo ORDER BY fecha_creacion DESC",
      );

      return results.map((row) => OrdenTrabajo.fromJson(row)).toList();
    } catch (e) {
      print('Excepción en obtenerOrdenes: $e');
      return [];
    }
  }

  Future<OrdenTrabajo?> obtenerOrdenPorCotizacionId(String cotizacionId) async {
    try {
      final results = await _db.query(
        "SELECT * FROM ordenes_trabajo WHERE cotizacion_id = @id LIMIT 1",
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
          'fechaEntrega': orden.fechaEntrega,
        },
      );

      if (rowsAffected > 0) {
        print('Orden de Trabajo creada con éxito en NeonDB');
        return true;
      }
      return false;
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
          'fechaEntrega': orden.fechaEntrega,
        },
      );

      if (rowsAffected > 0) {
        print('Orden de Trabajo actualizada con éxito en NeonDB');
        return true;
      }
      return false;
    } catch (e) {
      print('Excepción en actualizarOrden: $e');
      return false;
    }
  }

  Future<bool> eliminarOrden(String id) async {
    try {
      final rowsAffected = await _db.execute(
        "DELETE FROM ordenes_trabajo WHERE id = CAST(@id AS uuid)",
        params: {'id': id},
      );

      if (rowsAffected > 0) {
        print('Orden de Trabajo eliminada con éxito de NeonDB');
        return true;
      }
      return false;
    } catch (e) {
      print('Excepción en eliminarOrden: $e');
      return false;
    }
  }
}
