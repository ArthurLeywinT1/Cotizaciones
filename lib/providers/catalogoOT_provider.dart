import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/db.dart';

class CatalogoOTState {
  final bool isLoading;
  final List<Map<String, dynamic>> ordenes;
  final String error;

  CatalogoOTState({
    this.isLoading = false,
    this.ordenes = const [],
    this.error = '',
  });

  CatalogoOTState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? ordenes,
    String? error,
  }) {
    return CatalogoOTState(
      isLoading: isLoading ?? this.isLoading,
      ordenes: ordenes ?? this.ordenes,
      error: error ?? this.error,
    );
  }
}

class CatalogoOTController extends StateNotifier<CatalogoOTState> {
  CatalogoOTController() : super(CatalogoOTState()) {
    cargarOrdenes();
  }

  final DatabaseService _db = DatabaseService();

  Future<void> cargarOrdenes({String? area}) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      String sqlQuery = """
        SELECT
          ot.id as ot_id,
          c.id as cotizacion_id,
          c.folio,
          ot.no_orden,
          ot.fecha_creacion,
          cl.razon_social as cliente,
          c.descripcion,
          ot.fecha_entrega,

          ot.datos_completos->'adquisiciones'->>'estatus' as estatus_adquisiciones,
          ot.datos_completos->'adquisiciones'->>'inicio' as inicio_adquisiciones,
          ot.datos_completos->'adquisiciones'->>'fin' as fin_adquisiciones,

          ot.datos_completos->'pre_prensa'->>'estatus' as estatus_preprensa,
          ot.datos_completos->'pre_prensa'->>'inicio' as inicio_preprensa,
          ot.datos_completos->'pre_prensa'->>'fin' as fin_preprensa,

          ot.datos_completos->'offset'->>'estatus' as estatus_offset,
          ot.datos_completos->'offset'->>'inicio' as inicio_offset,
          ot.datos_completos->'offset'->>'fin' as fin_offset,

          ot.datos_completos->'corte'->>'estatus' as estatus_corte,
          ot.datos_completos->'corte'->>'inicio' as inicio_corte,
          ot.datos_completos->'corte'->>'fin' as fin_corte,

          ot.datos_completos->'laminados'->>'estatus' as estatus_laminado,
          ot.datos_completos->'laminados'->>'inicio' as inicio_laminado,
          ot.datos_completos->'laminados'->>'fin' as fin_laminado,

          ot.datos_completos->'suaje'->>'estatus' as estatus_suaje,
          ot.datos_completos->'suaje'->>'inicio' as inicio_suaje,
          ot.datos_completos->'suaje'->>'fin' as fin_suaje,

          ot.datos_completos->'acabado'->>'estatus' as estatus_acabado,
          ot.datos_completos->'acabado'->>'inicio' as inicio_acabado,
          ot.datos_completos->'acabado'->>'fin' as fin_acabado,

          ot.datos_completos->'embalaje'->>'estatus' as estatus_embalaje,
          ot.datos_completos->'embalaje'->>'inicio' as inicio_embalaje,
          ot.datos_completos->'embalaje'->>'fin' as fin_embalaje,

          ot.datos_completos->'logistica'->>'estatus' as estatus_logistica,
          ot.datos_completos->'logistica'->>'inicio' as inicio_logistica,
          ot.datos_completos->'logistica'->>'fin' as fin_logistica

        FROM ordenes_trabajo ot
        LEFT JOIN cotizaciones c ON ot.cotizacion_id::TEXT = c.id::TEXT
        LEFT JOIN clientes cl ON c.cliente_id::TEXT = cl.id::TEXT
      """;

      if (area != null && area.isNotEmpty && area.toLowerCase() != 'admin') {
        String areaFiltro = area.toLowerCase();

        if (areaFiltro == 'pre-prensa') areaFiltro = 'diseño';

        sqlQuery +=
            " WHERE (ot.datos_completos->'activeSections'->>'$areaFiltro')::boolean = true ";
      }

      sqlQuery += " ORDER BY ot.fecha_creacion DESC";

      final results = await _db.query(sqlQuery);

      state = state.copyWith(isLoading: false, ordenes: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> eliminarOrden(String id) async {
    try {
      await _db.execute(
        "DELETE FROM ordenes_trabajo WHERE id = CAST(@id AS uuid)",
        params: {'id': id},
      );
      await cargarOrdenes();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final catalogoOTProvider =
    StateNotifierProvider<CatalogoOTController, CatalogoOTState>((ref) {
      return CatalogoOTController();
    });

final otSeleccionadaProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);
