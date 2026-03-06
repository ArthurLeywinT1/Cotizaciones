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
      await db.execute('''INSERT INTO cotizaciones (
             cliente_id, usuario_id, descripcion, ancho_medida, alto_medida,
             tinta_frontal, tinta_reverso, cantidad_impresiones, total_pliegos,
             precio_sin_iva, precio_unitario, precio_con_iva, status,

             config_acabados_especiales, config_acabados, config_clientes,
             config_corte, config_costo_papel, config_costo_total,
             config_datos_papel, config_grabado, config_laminado,
             config_maquina, config_pliegos, config_serigrafia,
             config_suaje, config_embalaje
           ) VALUES (
             @cliente_id, @usuario_id, @descripcion, @ancho_medida, @alto_medida,
             @tinta_frontal, @tinta_reverso, @cantidad_impresiones, @total_pliegos,
             @precio_sin_iva, @precio_unitario, @precio_con_iva, @status,

             @config_acabados_especiales, @config_acabados, @config_clientes,
             @config_corte, @config_costo_papel, @config_costo_total,
             @config_datos_papel, @config_grabado, @config_laminado,
             @config_maquina, @config_pliegos, @config_serigrafia,
             @config_suaje, @config_embalaje
           )''', params: cotizacion.toMap());
    } catch (e) {
      print('Error al crear cotización: $e');
      rethrow;
    }
  }

  Future<void> actualizarCotizacion(Cotizacion cotizacion) async {
    try {
      await db.execute('''UPDATE cotizaciones
           SET cliente_id = @cliente_id,
               usuario_id = @usuario_id,
               descripcion = @descripcion,
               ancho_medida = @ancho_medida,
               alto_medida = @alto_medida,
               tinta_frontal = @tinta_frontal,
               tinta_reverso = @tinta_reverso,
               cantidad_impresiones = @cantidad_impresiones,
               total_pliegos = @total_pliegos,
               precio_sin_iva = @precio_sin_iva,
               precio_unitario = @precio_unitario,
               precio_con_iva = @precio_con_iva,
               status = @status,

               config_acabados_especiales = @config_acabados_especiales,
               config_acabados = @config_acabados,
               config_clientes = @config_clientes,
               config_corte = @config_corte,
               config_costo_papel = @config_costo_papel,
               config_costo_total = @config_costo_total,
               config_datos_papel = @config_datos_papel,
               config_grabado = @config_grabado,
               config_laminado = @config_laminado,
               config_maquina = @config_maquina,
               config_pliegos = @config_pliegos,
               config_serigrafia = @config_serigrafia,
               config_suaje = @config_suaje,
               config_embalaje = @config_embalaje
           WHERE id = @id''', params: cotizacion.toMap());
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
