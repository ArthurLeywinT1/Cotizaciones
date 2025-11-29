import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/papel_model.dart';
import '../services/papel_service.dart';

final papelServiceProvider = Provider<PapelService>((ref) => PapelService());

final papelSeleccionadoProvider = StateProvider<Papel?>((ref) => null);

final papelesProvider = NotifierProvider<PapelesNotifier, PapelesState>(
  PapelesNotifier.new,
);

class PapelesNotifier extends Notifier<PapelesState> {
  late final PapelService _service;

  @override
  PapelesState build() {
    _service = ref.read(papelServiceProvider);

    // CORRECCIÓN: Usamos microtask para diferir la carga hasta que el provider esté listo.
    Future.microtask(() => _cargarPapeles());

    return PapelesState.initial();
  }

  Future<void> _cargarPapeles() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final lista = await _service.obtenerPapeles();
      state = state.copyWith(isLoading: false, papeles: lista);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar papeles: $e',
      );
    }
  }

  Future<bool> crearPapel(Papel papel) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearPapel(papel);
      await _cargarPapeles();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarPapel(Papel papel) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarPapel(papel);
      await _cargarPapeles();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarPapel(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarPapel(id);
      if (success) {
        await _cargarPapeles();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo eliminar el papel',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> recargar() async => await _cargarPapeles();
}

class PapelesState {
  final bool isLoading;
  final List<Papel> papeles;
  final String error;

  const PapelesState({
    this.isLoading = false,
    this.papeles = const [],
    this.error = '',
  });

  factory PapelesState.initial() => const PapelesState(isLoading: true);

  PapelesState copyWith({
    bool? isLoading,
    List<Papel>? papeles,
    String? error,
  }) {
    return PapelesState(
      isLoading: isLoading ?? this.isLoading,
      papeles: papeles ?? this.papeles,
      error: error ?? this.error,
    );
  }
}
