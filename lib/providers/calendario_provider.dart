import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendario_model.dart';
import '../services/calendario_service.dart';

class CalendarioState {
  final bool isLoading;
  final List<Calendario> calendarios;
  final String error;

  CalendarioState({
    this.isLoading = false,
    this.calendarios = const [],
    this.error = '',
  });

  CalendarioState copyWith({
    bool? isLoading,
    List<Calendario>? calendarios,
    String? error,
  }) {
    return CalendarioState(
      isLoading: isLoading ?? this.isLoading,
      calendarios: calendarios ?? this.calendarios,
      error: error ?? this.error,
    );
  }
}

class CalendarioController extends StateNotifier<CalendarioState> {
  CalendarioController() : super(CalendarioState()) {
    cargarCalendarios();
  }

  final CalendarioService _service = CalendarioService();

  Future<void> cargarCalendarios() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final calendarios = await _service.obtenerCalendarios();
      state = state.copyWith(isLoading: false, calendarios: calendarios);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> crearCalendario(Calendario calendario) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.crearCalendario(calendario);
    if (success) {
      await cargarCalendarios();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al registrar en calendario',
      );
    }
    return success;
  }

  Future<bool> eliminarCalendario(String id) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.eliminarCalendario(id);
    if (success) {
      await cargarCalendarios();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al eliminar registro de calendario',
      );
    }
    return success;
  }
}

final calendarioProvider =
    StateNotifierProvider<CalendarioController, CalendarioState>((ref) {
      return CalendarioController();
    });
