import '../models/cotizacion_model.dart';
import 'db.dart';

class CotizacionService {
  final db = DatabaseService();

  Future<List<Cotizacion>> obtenerCotizaciones() async {
    try {
      final sql = '''
        SELECT 
          c.*, 
          cl.razon_social AS cliente_nombre, 
          u.usuario AS usuario_nombre 
        FROM cotizaciones c
        LEFT JOIN clientes cl ON c.cliente_id = cl.id
        LEFT JOIN usuarios u ON c.usuario_id = u.id
        ORDER BY c.fecha_creacion DESC
      ''';

      final resultado = await db.query(sql);
      return resultado.map((row) => Cotizacion.fromMap(row)).toList();
    } catch (e) {
      print('Error al obtener cotizaciones: $e');
      rethrow;
    }
  }

  Future<void> crearCotizacion(Cotizacion cotizacion) async {
    try {
      await db.execute(
        '''INSERT INTO cotizaciones (
             cliente_id, usuario_id, descripcion, ancho_medida, alto_medida, 
             tipo_cotizacion, tinta_frontal, tinta_reverso, cantidad_impresiones, 
             precio_sin_iva, precio_unitario, precio_con_iva, status
           ) VALUES (
             @cid, @uid, @desc, @ancho, @alto, 
             @tipo, @tFrente, @tReverso, @cant, 
             @pSinIva, @pUnit, @pConIva, @stat
           )''',
        params: {
          'cid': cotizacion.clienteId,
          'uid': cotizacion.usuarioId,
          'desc': cotizacion.descripcion,
          'ancho': cotizacion.anchoMedida,
          'alto': cotizacion.altoMedida,
          'tipo': cotizacion.tipoCotizacion,
          'tFrente': cotizacion.tintaFrontal,
          'tReverso': cotizacion.tintaReverso,
          'cant': cotizacion.cantidadImpresiones,
          'pSinIva': cotizacion.precioSinIva,
          'pUnit': cotizacion.precioUnitario,
          'pConIva': cotizacion.precioConIva,
          'stat': cotizacion.status,
        },
      );
    } catch (e) {
      print('Error al crear cotización: $e');
      rethrow;
    }
  }

  Future<void> actualizarCotizacion(Cotizacion cotizacion) async {
    try {
      await db.execute(
        '''UPDATE cotizaciones 
           SET cliente_id = @cid, 
               usuario_id = @uid, -- 🔹 MEJORA: Agregado por si se reasigna la cotización a otro vendedor
               descripcion = @desc, 
               ancho_medida = @ancho, alto_medida = @alto,
               tipo_cotizacion = @tipo, tinta_frontal = @tFrente,
               tinta_reverso = @tReverso, cantidad_impresiones = @cant,
               precio_sin_iva = @pSinIva, precio_unitario = @pUnit,
               precio_con_iva = @pConIva, status = @stat
           WHERE id = @id''',
        params: {
          'id': cotizacion.id,
          'cid': cotizacion.clienteId,
          'uid': cotizacion.usuarioId,
          'desc': cotizacion.descripcion,
          'ancho': cotizacion.anchoMedida,
          'alto': cotizacion.altoMedida,
          'tipo': cotizacion.tipoCotizacion,
          'tFrente': cotizacion.tintaFrontal,
          'tReverso': cotizacion.tintaReverso,
          'cant': cotizacion.cantidadImpresiones,
          'pSinIva': cotizacion.precioSinIva,
          'pUnit': cotizacion.precioUnitario,
          'pConIva': cotizacion.precioConIva,
          'stat': cotizacion.status,
        },
      );
    } catch (e) {
      print('Error al actualizar cotización: $e');
      rethrow;
    }
  }

  Future<bool> eliminarCotizacion(String id) async {
    try {
      final affectedRows = await db.execute(
        'DELETE FROM cotizaciones WHERE id = @id',
        params: {'id': id},
      );
      return affectedRows > 0;
    } catch (e) {
      print('Error al eliminar cotización: $e');
      rethrow;
    }
  }
}
