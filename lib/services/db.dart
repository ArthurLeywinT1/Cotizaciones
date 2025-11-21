import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NeonConfig {
  static String get host => dotenv.env['PGHOST'] ?? '';
  static String get database => dotenv.env['PGDATABASE'] ?? '';
  static String get username => dotenv.env['PGUSER'] ?? '';
  static String get password => dotenv.env['PGPASSWORD'] ?? '';
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;

  Future<void> connect() async {
    if (_connection != null && _connection!.isOpen) return;

    print("Conectando a NeonDB...");
    try {
      final endpoint = Endpoint(
        host: NeonConfig.host,
        database: NeonConfig.database,
        username: NeonConfig.username,
        password: NeonConfig.password,
      );

      _connection = await Connection.open(
        endpoint,
        settings: ConnectionSettings(sslMode: SslMode.require),
      );
      print("Conexión establecida exitosamente.");
    } catch (e) {
      print("Error crítico de conexión: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    await connect();

    try {
      final result = await _connection!.execute(
        Sql.named(sql),
        parameters: params,
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print("Error en Query SQL: $e");
      rethrow;
    }
  }

  Future<int> execute(String sql, {Map<String, dynamic>? params}) async {
    await connect();

    try {
      final result = await _connection!.execute(
        Sql.named(sql),
        parameters: params,
      );
      return result.affectedRows;
    } catch (e) {
      print("Error en Ejecución SQL: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> login(String usuario, String password) async {
    final resultados = await query(
      "SELECT id, usuario, tipo_usuario, nombre, apellido_paterno, apellido_materno FROM usuarios WHERE usuario = @u AND contrasena = @p",
      params: {'u': usuario, 'p': password},
    );

    if (resultados.isEmpty) return null;
    return resultados.first;
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
