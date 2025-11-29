import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/extra_model.dart';
import '../services/extra_service.dart';

final extraServiceProvider = Provider<ExtraService>((ref) => ExtraService());

final extraSeleccionadoProvider = StateProvider<Extra?>((ref) => null);

final extrasProvider = NotifierProvider<ExtrasNotifier, ExtrasState>(
  ExtrasNotifier.new,
);

class ExtrasNotifier extends Notifier<ExtrasState> {
  late final ExtraService _service;

  @override
  ExtrasState build() {
    _service = ref.read(extraServiceProvider);
    Future.microtask(() => _cargarExtras());
    return ExtrasState.initial();
  }

  Future<void> _cargarExtras() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final lista = await _service.obtenerExtras();
      state = state.copyWith(isLoading: false, extras: lista);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar extras: $e',
      );
    }
  }

  Future<bool> crearExtra(Extra extra) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearExtra(extra);
      await _cargarExtras();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarExtra(Extra extra) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarExtra(extra);
      await _cargarExtras();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarExtra(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarExtra(id);
      if (success) {
        await _cargarExtras();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo eliminar el extra',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> recargar() async => await _cargarExtras();
}

class ExtrasState {
  final bool isLoading;
  final List<Extra> extras;
  final String error;

  const ExtrasState({
    this.isLoading = false,
    this.extras = const [],
    this.error = '',
  });

  factory ExtrasState.initial() => const ExtrasState(isLoading: true);

  ExtrasState copyWith({bool? isLoading, List<Extra>? extras, String? error}) {
    return ExtrasState(
      isLoading: isLoading ?? this.isLoading,
      extras: extras ?? this.extras,
      error: error ?? this.error,
    );
  }
}
