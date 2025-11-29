import '../models/cliente_model.dart';
import 'db.dart';

class ClienteService {
  final db = DatabaseService();

  Future<List<Cliente>> obtenerClientes() async {
    try {
      final resultado = await db.query(
        'SELECT * FROM clientes ORDER BY razon_social ASC',
      );
      return resultado.map((row) => Cliente.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener clientes: $e');
      rethrow;
    }
  }

  Future<Cliente> crearCliente({
    required String razonSocial,
    String? rfc,
    String? calle,
    String? noExterior,
    String? noInterior,
    String? colonia,
    String? cp,
    String? municipio,
    String? ciudad,
    String pais = 'México',
    String? correoElectronico,
    double margenUtilidad = 0.0,
  }) async {
    try {
      await db.execute(
        '''INSERT INTO clientes (
             razon_social, rfc, calle, no_exterior, no_interior, colonia, 
             cp, municipio, ciudad, pais, correo_electronico, margen_utilidad
           ) VALUES (@rs, @rfc, @calle, @noext, @noint, @col, @cp, @mun, @ciu, @pais, @email, @margen)''',
        params: {
          'rs': razonSocial,
          'rfc': rfc,
          'calle': calle,
          'noext': noExterior,
          'noint': noInterior,
          'col': colonia,
          'cp': cp,
          'mun': municipio,
          'ciu': ciudad,
          'pais': pais,
          'email': correoElectronico,
          'margen': margenUtilidad,
        },
      );

      final clientes = await obtenerClientes();
      return clientes.firstWhere(
        (c) => c.rfc == rfc && c.razonSocial == razonSocial,
      );
    } catch (e) {
      print('Error al crear cliente: $e');
      rethrow;
    }
  }

  Future<Cliente> actualizarCliente({
    required String id,
    required String razonSocial,
    required String rfc,
    String? calle,
    String? noExterior,
    String? noInterior,
    String? colonia,
    String? cp,
    String? municipio,
    String? ciudad,
    String pais = 'México',
    String? correoElectronico,
    double margenUtilidad = 0.0,
  }) async {
    try {
      await db.execute(
        '''UPDATE clientes 
           SET razon_social = @rs, rfc = @rfc, calle = @calle, no_exterior = @noext, 
               no_interior = @noint, colonia = @col, cp = @cp, municipio = @mun, 
               ciudad = @ciu, pais = @pais, correo_electronico = @email, 
               margen_utilidad = @margen, fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': id,
          'rs': razonSocial,
          'rfc': rfc,
          'calle': calle,
          'noext': noExterior,
          'noint': noInterior,
          'col': colonia,
          'cp': cp,
          'mun': municipio,
          'ciu': ciudad,
          'pais': pais,
          'email': correoElectronico,
          'margen': margenUtilidad,
        },
      );

      final resultado = await db.query(
        'SELECT * FROM clientes WHERE id = @id',
        params: {'id': id},
      );

      if (resultado.isEmpty)
        throw Exception('Cliente no encontrado después de actualizar');
      return Cliente.fromMap(resultado.first);
    } catch (e) {
      print('Error al actualizar cliente: $e');
      rethrow;
    }
  }

  Future<bool> eliminarCliente(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM clientes WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar cliente: $e');
      rethrow;
    }
  }
}
