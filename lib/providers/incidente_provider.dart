import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incidente_model.dart';
import '../services/incidente_service.dart';
import '../services/email.dart';

class IncidenteState {
  final bool isLoading;
  final String error;
  final List<Incidente> incidentesActuales;
  final List<Map<String, dynamic>> incidentesPendientes;
  final List<Map<String, dynamic>> historialResueltos;

  IncidenteState({
    this.isLoading = false,
    this.error = '',
    this.incidentesActuales = const [],
    this.incidentesPendientes = const [],
    this.historialResueltos = const [],
  });

  IncidenteState copyWith({
    bool? isLoading,
    String? error,
    List<Incidente>? incidentesActuales,
    List<Map<String, dynamic>>? incidentesPendientes,
    List<Map<String, dynamic>>? historialResueltos,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      incidentesActuales: incidentesActuales ?? this.incidentesActuales,
      incidentesPendientes: incidentesPendientes ?? this.incidentesPendientes,
      historialResueltos: historialResueltos ?? this.historialResueltos,
    );
  }
}

class IncidenteController extends StateNotifier<IncidenteState> {
  IncidenteController() : super(IncidenteState());

  final IncidenteService _service = IncidenteService();

  Future<void> cargarIncidentesPorOtYArea(
    String ordenTrabajoId,
    String area,
  ) async {
    state = IncidenteState(
      isLoading: true,
      error: '',
      incidentesActuales: [],
      incidentesPendientes: state.incidentesPendientes,
    );

    try {
      final incidentes = await _service.obtenerIncidentesPorOtYArea(
        ordenTrabajoId,
        area,
      );
      state = IncidenteState(
        isLoading: false,
        error: '',
        incidentesActuales: incidentes,
        incidentesPendientes: state.incidentesPendientes,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> reportarIncidente(Incidente incidente) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final exito = await _service.crearIncidente(incidente);
      if (exito) {
        try {
          final correosAdmins = await _service.obtenerCorreosAdmins();

          if (correosAdmins.isNotEmpty) {
            await EmailService.enviarCorreo(
              destinatarios: correosAdmins,
              asunto: 'Nuevo Incidente Reportado en ${incidente.area}',
              contenidoHtml:
                  '''
                <h2>Nuevo incidente</h2>
                <p><strong>Área:</strong> ${incidente.area}</p>
                <p><strong>Mensaje del operario:</strong> ${incidente.mensajeOperario}</p>
                <hr/>
                <p><small>Ingresa a la aplicación para dar respuesta a este incidente.</small></p>
              ''',
            );
          }
        } catch (e) {
          print('Error silencioso al enviar correo a admins: $e');
        }

        await cargarIncidentesPorOtYArea(
          incidente.ordenTrabajoId,
          incidente.area,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al reportar el incidente.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> cargarBandejaPendientes() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final pendientes = await _service.obtenerIncidentesPendientes();
      state = state.copyWith(
        isLoading: false,
        incidentesPendientes: pendientes,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cargarHistorialResueltos() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final historial = await _service.obtenerHistorialResueltosAdmin();
      state = state.copyWith(isLoading: false, historialResueltos: historial);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> responderIncidente(String incidenteId, String respuesta) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final exito = await _service.responderIncidente(incidenteId, respuesta);
      if (exito) {
        try {
          print('Buscando correo del operario para el incidente: $incidenteId');
          final correosEquipo = await _service
              .obtenerCorreosPorTipoDelIncidente(incidenteId);
          print('Correos recuperados desde BD: $correosEquipo');
          if (correosEquipo.isNotEmpty) {
            await EmailService.enviarCorreo(
              destinatarios: correosEquipo,
              asunto: 'Actualización de incidente en su área',
              contenidoHtml:
                  '''
                <h2>incidente contestado</h2>
                <p>El administrador ha dejado la siguiente respuesta:</p>
                <blockquote style="background: #f9f9f9; border-left: 10px solid #ccc; margin: 1.5em 10px; padding: 0.5em 10px;">
                  $respuesta
                </blockquote>
                <p>El estatus ha cambiado a <strong>Resuelto</strong>. Revisen la aplicación para más detalles.</p>
              ''',
            );
          }
        } catch (e) {
          print('Error silencioso al enviar correo al usuario: $e');
        }

        await cargarBandejaPendientes();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al enviar respuesta.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void limpiarIncidenteActual() {
    state = IncidenteState(
      isLoading: false,
      error: '',
      incidentesActuales: [],
      incidentesPendientes: state.incidentesPendientes,
    );
  }
}

final incidenteProvider =
    StateNotifierProvider<IncidenteController, IncidenteState>((ref) {
      return IncidenteController();
    });
