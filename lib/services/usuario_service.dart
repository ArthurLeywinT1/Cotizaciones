import '../models/usuario_model.dart';
import 'db.dart';
import 'hash.dart';

class UsuarioService {
  final db = DatabaseService();

  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final resultado = await db.query(
        'SELECT id, usuario, tipo_usuario, nombre, apellido_paterno, apellido_materno FROM usuarios ORDER BY apellido_paterno, nombre',
      );
      return resultado.map((row) => Usuario.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener usuarios: $e');
      rethrow;
    }
  }

  Future<Usuario> crearUsuario({
    required String usuario,
    required String contrasena,
    required String tipoUsuario,
    required String nombre,
    required String apellidoPaterno,
    required String? apellidoMaterno,
  }) async {
    try {
      final esUnico = await usuarioEsUnico(usuario);
      if (!esUnico) {
        throw Exception('El nombre de usuario ya existe');
      }

      final contrasenaHash = HashService.hashPassword(contrasena);

      await db.execute(
        '''INSERT INTO usuarios (usuario, contrasena, tipo_usuario, nombre, apellido_paterno, apellido_materno)
           VALUES (@u, @c, @t, @n, @ap, @am)''',
        params: {
          'u': usuario,
          'c': contrasenaHash,
          't': tipoUsuario,
          'n': nombre,
          'ap': apellidoPaterno,
          'am': apellidoMaterno,
        },
      );

      final usuarios = await obtenerUsuarios();
      return usuarios.firstWhere((u) => u.usuario == usuario);
    } catch (e) {
      print('Error al crear usuario: $e');
      rethrow;
    }
  }

  Future<Usuario> actualizarUsuario({
    required String id,
    required String usuario,
    required String tipoUsuario,
    required String nombre,
    required String apellidoPaterno,
    required String? apellidoMaterno,
    required String? nuevaContrasena,
  }) async {
    try {
      if (nuevaContrasena != null && nuevaContrasena.isNotEmpty) {
        final contrasenaHasheada = HashService.hashPassword(nuevaContrasena);

        await db.execute(
          '''UPDATE usuarios 
             SET usuario = @u, tipo_usuario = @t, nombre = @n, apellido_paterno = @ap, 
                 apellido_materno = @am, contrasena = @c
             WHERE id = @id''',
          params: {
            'id': id,
            'u': usuario,
            't': tipoUsuario,
            'n': nombre,
            'ap': apellidoPaterno,
            'am': apellidoMaterno,
            'c': contrasenaHasheada,
          },
        );
      } else {
        await db.execute(
          '''UPDATE usuarios 
             SET usuario = @u, tipo_usuario = @t, nombre = @n, apellido_paterno = @ap, 
                 apellido_materno = @am
             WHERE id = @id''',
          params: {
            'id': id,
            'u': usuario,
            't': tipoUsuario,
            'n': nombre,
            'ap': apellidoPaterno,
            'am': apellidoMaterno,
          },
        );
      }

      final resultado = await db.query(
        'SELECT id, usuario, tipo_usuario, nombre, apellido_paterno, apellido_materno FROM usuarios WHERE id = @id',
        params: {'id': id},
      );

      if (resultado.isEmpty)
        throw Exception('Usuario no encontrado después de actualizar');
      return Usuario.fromMap(resultado.first);
    } catch (e) {
      print('Error al actualizar usuario: $e');
      rethrow;
    }
  }

  Future<bool> eliminarUsuario(String usuarioId) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM usuarios WHERE id = @id',
        params: {'id': usuarioId},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      rethrow;
    }
  }

  Future<bool> usuarioEsUnico(String usuario, {String? excluirId}) async {
    try {
      final resultado = await db.query(
        excluirId != null
            ? 'SELECT id FROM usuarios WHERE usuario = @u AND id != @id'
            : 'SELECT id FROM usuarios WHERE usuario = @u',
        params: excluirId != null
            ? {'u': usuario, 'id': excluirId}
            : {'u': usuario},
      );
      return resultado.isEmpty;
    } catch (e) {
      print('Error al validar usuario único: $e');
      rethrow;
    }
  }
}
