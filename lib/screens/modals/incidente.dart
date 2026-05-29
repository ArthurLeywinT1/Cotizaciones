import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/incidente_provider.dart';
import '../../models/incidente_model.dart';
import '../../providers/orden_trabajo_provider.dart';
import '../../providers/auth_provider.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(incidenteProvider.notifier)
          .cargarIncidentesPorOtYArea(widget.ordenTrabajoId, widget.area);
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidenteProvider);

    if (state.isLoading && state.incidentesActuales.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Error: ${state.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return SizedBox(
      height: 500,
      child: Column(
        children: [
          // HISTORIAL DE INCIDENTES
          Expanded(
            child: state.incidentesActuales.isEmpty
                ? const Center(
                    child: Text(
                      'No hay incidentes reportados en esta área.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.incidentesActuales.length,
                    itemBuilder: (context, index) {
                      final incidente = state.incidentesActuales[index];
                      final esResuelto = incidente.estatus == 'Resuelto';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: esResuelto
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: esResuelto
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  esResuelto
                                      ? Icons.check_circle
                                      : Icons.access_time,
                                  color: esResuelto
                                      ? Colors.green
                                      : Colors.orange,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  esResuelto ? 'RESUELTO' : 'EN REVISIÓN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: esResuelto
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            const Text(
                              'Reporte del Operario:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(incidente.mensajeOperario),
                            if (esResuelto &&
                                incidente.mensajeAdmin != null) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Respuesta del Admin:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  incidente.mensajeAdmin!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 24, thickness: 1.5),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Reportar Nuevo Incidente:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _mensajeController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Describe el problema aquí',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Enviar Reporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_mensajeController.text.trim().isEmpty) return;

                final String usuarioActivoId =
                    ref.read(authProvider).usuario?.id ?? '';

                if (usuarioActivoId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error: No se pudo identificar al usuario activo.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final nuevoIncidente = Incidente(
                  ordenTrabajoId: widget.ordenTrabajoId,
                  usuarioId: usuarioActivoId,
                  area: widget.area,
                  mensajeOperario: _mensajeController.text.trim(),
                );

                final success = await ref
                    .read(incidenteProvider.notifier)
                    .reportarIncidente(nuevoIncidente);

                if (success && context.mounted) {
                  _mensajeController.clear();
                  _scrollToBottom();
                  ref
                      .read(ordenTrabajoProvider.notifier)
                      .marcarIncidenteProceso(widget.area);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
