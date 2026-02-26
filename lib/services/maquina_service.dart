import '../models/maquina_model.dart';
import 'db.dart';

class MaquinaService {
  final db = DatabaseService();

  Future<List<Maquina>> obtenerMaquinas() async {
    try {
      final resultado = await db.query(
        'SELECT * FROM maquinas ORDER BY nombre_maquina ASC',
      );
      return resultado.map((row) => Maquina.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener máquinas: $e');
      rethrow;
    }
  }

  Future<void> crearMaquina(Maquina maquina) async {
    try {
      await db.execute(
        '''INSERT INTO maquinas (
             nombre_maquina, cantidad_tintas, cantidad_tamanos, 
             ancho_maximo, largo_maximo, costo_placa_615x724, costo_placa_790x1030
           ) VALUES (@nom, @tintas, @tamanos, @ancho, @largo, @costo_615, @costo_790)''',
        params: {
          'nom': maquina.nombre,
          'tintas': maquina.cantidadTintas,
          'tamanos': maquina.cantidadTamanos,
          'ancho': maquina.anchoMaximo,
          'largo': maquina.largoMaximo,
          'costo_615': maquina.costoPlaca615x724,
          'costo_790': maquina.costoPlaca790x1030,
        },
      );
    } catch (e) {
      print('Error al crear máquina: $e');
      rethrow;
    }
  }

  Future<void> actualizarMaquina(Maquina maquina) async {
    try {
      await db.execute(
        '''UPDATE maquinas 
           SET nombre_maquina = @nom, cantidad_tintas = @tintas, 
               cantidad_tamanos = @tamanos, ancho_maximo = @ancho, 
               largo_maximo = @largo, costo_placa_615x724 = @costo_615, 
               costo_placa_790x1030 = @costo_790, 
               fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': maquina.id,
          'nom': maquina.nombre,
          'tintas': maquina.cantidadTintas,
          'tamanos': maquina.cantidadTamanos,
          'ancho': maquina.anchoMaximo,
          'largo': maquina.largoMaximo,
          'costo_615': maquina.costoPlaca615x724,
          'costo_790': maquina.costoPlaca790x1030,
        },
      );
    } catch (e) {
      print('Error al actualizar máquina: $e');
      rethrow;
    }
  }

  Future<bool> eliminarMaquina(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM maquinas WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar máquina: $e');
      rethrow;
    }
  }
}
