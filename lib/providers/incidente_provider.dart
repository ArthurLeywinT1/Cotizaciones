import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incidente_model.dart';
import '../services/incidente_service.dart';

class IncidenteState {
  final bool isLoading;
  final String error;
  final List<Incidente> incidentesActuales;
  final List<Map<String, dynamic>> incidentesPendientes;

  IncidenteState({
    this.isLoading = false,
    this.error = '',
    this.incidentesActuales = const [],
    this.incidentesPendientes = const [],
  });

  IncidenteState copyWith({
    bool? isLoading,
    String? error,
    List<Incidente>? incidentesActuales,
    List<Map<String, dynamic>>? incidentesPendientes,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      incidentesActuales: incidentesActuales ?? this.incidentesActuales,
      incidentesPendientes: incidentesPendientes ?? this.incidentesPendientes,
    );
  }
}

class IncidenteController extends StateNotifier<IncidenteState> {
  IncidenteController() : super(IncidenteState());

  final IncidenteService _service = IncidenteService();

  Future<void> cargarIncidentesPorOtYArea(
    String ordenTrabajoId,
    String area,
  ) async {
    state = IncidenteState(
      isLoading: true,
      error: '',
      incidentesActuales: [],
      incidentesPendientes: state.incidentesPendientes,
    );

    try {
      final incidentes = await _service.obtenerIncidentesPorOtYArea(
        ordenTrabajoId,
        area,
      );

      state = IncidenteState(
        isLoading: false,
        error: '',
        incidentesActuales: incidentes,
        incidentesPendientes: state.incidentesPendientes,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> reportarIncidente(Incidente incidente) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final exito = await _service.crearIncidente(incidente);
      if (exito) {
        await cargarIncidentesPorOtYArea(
          incidente.ordenTrabajoId,
          incidente.area,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al reportar el incidente.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> cargarBandejaPendientes() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final pendientes = await _service.obtenerIncidentesPendientes();
      state = state.copyWith(
        isLoading: false,
        incidentesPendientes: pendientes,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> responderIncidente(String incidenteId, String respuesta) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final exito = await _service.responderIncidente(incidenteId, respuesta);
      if (exito) {
        await cargarBandejaPendientes();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al enviar respuesta.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void limpiarIncidenteActual() {
    state = IncidenteState(
      isLoading: false,
      error: '',
      incidentesActuales: [],
      incidentesPendientes: state.incidentesPendientes,
    );
  }
}

final incidenteProvider =
    StateNotifierProvider<IncidenteController, IncidenteState>((ref) {
      return IncidenteController();
    });
