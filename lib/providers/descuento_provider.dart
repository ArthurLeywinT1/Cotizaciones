import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/descuento_model.dart';
import '../services/descuento_service.dart';

final descuentoServiceProvider = Provider((ref) => DescuentoService());

final descuentoSeleccionadoProvider = StateProvider<DescuentoPapel?>(
  (ref) => null,
);

final descuentosProvider =
    NotifierProvider<DescuentosNotifier, DescuentosState>(
      DescuentosNotifier.new,
    );

class DescuentosNotifier extends Notifier<DescuentosState> {
  late final DescuentoService _service;

  @override
  DescuentosState build() {
    _service = ref.read(descuentoServiceProvider);
    Future.microtask(() => _cargarDescuentos());
    return DescuentosState.initial();
  }

  Future<void> _cargarDescuentos() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final lista = await _service.obtenerDescuentos();
      state = state.copyWith(isLoading: false, descuentos: lista);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cargar: $e');
    }
  }

  Future<bool> crearDescuento(DescuentoPapel descuento) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearDescuento(descuento);
      await _cargarDescuentos();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarDescuento(DescuentoPapel descuento) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarDescuento(descuento);
      await _cargarDescuentos();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarDescuento(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarDescuento(id);
      if (success) {
        await _cargarDescuentos();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'No se pudo eliminar');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> recargar() async => await _cargarDescuentos();
}

class DescuentosState {
  final bool isLoading;
  final List<DescuentoPapel> descuentos;
  final String error;

  const DescuentosState({
    this.isLoading = false,
    this.descuentos = const [],
    this.error = '',
  });

  factory DescuentosState.initial() => const DescuentosState(isLoading: true);

  DescuentosState copyWith({
    bool? isLoading,
    List<DescuentoPapel>? descuentos,
    String? error,
  }) {
    return DescuentosState(
      isLoading: isLoading ?? this.isLoading,
      descuentos: descuentos ?? this.descuentos,
      error: error ?? this.error,
    );
  }
}
