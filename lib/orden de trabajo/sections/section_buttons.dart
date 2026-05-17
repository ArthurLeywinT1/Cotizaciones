import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orden_trabajo_provider.dart';
import '../../screens/modals/incidente.dart';

class SectionButtons extends ConsumerWidget {
  final String area;
  final String ordenTrabajoId;

  const SectionButtons({
    super.key,
    required this.area,
    required this.ordenTrabajoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            label: "Inicio",
            icon: Icons.play_arrow,
            color: Colors.blue,
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Iniciando proceso en ${area.toUpperCase()}...',
                  ),
                ),
              );
              await ref
                  .read(ordenTrabajoProvider.notifier)
                  .iniciarProceso(area);
            },
          ),

          _buildButton(
            label: "Fin",
            icon: Icons.stop,
            color: Colors.green,
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Finalizando proceso en ${area.toUpperCase()}...',
                  ),
                ),
              );
              await ref
                  .read(ordenTrabajoProvider.notifier)
                  .terminarProceso(area);
            },
          ),

          _buildButton(
            label: "Incidente",
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            onPressed: () {
              ref
                  .read(ordenTrabajoProvider.notifier)
                  .marcarIncidenteProceso(area);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Incidente - Área: ${area.toUpperCase()}"),
                    content: SizedBox(
                      width: 400,
                      child: IncidenteModalContent(
                        ordenTrabajoId: ordenTrabajoId,
                        area: area,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cerrar"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        foregroundColor: color.shade700,
        backgroundColor: color.shade50,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: color.shade200, width: 1),
      ),
    );
  }
}
