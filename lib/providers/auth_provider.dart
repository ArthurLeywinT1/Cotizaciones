import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  final bool isLoading;
  final Usuario? usuario;
  final String? error;

  const AuthState({this.isLoading = false, this.usuario, this.error});

  factory AuthState.initial() =>
      const AuthState(isLoading: false, usuario: null, error: null);

  bool get isAuthenticated => usuario != null;

  AuthState copyWith({bool? isLoading, Usuario? usuario, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      usuario: usuario ?? this.usuario,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<bool> login(String usuario, String contrasena) async {
    state = state.copyWith(isLoading: true, error: null);

    if (state.error != null) {
      state = const AuthState(isLoading: true, usuario: null, error: null);
    }

    try {
      final authService = ref.read(authServiceProvider);

      final usuarioAutenticado = await authService.login(usuario, contrasena);

      if (usuarioAutenticado != null) {
        if (authService.esAdmin(usuarioAutenticado)) {
          state = state.copyWith(
            isLoading: false,
            usuario: usuarioAutenticado,
            error: null,
          );
          return true;
        } else {
          state = const AuthState(
            isLoading: false,
            usuario: null,
            error: 'Solo los administradores pueden iniciar sesión.',
          );
          return false;
        }
      } else {
        state = const AuthState(
          isLoading: false,
          usuario: null,
          error: 'Usuario o contraseña incorrectos.',
        );
        return false;
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        usuario: null,
        error: 'Error: ${e.toString()}',
      );
      return false;
    }
  }

  void logout() {
    state = AuthState.initial();
  }
}
