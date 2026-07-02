// panel_datos_papel_pliego.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Ajusta estas importaciones a las rutas reales de tu proyecto:
import '../../providers/papel_provider.dart';
import '../../providers/proveedor_provider.dart';
import '../modals/modal_papel.dart';
import '../cotizacion-plana/buscador_papel.dart';

class PanelDatosPapelPliego extends ConsumerStatefulWidget {
  // Los controladores que le pertenecen al mapa del pliego padre
  final TextEditingController nombrePapelController;
  final TextEditingController tipoPapelController;
  final TextEditingController anchoPapelController;
  final TextEditingController largoPapelController;
  final TextEditingController pesoPapelController;
  final TextEditingController proveedorPapelController;
  final TextEditingController costoMillarController;
  final TextEditingController totalPliegosController;

  // Medidas calculadas dinámicamente en la tarjeta del padre
  final double minAnchoRequerido;
  final double minAltoRequerido;

  const PanelDatosPapelPliego({
    super.key,
    required this.nombrePapelController,
    required this.tipoPapelController,
    required this.anchoPapelController,
    required this.largoPapelController,
    required this.pesoPapelController,
    required this.proveedorPapelController,
    required this.costoMillarController,
    required this.totalPliegosController,
    required this.minAnchoRequerido,
    required this.minAltoRequerido,
  });

  @override
  ConsumerState<PanelDatosPapelPliego> createState() => _PanelDatosPapelPliegoState();
}

class _PanelDatosPapelPliegoState extends ConsumerState<PanelDatosPapelPliego> {
  void _buscarPapel() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorPapel(
        minAncho: widget.minAnchoRequerido,
        minLargo: widget.minAltoRequerido,
        onSeleccionado: (papel) {
          // Escribimos directamente en los controladores del padre
          widget.nombrePapelController.text = papel.nombre;
          widget.tipoPapelController.text = papel.tipo ?? '';
          widget.anchoPapelController.text = papel.ancho?.toString() ?? '0';
          widget.largoPapelController.text = papel.largo?.toString() ?? '0';
          widget.pesoPapelController.text = papel.peso?.toString() ?? '0';
          widget.costoMillarController.text = papel.costoMillar.toString();

          if (papel.proveedorId != null) {
            final proveedores = ref.read(proveedoresProvider).proveedores;
            try {
              final proveedor = proveedores.firstWhere((p) => p.id == papel.proveedorId);
              widget.proveedorPapelController.text = proveedor.razonSocial;
            } catch (e) {
              widget.proveedorPapelController.text = "No encontrado";
            }
          } else {
            widget.proveedorPapelController.text = "";
          }
        },
      ),
    );
  }

  void _agregarPapel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ModalPapel(
        titulo: 'Nuevo Papel',
        listaProveedores: ref.read(proveedoresProvider).proveedores,
        onGuardar: (papelNuevo) async {
          final success = await ref.read(papelesProvider.notifier).crearPapel(papelNuevo);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Papel creado con éxito')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Especificaciones de Papel (Pliego)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
          ),
          const SizedBox(height: 14),
          
          // Fila Nombre + Buscador
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.nombrePapelController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Papel Seleccionado', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              IconButton(icon: const Icon(Icons.search, size: 22), onPressed: _buscarPapel),
              IconButton(icon: const Icon(Icons.add, size: 22), onPressed: () => _agregarPapel(context, ref)),
            ],
          ),
          const SizedBox(height: 12),

          // Tipo de Papel
          TextFormField(
            controller: widget.tipoPapelController,
            readOnly: true,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Tipo de Papel', border: OutlineInputBorder(), isDense: true),
          ),
          const SizedBox(height: 12),

          // Medidas y peso en una sola fila compacta
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.anchoPapelController,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'Ancho (cm)', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("x")),
              Expanded(
                child: TextFormField(
                  controller: widget.largoPapelController,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'Largo (cm)', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.pesoPapelController,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'Peso (g)', border: OutlineInputBorder(), isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Proveedor
          TextFormField(
            controller: widget.proveedorPapelController,
            readOnly: true,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder(), isDense: true),
          ),
          const SizedBox(height: 12),

          // Costo y total pliegos asignados
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.costoMillarController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Costo x Millar \$', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.totalPliegosController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Cant. Pliegos Papel', border: OutlineInputBorder(), isDense: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}