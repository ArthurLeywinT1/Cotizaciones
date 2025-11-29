import '../models/proveedor_model.dart';
import 'db.dart';

class ProveedorService {
  final db = DatabaseService();

  Future<List<Proveedor>> obtenerProveedores() async {
    try {
      final resultado = await db.query(
        'SELECT * FROM proveedores ORDER BY razon_social ASC',
      );
      return resultado.map((row) => Proveedor.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener proveedores: $e');
      rethrow;
    }
  }

  Future<Proveedor> crearProveedor({
    required String razonSocial,
    String? rfc,
    String? direccion,
    String? telefono,
    String? correoElectronico,
  }) async {
    try {
      await db.execute(
        '''INSERT INTO proveedores (
             razon_social, rfc, direccion, telefono, correo_electronico
           ) VALUES (@rs, @rfc, @direccion, @telefono, @email)''',
        params: {
          'rs': razonSocial,
          'rfc': rfc,
          'direccion': direccion,
          'telefono': telefono,
          'email': correoElectronico,
        },
      );

      final proveedores = await obtenerProveedores();
      return proveedores.firstWhere(
        (c) => c.rfc == rfc && c.razonSocial == razonSocial,
      );
    } catch (e) {
      print('Error al crear proveedor: $e');
      rethrow;
    }
  }

  Future<Proveedor> actualizarProveedor({
    required String id,
    required String razonSocial,
    String? rfc,
    String? direccion,
    String? telefono,
    String pais = 'México',
    String? correoElectronico,
  }) async {
    try {
      await db.execute(
        '''UPDATE proveedores 
           SET razon_social = @rs, rfc = @rfc, direccion = @direccion, telefono = @telefono, 
               correo_electronico = @email, fecha_modificacion = NOW()
           WHERE id = @id''',
        params: {
          'id': id,
          'rs': razonSocial,
          'rfc': rfc,
          'direccion': direccion,
          'telefono': telefono,
          'email': correoElectronico,
        },
      );

      final resultado = await db.query(
        'SELECT * FROM proveedores WHERE id = @id',
        params: {'id': id},
      );

      if (resultado.isEmpty)
        throw Exception('Proveedor no encontrado después de actualizar');
      return Proveedor.fromMap(resultado.first);
    } catch (e) {
      print('Error al actualizar proveedor: $e');
      rethrow;
    }
  }

  Future<bool> eliminarProveedor(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM proveedores WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar proveedor: $e');
      rethrow;
    }
  }
}
