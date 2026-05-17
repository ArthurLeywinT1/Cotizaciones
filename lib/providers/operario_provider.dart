import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/db.dart';

class OperarioOTState {
  final bool isLoading;
  final List<Map<String, dynamic>> ordenes;
  final String error;

  OperarioOTState({
    this.isLoading = false,
    this.ordenes = const [],
    this.error = '',
  });

  OperarioOTState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? ordenes,
    String? error,
  }) {
    return OperarioOTState(
      isLoading: isLoading ?? this.isLoading,
      ordenes: ordenes ?? this.ordenes,
      error: error ?? this.error,
    );
  }
}

class OperarioOTController extends StateNotifier<OperarioOTState> {
  OperarioOTController() : super(OperarioOTState());

  final DatabaseService _db = DatabaseService();

  Future<void> cargarOrdenesOperario(String area, bool verHistorial) async {
    state = state.copyWith(isLoading: true, error: '');
    String areaKey = area.toLowerCase().trim();
    if (areaKey == 'diseño' || areaKey == 'pre-prensa') areaKey = 'diseno';

    try {
      String estatusFiltro = verHistorial
          ? "ot.datos_completos->'$areaKey'->>'estatus' = 'Fin'"
          : "COALESCE(ot.datos_completos->'$areaKey'->>'estatus', 'Pendiente') != 'Fin'";

      final results = await _db.query(
        """
        SELECT
          ot.id as ot_id,
          c.id as cotizacion_id,
          c.folio,
          ot.no_orden,
          ot.fecha_creacion,
          cl.razon_social as cliente,
          c.descripcion,
          ot.datos_completos->'logistica'->>'fechaEntrega' as fecha_entrega,

          COALESCE(ot.datos_completos->'$areaKey'->>'estatus', 'Pendiente') as estatus_departamento,
          ot.datos_completos->'$areaKey'->>'inicio' as inicio_departamento,
          ot.datos_completos->'$areaKey'->>'fin' as fin_departamento,
          i.estatus as estatus_incidente

        FROM ordenes_trabajo ot
        LEFT JOIN cotizaciones c ON ot.cotizacion_id::TEXT = c.id::TEXT
        LEFT JOIN clientes cl ON c.cliente_id::TEXT = cl.id::TEXT

        LEFT JOIN incidentes i ON i.orden_trabajo_id = ot.id AND i.area = @area

        WHERE COALESCE(ot.datos_completos->'activeSections'->>'$areaKey', 'true') = 'true'
          AND $estatusFiltro
          AND ot.estatus != 'Cancelada'

        ORDER BY ot.fecha_creacion DESC
      """,
        params: {'area': area},
      );

      state = state.copyWith(isLoading: false, ordenes: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final operarioOTProvider =
    StateNotifierProvider<OperarioOTController, OperarioOTState>((ref) {
      return OperarioOTController();
    });

final otOperarioSeleccionadaProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);
