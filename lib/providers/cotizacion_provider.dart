import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cotizacion_model.dart';
import '../services/cotizacion_service.dart';

final cotizacionServiceProvider = Provider<CotizacionService>(
  (ref) => CotizacionService(),
);

final cotizacionSeleccionadaProvider = StateProvider<Cotizacion?>(
  (ref) => null,
);

final cotizacionesProvider =
    NotifierProvider<CotizacionesNotifier, CotizacionesState>(
      CotizacionesNotifier.new,
    );

class CotizacionesNotifier extends Notifier<CotizacionesState> {
  late final CotizacionService _service;

  @override
  CotizacionesState build() {
    _service = ref.read(cotizacionServiceProvider);
    Future.microtask(() => _cargarCotizaciones());
    return CotizacionesState.initial();
  }

  Future<void> _cargarCotizaciones() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final lista = await _service.obtenerCotizaciones();
      state = state.copyWith(isLoading: false, cotizaciones: lista);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar cotizaciones: $e',
      );
    }
  }

  Future<bool> crearCotizacion(Cotizacion cotizacion) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearCotizacion(cotizacion);
      await _cargarCotizaciones();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarCotizacion(Cotizacion cotizacion) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarCotizacion(cotizacion);
      await _cargarCotizaciones();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarCotizacion(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarCotizacion(id);
      if (success) {
        await _cargarCotizaciones();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo eliminar la cotización',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cambiarStatus(String id, String nuevoStatus) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.actualizarStatus(id, nuevoStatus);

      if (success) {
        await _cargarCotizaciones();
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo actualizar el status',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> recargar() async => await _cargarCotizaciones();
}

class CotizacionesState {
  final bool isLoading;
  final List<Cotizacion> cotizaciones;
  final String error;

  const CotizacionesState({
    this.isLoading = false,
    this.cotizaciones = const [],
    this.error = '',
  });

  factory CotizacionesState.initial() =>
      const CotizacionesState(isLoading: true);

  CotizacionesState copyWith({
    bool? isLoading,
    List<Cotizacion>? cotizaciones,
    String? error,
  }) {
    return CotizacionesState(
      isLoading: isLoading ?? this.isLoading,
      cotizaciones: cotizaciones ?? this.cotizaciones,
      error: error ?? this.error,
    );
  }
}
