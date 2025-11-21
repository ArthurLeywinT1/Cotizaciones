import 'db.dart';
import '../models/usuario_model.dart';

class AuthService {
  // La base de datos no esta conectada, ya me dio weba, luego lo hago
  final DatabaseService _dbService = DatabaseService();

  Future<Usuario?> login(String usuario, String contrasena) async {
    try {
      const usuariosDemo = {
        'admin': {'contrasena': '1234', 'tipo': 'Admin'},
        'usuario1': {'contrasena': 'pass1', 'tipo': 'Offset'},
      };

      if (usuariosDemo.containsKey(usuario) &&
          usuariosDemo[usuario]!['contrasena'] == contrasena) {
        await Future.delayed(const Duration(milliseconds: 500));

        return Usuario(
          id: 'demo-${usuario}',
          usuario: usuario,
          tipoUsuario: usuariosDemo[usuario]!['tipo']!,
          nombre: usuario == 'admin' ? 'Administrador' : 'Usuario Demo',
          apellidoPaterno: 'Sistema',
          apellidoMaterno: 'Cotizador',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error en autenticación: $e');
    }
  }

  bool esAdmin(Usuario usuario) => usuario.tipoUsuario == 'Admin';
}
