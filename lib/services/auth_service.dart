import '../models/usuario_model.dart';
import 'db.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();

  Future<Usuario?> login(String usuario, String contrasena) async {
    try {
      final datosUsuario = await _dbService.login(usuario, contrasena);

      if (datosUsuario != null) {
        return Usuario.fromMap(datosUsuario);
      }
      return null;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  bool esAdmin(Usuario usuario) => usuario.tipoUsuario == 'Admin';
}
