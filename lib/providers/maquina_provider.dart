import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maquina_model.dart';
import '../services/maquina_service.dart';

final maquinaServiceProvider = Provider((ref) => MaquinaService());

final maquinaSeleccionadaProvider = StateProvider<Maquina?>((ref) => null);

final maquinasProvider = NotifierProvider<MaquinasNotifier, MaquinasState>(
  MaquinasNotifier.new,
);

class MaquinasNotifier extends Notifier<MaquinasState> {
  late final MaquinaService _service;

  @override
  MaquinasState build() {
    _service = ref.read(maquinaServiceProvider);
    Future.microtask(() => _cargarMaquinas());
    return MaquinasState.initial();
  }

  Future<void> _cargarMaquinas() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final lista = await _service.obtenerMaquinas();
      state = state.copyWith(isLoading: false, maquinas: lista);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar máquinas: $e',
      );
    }
  }

  Future<bool> crearMaquina(Maquina maquina) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearMaquina(maquina);
      await _cargarMaquinas();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarMaquina(Maquina maquina) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarMaquina(maquina);
      await _cargarMaquinas();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarMaquina(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarMaquina(id);
      if (success) {
        await _cargarMaquinas();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo eliminar la máquina',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> recargar() async => await _cargarMaquinas();
}

class MaquinasState {
  final bool isLoading;
  final List<Maquina> maquinas;
  final String error;

  const MaquinasState({
    this.isLoading = false,
    this.maquinas = const [],
    this.error = '',
  });

  factory MaquinasState.initial() => const MaquinasState(isLoading: true);

  MaquinasState copyWith({
    bool? isLoading,
    List<Maquina>? maquinas,
    String? error,
  }) {
    return MaquinasState(
      isLoading: isLoading ?? this.isLoading,
      maquinas: maquinas ?? this.maquinas,
      error: error ?? this.error,
    );
  }
}
