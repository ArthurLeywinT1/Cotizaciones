import 'package:bcrypt/bcrypt.dart';

class HashService {
  static String hashPassword(String password) {
    try {
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      return hashedPassword;
    } catch (e) {
      print('Error al hashear contraseña: $e');
      rethrow;
    }
  }

  static bool verifyPassword(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (e) {
      print('Error al verificar contraseña: $e');
      return false;
    }
  }
}
