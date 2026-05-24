import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cliente_provider.dart';
import '../modals/modal_cliente.dart';
import 'buscador_cliente.dart';

// Panel específico para el ingreso de datos del cliente y detalles del trabajo solicitado en la cotización plana
class PanelClientes extends ConsumerStatefulWidget {
  final TextEditingController razonSocialController;
  final ValueChanged<String> onClienteIdSeleccionado;
  final TextEditingController proyectoController;
  final TextEditingController descripcionController;
  final TextEditingController cantidadImpresionController;
  final TextEditingController anchoController;
  final TextEditingController altoController;
  final TextEditingController medianilController;
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;
  final bool offset;
  final ValueChanged<bool> onOffsetChanged;
  final bool suaje;
  final ValueChanged<bool> onSuajeChanged;
  final VoidCallback onCalcular;
  final bool barnizUV;
  final ValueChanged<bool?> onBarnizUVChanged;
  final bool laminadosActivo;
  final ValueChanged<bool?> onLaminadosChanged;
  final bool pruebaCarta;
  final bool pruebaTabloide;
  final bool pruebaMediaCarta;
  final TextEditingController cantidadCartaController;
  final TextEditingController precioCartaController;
  final TextEditingController totalCartaController;
  final TextEditingController cantidadTabloideController;
  final TextEditingController precioTabloideController;
  final TextEditingController totalTabloideController;
  final TextEditingController cantidadMediaCartaController;
  final TextEditingController precioMediaCartaController;
  final TextEditingController totalMediaCartaController;
  final ValueChanged<bool?> onPruebaCartaChanged;
  final ValueChanged<bool?> onPruebaTabloideChanged;
  final ValueChanged<bool?> onPruebaMediaCartaChanged;
  final TextEditingController paginasInternasTotalesController;
  final TextEditingController paginasInternasPorPiezaController;
  final bool prePrensa;
  final ValueChanged<bool> onPrePrensaChanged;
  final bool serigrafia;
  final ValueChanged<bool> onSerigrafiaChanged;
  final bool embalaje;
  final ValueChanged<bool> onEmbalajeChanged;
  final bool grabado;
  final ValueChanged<bool> onGrabadoChanged;
  final bool acabadosEspeciales;
  final ValueChanged<bool?> onAcabadosEspecialesChanged;

  const PanelClientes({
    required this.razonSocialController,
    required this.onClienteIdSeleccionado,
    required this.proyectoController,
    required this.descripcionController,
    required this.cantidadImpresionController,
    required this.anchoController,
    required this.altoController,
    required this.medianilController,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.paginasInternasTotalesController,
    required this.paginasInternasPorPiezaController,
    required this.prePrensa,
    required this.onPrePrensaChanged,
    required this.offset,
    required this.onOffsetChanged,
    required this.barnizUV,
    required this.onBarnizUVChanged,
    required this.suaje,
    required this.onSuajeChanged,
    required this.laminadosActivo,
    required this.onLaminadosChanged,
    required this.acabadosEspeciales,
    required this.onAcabadosEspecialesChanged,
    required this.serigrafia,
    required this.onSerigrafiaChanged,
    required this.grabado,
    required this.onGrabadoChanged,
    required this.embalaje,
    required this.onEmbalajeChanged,
    required this.onCalcular,
    required this.pruebaCarta,
    required this.onPruebaCartaChanged,
    required this.pruebaTabloide,
    required this.onPruebaTabloideChanged,
    required this.pruebaMediaCarta,
    required this.onPruebaMediaCartaChanged,
    required this.cantidadCartaController,
    required this.precioCartaController,
    required this.totalCartaController,
    required this.cantidadTabloideController,
    required this.precioTabloideController,
    required this.totalTabloideController,
    required this.cantidadMediaCartaController,
    required this.precioMediaCartaController,
    required this.totalMediaCartaController,
  });

  @override
  ConsumerState<PanelClientes> createState() => _PanelClientesState();
}

