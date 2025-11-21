import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';

//Aqui se verifican los datos del usuario y se maneja el estado de autenticación
final authServiceProvider = Provider(
  (ref) => AuthService(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial());

  // Esta cosa verifica tus datos demo, todavia no hay conexion a base de datos
  Future<bool> login(String usuario, String contrasena) async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      final usuarioAutenticado = await _authService.login(usuario, contrasena);

      if (usuarioAutenticado != null) {
        if (_authService.esAdmin(usuarioAutenticado)) {
          state = state.copyWith(
            isLoading: false,
            usuario: usuarioAutenticado,
            error: '',
          );
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Solo administradores pueden iniciar sesión.',
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuario o contraseña incorrectos.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: ${e.toString()}');
      return false;
    }
  }

  // Esta cosa cierra la sesion del usuario, la establece como esta abajo, como datos vacios
  void logout() {
    state = AuthState.initial();
  }
}

class AuthState {
  final bool isLoading;
  final Usuario? usuario;
  final String error;

  AuthState({
    required this.isLoading,
    required this.usuario,
    required this.error,
  });

  factory AuthState.initial() =>
      AuthState(isLoading: false, usuario: null, error: '');

  bool get isAuthenticated => usuario != null;

  AuthState copyWith({bool? isLoading, Usuario? usuario, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      usuario: usuario ?? this.usuario,
      error: error ?? this.error,
    );
  }
}
