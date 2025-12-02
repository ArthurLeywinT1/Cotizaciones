import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/proveedor_model.dart';
import '../services/proveedor_service.dart';

final proveedorServiceProvider = Provider<ProveedorService>(
  (ref) => ProveedorService(),
);

final proveedorSeleccionadoProvider = StateProvider<Proveedor?>((ref) => null);

final proveedoresProvider =
    NotifierProvider<ProveedoresNotifier, ProveedoresState>(() {
      return ProveedoresNotifier(ProveedorService());
    });

class ProveedoresNotifier extends Notifier<ProveedoresState> {
  final ProveedorService _service;

  ProveedoresNotifier(this._service);

  @override
  ProveedoresState build() {
    Future.microtask(() => _cargarProveedores());

    return ProveedoresState.initial();
  }

  Future<void> _cargarProveedores() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final proveedores = await _service.obtenerProveedores();
      state = state.copyWith(
        isLoading: false,
        proveedores: proveedores,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar: ${e.toString()}',
      );
    }
  }

  Future<bool> crearProveedor(Proveedor proveedor) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearProveedor(
        razonSocial: proveedor.razonSocial,
        rfc: proveedor.rfc ?? '',
        direccion: proveedor.direccion ?? '',
        telefono: proveedor.telefono ?? '',
        correoElectronico: proveedor.correoElectronico ?? '',
      );
      await _cargarProveedores();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarProveedor(Proveedor proveedor) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarProveedor(
        id: proveedor.id,
        razonSocial: proveedor.razonSocial,
        rfc: proveedor.rfc ?? '',
        direccion: proveedor.direccion ?? '',
        telefono: proveedor.telefono ?? '',
        correoElectronico: proveedor.correoElectronico ?? '',
      );
      await _cargarProveedores();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarProveedor(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarProveedor(id);
      if (success) {
        await _cargarProveedores();
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

  Future<void> recargar() async => await _cargarProveedores();
}

class ProveedoresState {
  final bool isLoading;
  final List<Proveedor> proveedores;
  final String error;

  ProveedoresState({
    required this.isLoading,
    required this.proveedores,
    required this.error,
  });

  factory ProveedoresState.initial() =>
      ProveedoresState(isLoading: true, proveedores: [], error: '');

  ProveedoresState copyWith({
    bool? isLoading,
    List<Proveedor>? proveedores,
    String? error,
  }) {
    return ProveedoresState(
      isLoading: isLoading ?? this.isLoading,
      proveedores: proveedores ?? this.proveedores,
      error: error ?? this.error,
    );
  }
}
