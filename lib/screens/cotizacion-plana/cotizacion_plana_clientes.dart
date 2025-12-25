import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cliente_provider.dart';
import '../modals/modal_cliente.dart';
import 'buscador_cliente.dart';

class PanelClientes extends ConsumerStatefulWidget {
  final TextEditingController razonSocialController;
  final TextEditingController descripcionController;

  final TextEditingController cantidadImpresionController;
  final TextEditingController anchoController;
  final TextEditingController altoController;
  final TextEditingController medianilController;
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;

  final bool suaje;
  final ValueChanged<bool> onSuajeChanged;
  final VoidCallback onCalcular;

  const PanelClientes({
    super.key,
    required this.razonSocialController,
    required this.descripcionController,
    required this.cantidadImpresionController,
    required this.anchoController,
    required this.altoController,
    required this.medianilController,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.suaje,
    required this.onSuajeChanged,
    required this.onCalcular,
  });

  @override
  ConsumerState<PanelClientes> createState() => _PanelClientesState();
}

class _PanelClientesState extends ConsumerState<PanelClientes> {
  /// Estado SOLO para Prueba de Color
  bool pruebaColor = false;

  final TextEditingController porcentajePruebaController =
      TextEditingController();
  final TextEditingController costoPruebaController = TextEditingController();

  void _buscarCliente() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorCliente(
        onSeleccionado: (cliente) {
          widget.razonSocialController.text = cliente.razonSocial;
        },
      ),
    );
  }

  void _agregarCliente(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ModalCliente(
        titulo: 'Nuevo Cliente',
        onGuardar: (clienteNuevo) async {
          final success = await ref
              .read(clientesProvider.notifier)
              .crearCliente(clienteNuevo);
          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Cliente creado')));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    porcentajePruebaController.dispose();
    costoPruebaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Datos del Cliente y del Trabajo Solicitado",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// Razón social
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: widget.razonSocialController,
                    decoration: const InputDecoration(
                      labelText: "Razón Social Cliente",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _buscarCliente,
                  icon: const Icon(Icons.search),
                  tooltip: "Buscar cliente",
                ),
                IconButton(
                  onPressed: () => _agregarCliente(context, ref),
                  icon: const Icon(Icons.add),
                  tooltip: "Crear cliente",
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Tipo trabajo
            TextField(
              decoration: const InputDecoration(
                labelText: "Tipo Trabajo",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 8),

            /// Descripción
            TextField(
              controller: widget.descripcionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Descripción del Trabajo",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 10),

            /// Medidas
            const Text("Medidas del Trabajo (cm):"),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.anchoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Ancho",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("X"),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.altoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Alto",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Medianil
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: widget.medianilController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Medianil (cm)",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.onCalcular,
                  child: const Text("Calcular medidas finales"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Medidas finales
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.anchoFinalController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Ancho Final",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("X"),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.altoFinalController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Alto Final",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Suaje
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Suaje"),
              value: widget.suaje,
              onChanged: (v) => widget.onSuajeChanged(v ?? false),
            ),

            const SizedBox(height: 8),

            /// Cantidad impresión
            const Text("Cantidad Impresiones Pedidas por el Cliente:"),
            const SizedBox(height: 6),
            SizedBox(
              width: 180,
              child: TextField(
                controller: widget.cantidadImpresionController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// PRUEBA DE COLOR (ÚNICO ACABADO AQUÍ)
            const Text(
              "Prueba de Color",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            CheckboxListTile(
              title: const Text("Aplicar Prueba de Color"),
              value: pruebaColor,
              onChanged: (v) {
                setState(() {
                  pruebaColor = v ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (pruebaColor)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: porcentajePruebaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "% Prueba Color",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: costoPruebaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Costo Prueba Color \$",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
