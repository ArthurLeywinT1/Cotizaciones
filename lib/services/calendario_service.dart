import '../models/calendario_model.dart';
import 'db.dart';

class CalendarioService {
  final DatabaseService _db = DatabaseService();

  Future<List<Calendario>> obtenerCalendarios() async {
    try {
      final results = await _db.query(
        'SELECT * FROM calendario ORDER BY fecha_inicio ASC',
      );
      return results.map((row) => Calendario.fromJson(row)).toList();
    } catch (e) {
      print('Error al obtener registros del calendario: $e');
      return [];
    }
  }

  Future<bool> crearCalendario(Calendario calendario) async {
    try {
      final rowsAffected = await _db.execute(
        '''
        INSERT INTO calendario (titulo, descripcion, fecha_inicio, fecha_fin, usuario_id, area)
        VALUES (@titulo, @descripcion, @fechaInicio, @fechaFin, CAST(NULLIF(@usuarioId, '') AS uuid), @area)
        ''',
        params: {
          'titulo': calendario.titulo,
          'descripcion': calendario.descripcion,
          'fechaInicio': calendario.fechaInicio.toIso8601String(),
          'fechaFin': calendario.fechaFin.toIso8601String(),
          'usuarioId': calendario.usuarioId ?? '',
          'area': calendario.area,
        },
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error al crear registro en calendario: $e');
      return false;
    }
  }

  Future<bool> eliminarCalendario(String id) async {
    try {
      final rowsAffected = await _db.execute(
        'DELETE FROM calendario WHERE id = CAST(@id AS uuid)',
        params: {'id': id},
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Error al eliminar registro de calendario: $e');
      return false;
    }
  }

  Future<List<String>> obtenerCorreosParaCalendario(String area) async {
    try {
      List<Map<String, dynamic>> results;

      if (area.toLowerCase() == 'todos' ||
          area.toLowerCase() == 'general' ||
          area.isEmpty) {
        results = await _db.query("SELECT correo FROM usuarios");
      } else {
        results = await _db.query(
          "SELECT correo FROM usuarios WHERE LOWER(tipo_usuario) = LOWER(@area)",
          params: {'area': area},
        );
      }

      return results
          .where((row) => row['correo'] != null)
          .map((row) => row['correo'].toString().trim())
          .toList();
    } catch (e) {
      print('Error en obtenerCorreosParaCalendario: $e');
      return [];
    }
  }
}
