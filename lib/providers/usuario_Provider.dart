import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  return UsuarioService();
});

final usuariosProvider = StateNotifierProvider<UsuariosNotifier, UsuariosState>(
  (ref) {
    final service = ref.watch(usuarioServiceProvider);
    return UsuariosNotifier(service);
  },
);

final usuarioSeleccionadoProvider = StateProvider<Usuario?>((ref) => null);

class UsuariosNotifier extends StateNotifier<UsuariosState> {
  final UsuarioService _service;

  UsuariosNotifier(this._service) : super(UsuariosState.initial()) {
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final usuarios = await _service.obtenerUsuarios();
      state = state.copyWith(isLoading: false, usuarios: usuarios, error: '');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar usuarios: ${e.toString()}',
      );
    }
  }

  Future<bool> crearUsuario({
    required String usuario,
    required String correo,
    required String contrasena,
    required String tipoUsuario,
    required String nombre,
    required String apellidoPaterno,
    required String? apellidoMaterno,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '');

      await _service.crearUsuario(
        usuario: usuario,
        correo: correo,
        contrasena: contrasena,
        tipoUsuario: tipoUsuario,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
      );

      await _cargarUsuarios();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al crear usuario: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> actualizarUsuario({
    required String id,
    required String usuario,
    required String correo,
    required String tipoUsuario,
    required String nombre,
    required String apellidoPaterno,
    required String? apellidoMaterno,
    required String? nuevaContrasena,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '');

      await _service.actualizarUsuario(
        id: id,
        usuario: usuario,
        correo: correo,
        tipoUsuario: tipoUsuario,
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        nuevaContrasena: nuevaContrasena,
      );

      await _cargarUsuarios();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar usuario: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> eliminarUsuario(String usuarioId) async {
    try {
      state = state.copyWith(isLoading: true, error: '');

      final success = await _service.eliminarUsuario(usuarioId);

      if (success) {
        // Recargamos la lista
        await _cargarUsuarios();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo eliminar el usuario',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al eliminar usuario: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> recargar() async {
    await _cargarUsuarios();
  }
}

class UsuariosState {
  final bool isLoading;
  final List<Usuario> usuarios;
  final String error;

  UsuariosState({
    required this.isLoading,
    required this.usuarios,
    required this.error,
  });

  factory UsuariosState.initial() =>
      UsuariosState(isLoading: true, usuarios: [], error: '');

  UsuariosState copyWith({
    bool? isLoading,
    List<Usuario>? usuarios,
    String? error,
  }) {
    return UsuariosState(
      isLoading: isLoading ?? this.isLoading,
      usuarios: usuarios ?? this.usuarios,
      error: error ?? this.error,
    );
  }
}
