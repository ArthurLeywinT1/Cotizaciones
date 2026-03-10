import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/papel_provider.dart';
import '../../providers/proveedor_provider.dart';
import '../modals/modal_papel.dart';
import 'buscador_papel.dart';

// Panel específico para el ingreso y visualización de datos del papel a usar en la cotización plana
class PanelDatosPapel extends ConsumerStatefulWidget {
  final TextEditingController nombrePapelController;
  final TextEditingController tipoPapelController;
  final TextEditingController anchoPapelController;
  final TextEditingController largoPapelController;
  final TextEditingController pesoPapelController;
  final TextEditingController proveedorPapelController;
  final TextEditingController costoMillarController;
  final TextEditingController totalPliegosController;

  final TextEditingController pliegoAnchoController;
  final TextEditingController pliegoAltoController;

  const PanelDatosPapel({
    super.key,
    required this.nombrePapelController,
    required this.tipoPapelController,
    required this.anchoPapelController,
    required this.largoPapelController,
    required this.pesoPapelController,
    required this.proveedorPapelController,
    required this.costoMillarController,
    required this.totalPliegosController,
    required this.pliegoAnchoController,
    required this.pliegoAltoController,
  });

  @override
  ConsumerState<PanelDatosPapel> createState() => _PanelDatosPapelState();
}

class _PanelDatosPapelState extends ConsumerState<PanelDatosPapel> {
  void _buscarPapel() {
    final double reqAncho =
        double.tryParse(widget.pliegoAnchoController.text) ?? 0.0;
    final double reqAlto =
        double.tryParse(widget.pliegoAltoController.text) ?? 0.0;

    showDialog(
      context: context,
      builder: (_) => DialogoSelectorPapel(
        minAncho: reqAncho,
        minLargo: reqAlto,
        onSeleccionado: (papel) {
          widget.nombrePapelController.text = papel.nombre;
          widget.tipoPapelController.text = papel.tipo ?? '';
          widget.anchoPapelController.text = papel.ancho?.toString() ?? '0';
          widget.largoPapelController.text = papel.largo?.toString() ?? '0';
          widget.pesoPapelController.text = papel.peso?.toString() ?? '0';
          widget.costoMillarController.text = papel.costoMillar.toString();

          if (papel.proveedorId != null) {
            final proveedores = ref.read(proveedoresProvider).proveedores;
            try {
              final proveedor = proveedores.firstWhere(
                (p) => p.id == papel.proveedorId,
              );
              widget.proveedorPapelController.text = proveedor.razonSocial;
            } catch (e) {
              widget.proveedorPapelController.text = "Proveedor no encontrado";
            }
          } else {
            widget.proveedorPapelController.text = "";
          }
        },
      ),
    );
  }

  void _agregarPapel(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> proveedores,
  ) {
    showDialog(
      context: context,
      builder: (context) => ModalPapel(
        titulo: 'Nuevo Papel',
        listaProveedores: ref.read(proveedoresProvider).proveedores,
        onGuardar: (papelNuevo) async {
          final success = await ref
              .read(papelesProvider.notifier)
              .crearPapel(papelNuevo);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Papel creado')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Datos del Papel a Usar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            // ================= NOMBRE PAPEL ====================
            Row(
              children: [
                const SizedBox(width: 120, child: Text("Nombre Papel:")),
                Expanded(
                  child: TextField(
                    controller: widget.nombrePapelController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarPapel,
                  tooltip: "Buscar papel",
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _agregarPapel(context, ref, []),
                  tooltip: "Agregar papel",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= TIPO PAPEL ====================
            Row(
              children: [
                const SizedBox(width: 120, child: Text("Tipo Papel:")),
                Expanded(
                  child: TextField(
                    controller: widget.tipoPapelController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= MEDIDAS / PESO ====================
            Row(
              children: [
                const SizedBox(
                  width: 180,
                  child: Text("Medidas Papel a Comprar (cm):"),
                ),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: widget.anchoPapelController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text("X"),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: widget.largoPapelController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                const SizedBox(width: 120, child: Text("Peso del Papel (g):")),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: widget.pesoPapelController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= PROVEEDOR ====================
            Row(
              children: [
                const SizedBox(width: 150, child: Text("Proveedor del Papel:")),
                Expanded(
                  child: TextField(
                    controller: widget.proveedorPapelController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= COSTO POR MILLAR Y TOTAL PLIEGOS ====================
            Row(
              children: [
                const SizedBox(
                  width: 170,
                  child: Text("Costo por Millar del Papel:"),
                ),
                const Text("\$"),
                const SizedBox(width: 6),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: widget.costoMillarController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: widget.totalPliegosController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Total Pliegos",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
