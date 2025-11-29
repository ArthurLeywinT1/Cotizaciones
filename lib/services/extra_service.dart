import '../models/extra_model.dart';
import 'db.dart';

class ExtraService {
  final db = DatabaseService();

  Future<List<Extra>> obtenerExtras() async {
    try {
      final resultado = await db.query(
        'SELECT * FROM extras ORDER BY nombre ASC',
      );
      return resultado.map((row) => Extra.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener extras: $e');
      rethrow;
    }
  }

  Future<void> crearExtra(Extra extra) async {
    try {
      await db.execute(
        '''INSERT INTO extras (nombre, costo_cm2, costo_minimo_total, costo_fijo)
           VALUES (@nom, @cm2, @min, @fijo)''',
        params: {
          'nom': extra.nombre,
          'cm2': extra.costoCm2,
          'min': extra.costoMinimoTotal,
          'fijo': extra.costoFijo,
        },
      );
    } catch (e) {
      print('Error al crear extra: $e');
      rethrow;
    }
  }

  Future<void> actualizarExtra(Extra extra) async {
    try {
      await db.execute(
        '''UPDATE extras 
           SET nombre = @nom, costo_cm2 = @cm2, 
               costo_minimo_total = @min, costo_fijo = @fijo, 
               fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': extra.id,
          'nom': extra.nombre,
          'cm2': extra.costoCm2,
          'min': extra.costoMinimoTotal,
          'fijo': extra.costoFijo,
        },
      );
    } catch (e) {
      print('Error al actualizar extra: $e');
      rethrow;
    }
  }

  Future<bool> eliminarExtra(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM extras WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar extra: $e');
      rethrow;
    }
  }
}
