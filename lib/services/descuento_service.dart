import '../models/descuento_model.dart';
import 'db.dart';

class DescuentoService {
  final db = DatabaseService();

  Future<List<DescuentoPapel>> obtenerDescuentos() async {
    try {
      final resultado = await db.query(
        'SELECT id, cantidad_desde, cantidad_hasta, descuento, fecha_modificacion FROM papel_descuentos ORDER BY cantidad_desde ASC',
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
             cantidad_desde, cantidad_hasta, descuento
           ) VALUES (@desde, @hasta, @desc)''',
        params: {
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
           SET cantidad_desde = @desde, 
               cantidad_hasta = @hasta, 
               descuento = @desc, 
               fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': descuento.id,
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
