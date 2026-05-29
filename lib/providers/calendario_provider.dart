import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/calendario_model.dart';
import '../services/calendario_service.dart';
import '../services/email.dart';

class CalendarioState {
  final bool isLoading;
  final List<Calendario> calendarios;
  final String error;

  CalendarioState({
    this.isLoading = false,
    this.calendarios = const [],
    this.error = '',
  });

  CalendarioState copyWith({
    bool? isLoading,
    List<Calendario>? calendarios,
    String? error,
  }) {
    return CalendarioState(
      isLoading: isLoading ?? this.isLoading,
      calendarios: calendarios ?? this.calendarios,
      error: error ?? this.error,
    );
  }
}

class CalendarioController extends StateNotifier<CalendarioState> {
  CalendarioController() : super(CalendarioState()) {
    cargarCalendarios();
  }

  final CalendarioService _service = CalendarioService();

  Future<void> cargarCalendarios() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final calendarios = await _service.obtenerCalendarios();
      state = state.copyWith(isLoading: false, calendarios: calendarios);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> crearCalendario(Calendario calendario) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.crearCalendario(calendario);
    if (success) {
      try {
        final correosDestino = await _service.obtenerCorreosParaCalendario(
          calendario.area,
        );
        if (correosDestino.isNotEmpty) {
          final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
          final fechaInicioStr = formatoFecha.format(calendario.fechaInicio);
          final fechaFinStr = formatoFecha.format(calendario.fechaFin);

          await EmailService.enviarCorreo(
            destinatarios: correosDestino,
            asunto: '📅 Nuevo Evento Programado: ${calendario.titulo}',
            contenidoHtml:
                '''
              <h2>Se ha agendado un nuevo evento para el área de ${calendario.area.toUpperCase()}</h2>
              <p><strong>Evento:</strong> ${calendario.titulo}</p>
              <p><strong>Descripción:</strong> ${calendario.descripcion}</p>
              <br/>
              <div style="background-color: #f0f8ff; padding: 12px; border-radius: 8px; border-left: 5px solid #2196F3;">
                <p style="margin: 4px 0;"><strong>Inicia:</strong> $fechaInicioStr</p>
                <p style="margin: 4px 0;"><strong>Termina:</strong> $fechaFinStr</p>
              </div>
              <br/>
              <p><small>Por favor, revisa el calendario en la aplicación para más detalles.</small></p>
            ''',
          );
        }
      } catch (e) {
        print('Error silencioso al enviar correo de calendario: $e');
      }

      await cargarCalendarios();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al registrar en calendario',
      );
    }
    return success;
  }

  Future<bool> eliminarCalendario(String id) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.eliminarCalendario(id);
    if (success) {
      await cargarCalendarios();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al eliminar registro de calendario',
      );
    }
    return success;
  }
}

final calendarioProvider =
    StateNotifierProvider<CalendarioController, CalendarioState>((ref) {
      return CalendarioController();
    });
