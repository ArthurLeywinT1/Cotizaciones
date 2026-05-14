import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incidente_model.dart';
import '../services/incidente_service.dart';

class IncidenteState {
  final bool isLoading;
  final String error;
  final Incidente? incidenteActual;
  final List<Map<String, dynamic>> incidentesPendientes;

  IncidenteState({
    this.isLoading = false,
    this.error = '',
    this.incidenteActual,
    this.incidentesPendientes = const [],
  });

  IncidenteState copyWith({
    bool? isLoading,
    String? error,
    Incidente? incidenteActual,
    List<Map<String, dynamic>>? incidentesPendientes,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      incidenteActual: incidenteActual ?? this.incidenteActual,
      incidentesPendientes: incidentesPendientes ?? this.incidentesPendientes,
    );
  }
}

class IncidenteController extends StateNotifier<IncidenteState> {
  IncidenteController() : super(IncidenteState());

  final IncidenteService _service = IncidenteService();

  Future<void> cargarIncidentePorOtYArea(
    String ordenTrabajoId,
    String area,
  ) async {
    state = IncidenteState(
      isLoading: true,
      error: '',
      incidenteActual: null,
      incidentesPendientes: state.incidentesPendientes,
    );

    try {
      final incidente = await _service.obtenerIncidentePorOtYArea(
        ordenTrabajoId,
        area,
      );
      state = IncidenteState(
        isLoading: false,
        error: '',
        incidenteActual: incidente,
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
        state = state.copyWith(isLoading: false, incidenteActual: incidente);
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
      incidenteActual: null,
      incidentesPendientes: state.incidentesPendientes,
    );
  }
}

final incidenteProvider =
    StateNotifierProvider<IncidenteController, IncidenteState>((ref) {
      return IncidenteController();
    });
