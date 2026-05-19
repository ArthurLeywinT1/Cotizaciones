import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/incidente_provider.dart';
import '../../providers/catalogoOT_provider.dart';

class BandejaIncidentesDialog extends ConsumerStatefulWidget {
  const BandejaIncidentesDialog({super.key});

  @override
  ConsumerState<BandejaIncidentesDialog> createState() =>
      _BandejaIncidentesDialogState();
}

class _BandejaIncidentesDialogState
    extends ConsumerState<BandejaIncidentesDialog> {
  bool _verHistorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incidenteProvider.notifier).cargarBandejaPendientes();
    });
  }

  void _mostrarDialogoRespuesta(String incidenteId) {
    final respuestaController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Responder al Operario'),
          content: TextField(
            controller: respuestaController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Escribe la respuesta aquí',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (respuestaController.text.trim().isEmpty) return;

                final success = await ref
                    .read(incidenteProvider.notifier)
                    .responderIncidente(
                      incidenteId,
                      respuestaController.text.trim(),
                    );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Respuesta enviada exitosamente',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error al enviar la respuesta',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar Respuesta'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidenteProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Gestión de Incidentes'),
        ],
      ),
      content: SizedBox(
        width: 700,
        height: 550,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Bandeja de Pendientes"),
                  selected: !_verHistorial,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _verHistorial = false);
                      ref
                          .read(incidenteProvider.notifier)
                          .cargarBandejaPendientes();
                    }
                  },
                  selectedColor: Colors.red.shade100,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !_verHistorial
                        ? Colors.red.shade900
                        : Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text("Historial"),
                  selected: _verHistorial,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _verHistorial = true);
                      ref
                          .read(incidenteProvider.notifier)
                          .cargarHistorialResueltos();
                    }
                  },
                  selectedColor: Colors.green.shade100,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _verHistorial
                        ? Colors.green.shade900
                        : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            Expanded(
              child: _verHistorial
                  ? _buildHistorialView(state)
                  : _buildPendientesView(state),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ref.read(catalogoOTProvider.notifier).cargarOrdenes();
          },
          child: const Text('Cerrar Ventana'),
        ),
      ],
    );
  }

  Widget _buildPendientesView(IncidenteState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.incidentesPendientes.isEmpty) {
      return const Center(
        child: Text(
          'No hay incidentes pendientes.\n¡Todo el flujo está trabajando sin problemas!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.incidentesPendientes.length,
      itemBuilder: (context, index) {
        final incidente = state.incidentesPendientes[index];
        final fechaStr = incidente['fecha_creacion'] != null
            ? incidente['fecha_creacion'].toString().split('.')[0]
            : '';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.red.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FOLIO: ${incidente['folio_ot'] ?? 'S/F'} - ÁREA: ${incidente['area']?.toString().toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                    Text(
                      fechaStr,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Reportado por: ${incidente['operario_nombre'] ?? 'Operario'}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Problema reportado:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incidente['mensaje_operario'] ?? 'Sin mensaje',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.reply, size: 18),
                    label: const Text('Responder y Resolver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final rawId =
                          incidente['id'] ?? incidente['incidente_id'];
                      final idString = rawId?.toString() ?? '';

                      if (idString.isNotEmpty) {
                        _mostrarDialogoRespuesta(idString);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error: No se pudo localizar el ID del incidente.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorialView(IncidenteState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.historialResueltos.isEmpty) {
      return const Center(
        child: Text(
          'No hay incidentes resueltos en el historial.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.historialResueltos.length,
      itemBuilder: (context, index) {
        final inc = state.historialResueltos[index];
        final fechaCreacion =
            inc['fecha_creacion']?.toString().split('.')[0] ?? '';
        final fechaRespuesta =
            inc['fecha_respuesta']?.toString().split('.')[0] ?? '';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FOLIO: ${inc['folio_ot'] ?? 'S/F'} - ÁREA: ${inc['area']?.toString().toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Resuelto el: $fechaRespuesta',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Reportado por: ${inc['operario_nombre'] ?? 'Operario'} ($fechaCreacion)',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  inc['mensaje_operario'] ?? '',
                  style: const TextStyle(fontSize: 13),
                ),

                const Divider(height: 20),

                const Text(
                  'Respuesta del Administrador:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    inc['mensaje_admin'] ?? 'Sin respuesta',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
