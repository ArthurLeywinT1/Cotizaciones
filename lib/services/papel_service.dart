import '../models/papel_model.dart';
import 'db.dart';

class PapelService {
  final db = DatabaseService();

  Future<List<Papel>> obtenerPapeles() async {
    try {
      final resultado = await db.query(
        'SELECT * FROM papeles ORDER BY nombre_papel ASC',
      );
      return resultado.map((row) => Papel.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener papeles: $e');
      rethrow;
    }
  }

  Future<void> crearPapel(Papel papel) async {
    try {
      await db.execute(
        '''INSERT INTO papeles (
             nombre_papel, tipo_papel, medida_ancho, medida_largo, 
             peso_gramaje, costo_millar, proveedor_id
           ) VALUES (@nom, @tipo, @ancho, @largo, @peso, @costo, @prov)''',
        params: {
          'nom': papel.nombre,
          'tipo': papel.tipo,
          'ancho': papel.ancho,
          'largo': papel.largo,
          'peso': papel.peso,
          'costo': papel.costoMillar,
          'prov': papel.proveedorId,
        },
      );
    } catch (e) {
      print('Error al crear papel: $e');
      rethrow;
    }
  }

  Future<void> actualizarPapel(Papel papel) async {
    try {
      await db.execute(
        '''UPDATE papeles 
           SET nombre_papel = @nom, tipo_papel = @tipo, 
               medida_ancho = @ancho, medida_largo = @largo, 
               peso_gramaje = @peso, costo_millar = @costo, 
               proveedor_id = @prov, fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': papel.id,
          'nom': papel.nombre,
          'tipo': papel.tipo,
          'ancho': papel.ancho,
          'largo': papel.largo,
          'peso': papel.peso,
          'costo': papel.costoMillar,
          'prov': papel.proveedorId,
        },
      );
    } catch (e) {
      print('Error al actualizar papel: $e');
      rethrow;
    }
  }

  Future<bool> eliminarPapel(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM papeles WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar papel: $e');
      rethrow;
    }
  }
}
