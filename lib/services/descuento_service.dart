import '../models/descuento_model.dart';
import 'db.dart';

class DescuentoService {
  final db = DatabaseService();

  Future<List<DescuentoPapel>> obtenerDescuentos() async {
    try {
      final resultado = await db.query(
        'SELECT * FROM papel_descuentos ORDER BY papel_id, cantidad_desde ASC',
      );
      return resultado.map((row) => DescuentoPapel.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener descuentos: $e');
      rethrow;
    }
  }

  Future<void> crearDescuento(DescuentoPapel descuento) async {
    try {
      await db.execute(
        '''INSERT INTO papel_descuentos (
             papel_id, cantidad_desde, cantidad_hasta, descuento
           ) VALUES (@pid, @desde, @hasta, @desc)''',
        params: {
          'pid': descuento.papelId,
          'desde': descuento.cantidadDesde,
          'hasta': descuento.cantidadHasta,
          'desc': descuento.descuento,
        },
      );
    } catch (e) {
      print('Error al crear descuento: $e');
      rethrow;
    }
  }

  Future<void> actualizarDescuento(DescuentoPapel descuento) async {
    try {
      await db.execute(
        '''UPDATE papel_descuentos 
           SET papel_id = @pid, cantidad_desde = @desde, 
               cantidad_hasta = @hasta, descuento = @desc, 
               fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': descuento.id,
          'pid': descuento.papelId,
          'desde': descuento.cantidadDesde,
          'hasta': descuento.cantidadHasta,
          'desc': descuento.descuento,
        },
      );
    } catch (e) {
      print('Error al actualizar descuento: $e');
      rethrow;
    }
  }

  Future<bool> eliminarDescuento(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM papel_descuentos WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar descuento: $e');
      rethrow;
    }
  }
}