class _PanelClientesState extends ConsumerState<PanelClientes> {
  void _buscarCliente() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorCliente(
        onSeleccionado: (cliente) {
          widget.razonSocialController.text = cliente.razonSocial;
          widget.onClienteIdSeleccionado(cliente.id);
        },
      ),
    );
  }

  void _agregarCliente() {
    showDialog(
      context: context,
      builder: (_) => ModalCliente(
        titulo: 'Nuevo Cliente',
        onGuardar: (clienteNuevo) async {
          await ref.read(clientesProvider.notifier).crearCliente(clienteNuevo);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void calcularTotal(
    TextEditingController cantidadController,
    TextEditingController precioController,
    TextEditingController totalController,
  ) {
    double cantidad = double.tryParse(cantidadController.text) ?? 0;
    double precio = double.tryParse(precioController.text) ?? 0;

    double total = cantidad * precio;

    totalController.text = total.toStringAsFixed(2);
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

            /// RAZÓN SOCIAL
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: widget.razonSocialController,
                    decoration: const InputDecoration(
                      labelText: "Razón Social Cliente",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarCliente,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _agregarCliente,
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// PROYECTO
            TextField(
              controller: widget.proyectoController,
              decoration: const InputDecoration(
                labelText: "Proyecto",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            /// DESCRIPCIÓN
            TextField(
              controller: widget.descripcionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Descripción del Proyecto",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// PROCESOS
            const Text(
              "Procesos del Trabajo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Offset"),
              value: widget.offset,
              onChanged: (v) => widget.onOffsetChanged(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Barniz UV"),
              value: widget.barnizUV,
              onChanged: widget.onBarnizUVChanged,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Acabados Especiales"),
              value: widget.acabadosEspeciales,
              onChanged: widget.onAcabadosEspecialesChanged,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Suaje"),
              value: widget.suaje,
              onChanged: (v) => widget.onSuajeChanged(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Plastificado/Laminado"),
              value: widget.laminadosActivo,
              onChanged: widget.onLaminadosChanged,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Serigrafía"),
              value: widget.serigrafia,
              onChanged: (v) => widget.onSerigrafiaChanged(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Grabado"),
              value: widget.grabado,
              onChanged: (v) => widget.onGrabadoChanged(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Embalaje"),
              value: widget.embalaje,
              onChanged: (v) => widget.onEmbalajeChanged(v ?? false),
            ),

            /// MEDIDAS OFFSET
            if (widget.offset) ...[
              const SizedBox(height: 10),
              const Text("Medidas del Trabajo (cm)"),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.anchoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Ancho"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.altoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Alto"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: widget.medianilController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Medianil"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: widget.onCalcular,
                    child: const Text("Calcular medidas finales"),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// PRUEBA DE COLOR
              const Divider(),
              const Text(
                "Pruebas de Color (Internas)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              /// ===== CARTA =====
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Prueba Carta"),
                value: widget.pruebaCarta,
                onChanged: widget.onPruebaCartaChanged,
              ),

              if (widget.pruebaCarta)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.cantidadCartaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Cantidad Carta",
                        ),
                        onChanged: (value) => calcularTotal(
                          widget.cantidadCartaController,
                          widget.precioCartaController,
                          widget.totalCartaController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.precioCartaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio Carta",
                        ),
                        onChanged: (value) => calcularTotal(
                          widget.cantidadCartaController,
                          widget.precioCartaController,
                          widget.totalCartaController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.totalCartaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Total",
                          filled: true,
                          fillColor: Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                  ],
                ),

              /// ===== TABLOIDE =====
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Prueba Tabloide"),
                value: widget.pruebaTabloide,
                onChanged: widget.onPruebaTabloideChanged,
              ),

              if (widget.pruebaTabloide)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.cantidadTabloideController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Cantidad Tabloide",
                        ),
                        onChanged: (value) => calcularTotal(
                          widget.cantidadTabloideController,
                          widget.precioTabloideController,
                          widget.totalTabloideController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.precioTabloideController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio Tabloide",
                        ),
                        onChanged: (value) => calcularTotal(
                          widget.cantidadTabloideController,
                          widget.precioTabloideController,
                          widget.totalTabloideController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.totalTabloideController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Total",
                          filled: true,
                          fillColor: Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                  ],
                ),

              /// ===== MEDIA CARTA =====
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Prueba Media Carta"),
                value: widget.pruebaMediaCarta,
                onChanged: widget.onPruebaMediaCartaChanged,
              ),

              if (widget.pruebaMediaCarta)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.cantidadMediaCartaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Cantidad Media Carta",
                        ),
                        onChanged: (value) => calcularTotal(
                          widget.cantidadMediaCartaController,
                          widget.precioMediaCartaController,
                          widget.totalMediaCartaController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.precioMediaCartaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Precio Media Carta",
                        ),
                        onChanged: (value) => calcularTotal(
                          widget.cantidadMediaCartaController,
                          widget.precioMediaCartaController,
                          widget.totalMediaCartaController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: widget.totalMediaCartaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Total",
                          filled: true,
                          fillColor: Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                  ],
                ),
            ],

            const SizedBox(height: 10),

            const Text(
              "Piezas totales solicitadas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: widget.cantidadImpresionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Cantidad (Piezas)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
