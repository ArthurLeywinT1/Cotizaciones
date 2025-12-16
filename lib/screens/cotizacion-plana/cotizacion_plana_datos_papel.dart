import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/proveedor_provider.dart';
import 'buscador_papel.dart';

class PanelDatosPapel extends ConsumerStatefulWidget {
  final TextEditingController nombrePapelController;
  final TextEditingController tipoPapelController;
  final TextEditingController anchoPapelController;
  final TextEditingController largoPapelController;
  final TextEditingController pesoPapelController;
  final TextEditingController proveedorPapelController;
  final TextEditingController costoMillarController;
  final TextEditingController totalPliegosController;

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
  });

  @override
  ConsumerState<PanelDatosPapel> createState() => _PanelDatosPapelState();
}

class _PanelDatosPapelState extends ConsumerState<PanelDatosPapel> {
  void _buscarPapel() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorPapel(
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
                Expanded(
                  child: TextField(
                    controller: widget.nombrePapelController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Nombre Papel",
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
                  tooltip: "Buscar papel en catálogo",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= TIPO PAPEL ====================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.tipoPapelController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Tipo Papel",
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
                Expanded(
                  child: TextField(
                    controller: widget.proveedorPapelController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Proveedor del Papel",
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

            // ================= COSTO POR MILLAR ====================
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
