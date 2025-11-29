import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

final clienteServiceProvider = Provider<ClienteService>(
  (ref) => ClienteService(),
);

final clienteSeleccionadoProvider = StateProvider<Cliente?>((ref) => null);

final clientesProvider = StateNotifierProvider<ClientesNotifier, ClientesState>(
  (ref) {
    final service = ref.watch(clienteServiceProvider);
    return ClientesNotifier(service);
  },
);

class ClientesNotifier extends StateNotifier<ClientesState> {
  final ClienteService _service;

  ClientesNotifier(this._service) : super(ClientesState.initial()) {
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final clientes = await _service.obtenerClientes();
      state = state.copyWith(isLoading: false, clientes: clientes, error: '');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar: ${e.toString()}',
      );
    }
  }

  Future<bool> crearCliente(Cliente cliente) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.crearCliente(
        razonSocial: cliente.razonSocial,
        rfc: cliente.rfc ?? '',
        calle: cliente.calle ?? '',
        noExterior: cliente.noExterior ?? '',
        noInterior: cliente.noInterior ?? '',
        colonia: cliente.colonia ?? '',
        cp: cliente.cp ?? '',
        municipio: cliente.municipio ?? '',
        ciudad: cliente.ciudad ?? '',
        pais: cliente.pais,
        correoElectronico: cliente.correoElectronico ?? '',
        margenUtilidad: cliente.margenUtilidad,
      );
      await _cargarClientes();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizarCliente(Cliente cliente) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      await _service.actualizarCliente(
        id: cliente.id,
        razonSocial: cliente.razonSocial,
        rfc: cliente.rfc ?? '',
        calle: cliente.calle ?? '',
        noExterior: cliente.noExterior ?? '',
        noInterior: cliente.noInterior ?? '',
        colonia: cliente.colonia ?? '',
        cp: cliente.cp ?? '',
        municipio: cliente.municipio ?? '',
        ciudad: cliente.ciudad ?? '',
        pais: cliente.pais,
        correoElectronico: cliente.correoElectronico ?? '',
        margenUtilidad: cliente.margenUtilidad,
      );
      await _cargarClientes();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminarCliente(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final success = await _service.eliminarCliente(id);
      if (success) {
        await _cargarClientes();
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

  Future<void> recargar() async => await _cargarClientes();
}

class ClientesState {
  final bool isLoading;
  final List<Cliente> clientes;
  final String error;

  ClientesState({
    required this.isLoading,
    required this.clientes,
    required this.error,
  });

  factory ClientesState.initial() =>
      ClientesState(isLoading: true, clientes: [], error: '');

  ClientesState copyWith({
    bool? isLoading,
    List<Cliente>? clientes,
    String? error,
  }) {
    return ClientesState(
      isLoading: isLoading ?? this.isLoading,
      clientes: clientes ?? this.clientes,
      error: error ?? this.error,
    );
  }
}
