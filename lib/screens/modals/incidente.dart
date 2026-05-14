import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/incidente_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/incidente_model.dart';

class IncidenteModalContent extends ConsumerStatefulWidget {
  final String ordenTrabajoId;
  final String area;

  const IncidenteModalContent({
    super.key,
    required this.ordenTrabajoId,
    required this.area,
  });

  @override
  ConsumerState<IncidenteModalContent> createState() =>
      _IncidenteModalContentState();
}

class _IncidenteModalContentState extends ConsumerState<IncidenteModalContent> {
  final _mensajeController = TextEditingController();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(incidenteProvider.notifier)
          .cargarIncidentePorOtYArea(widget.ordenTrabajoId, widget.area);
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  void _enviarReporte() async {
    if (_mensajeController.text.trim().isEmpty) return;

    setState(() => _enviando = true);
    final usuarioId = ref.read(authProvider).usuario?.id;

    final nuevoIncidente = Incidente(
      ordenTrabajoId: widget.ordenTrabajoId,
      usuarioId: usuarioId,
      area: widget.area,
      mensajeOperario: _mensajeController.text.trim(),
    );

    final exito = await ref
        .read(incidenteProvider.notifier)
        .reportarIncidente(nuevoIncidente);
    if (mounted) {
      setState(() => _enviando = false);
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidente reportado al administrador.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar reporte. Revisa la conexión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidenteProvider);

    if (state.isLoading && state.incidenteActual == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error.isNotEmpty && state.incidenteActual == null) {
      return Text(
        "Error al cargar datos: ${state.error}",
        style: const TextStyle(color: Colors.red),
      );
    }

    final incidente = state.incidenteActual;

    if (incidente == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Describe el problema detalladamente. Se enviará una notificación a la administración.",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mensajeController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enviando ? null : _enviarReporte,
              icon: _enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_enviando ? "Enviando..." : "Enviar Reporte"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      );
    }

    if (incidente.estatus == 'Pendiente') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: const [
                Icon(Icons.access_time, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Reporte enviado. Esperando respuesta de Administración.",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "TU MENSAJE:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(incidente.mensajeOperario, style: const TextStyle(fontSize: 14)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "El administrador ha respondido.",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "TU MENSAJE:",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(incidente.mensajeOperario, style: const TextStyle(fontSize: 14)),
        const Divider(height: 24),
        const Text(
          "RESPUESTA ADMIN:",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          incidente.mensajeAdmin ?? 'Sin respuesta',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
