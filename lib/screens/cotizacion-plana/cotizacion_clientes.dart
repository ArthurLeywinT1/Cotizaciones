import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cliente_provider.dart';
import '../modals/modal_cliente.dart';
import 'buscador_cliente.dart';

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
  final bool extras;
  final ValueChanged<bool?> onExtrasChanged;

  const PanelClientes({
    super.key,
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
    required this.extras,
    required this.onExtrasChanged,
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
  bool _medidasOffsetExpandido = true;

  @override
  void initState() {
    super.initState();
    if (widget.medianilController.text.isEmpty) {
      widget.medianilController.text = "0.5";
    }
    widget.anchoController.addListener(_autoCalcularMedidas);
    widget.altoController.addListener(_autoCalcularMedidas);
    widget.medianilController.addListener(_autoCalcularMedidas);

    WidgetsBinding.instance.addPostFrameCallback((_) => _autoCalcularMedidas());
  }

  @override
  void dispose() {
    widget.anchoController.removeListener(_autoCalcularMedidas);
    widget.altoController.removeListener(_autoCalcularMedidas);
    widget.medianilController.removeListener(_autoCalcularMedidas);
    super.dispose();
  }

  void _autoCalcularMedidas() {
    final double ancho = double.tryParse(widget.anchoController.text) ?? 0.0;
    final double alto = double.tryParse(widget.altoController.text) ?? 0.0;
    final double medianil =
        double.tryParse(widget.medianilController.text) ?? 0.0;

    final String nuevoAnchoFinal =
        ancho > 0 ? (ancho + medianil).toStringAsFixed(2) : "0.00";
    final String nuevoAltoFinal =
        alto > 0 ? (alto + medianil).toStringAsFixed(2) : "0.00";

    if (widget.anchoFinalController.text != nuevoAnchoFinal) {
      widget.anchoFinalController.text = nuevoAnchoFinal;
    }
    if (widget.altoFinalController.text != nuevoAltoFinal) {
      widget.altoFinalController.text = nuevoAltoFinal;
    }
    if (mounted) setState(() {});
  }

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

  Widget _buildCheckboxProceso({
    required String titulo,
    required bool valor,
    required Color color,
    required IconData icono,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: valor ? color.withOpacity(0.18) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: valor ? color : color.withOpacity(0.55),
          width: valor ? 2.0 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onChanged(!valor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icono, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: valor ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Checkbox(
                  value: valor,
                  activeColor: color,
                  checkColor: Colors.white,
                  side: BorderSide(color: color, width: 2),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color colorOffset = Color(0xFF1976D2);

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

            TextField(
              controller: widget.proyectoController,
              decoration: const InputDecoration(
                labelText: "Proyecto",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: widget.descripcionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Descripción del Proyecto",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Procesos del Trabajo",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            _buildCheckboxProceso(
              titulo: "Offset",
              valor: widget.offset,
              color: const Color(0xFF1976D2),
              icono: Icons.print,
              onChanged: (v) => widget.onOffsetChanged(v ?? false),
            ),
            _buildCheckboxProceso(
              titulo: "Barniz UV",
              valor: widget.barnizUV,
              color: const Color(0xFF7B1FA2),
              icono: Icons.auto_awesome,
              onChanged: widget.onBarnizUVChanged,
            ),
            _buildCheckboxProceso(
              titulo: "Acabados Especiales",
              valor: widget.acabadosEspeciales,
              color: const Color(0xFF303F9F),
              icono: Icons.star_border,
              onChanged: widget.onAcabadosEspecialesChanged,
            ),
            _buildCheckboxProceso(
              titulo: "Extras",
              valor: widget.extras,
              color: const Color(0xFF00838F),
              icono: Icons.add_circle_outline,
              onChanged: widget.onExtrasChanged,
            ),
            _buildCheckboxProceso(
              titulo: "Suaje",
              valor: widget.suaje,
              color: const Color(0xFFEF6C00),
              icono: Icons.content_cut,
              onChanged: (v) => widget.onSuajeChanged(v ?? false),
            ),
            _buildCheckboxProceso(
              titulo: "Plastificado/Laminado",
              valor: widget.laminadosActivo,
              color: const Color(0xFF00796B),
              icono: Icons.layers,
              onChanged: widget.onLaminadosChanged,
            ),
            _buildCheckboxProceso(
              titulo: "Serigrafía",
              valor: widget.serigrafia,
              color: const Color(0xFFC2185B),
              icono: Icons.format_paint,
              onChanged: (v) => widget.onSerigrafiaChanged(v ?? false),
            ),
            _buildCheckboxProceso(
              titulo: "Grabado",
              valor: widget.grabado,
              color: const Color(0xFF5D4037),
              icono: Icons.vignette,
              onChanged: (v) => widget.onGrabadoChanged(v ?? false),
            ),
            _buildCheckboxProceso(
              titulo: "Embalaje",
              valor: widget.embalaje,
              color: const Color(0xFF388E3C),
              icono: Icons.inventory_2,
              onChanged: (v) => widget.onEmbalajeChanged(v ?? false),
            ),

            if (widget.offset) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorOffset, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _medidasOffsetExpandido = !_medidasOffsetExpandido;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorOffset,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(6),
                            topRight: const Radius.circular(6),
                            bottomLeft: Radius.circular(
                              _medidasOffsetExpandido ? 0 : 6,
                            ),
                            bottomRight: Radius.circular(
                              _medidasOffsetExpandido ? 0 : 6,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Offset: Medidas del Trabajo y Pruebas de Color",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              _medidasOffsetExpandido
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _medidasOffsetExpandido,
                      maintainState: true,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Medidas del Trabajo (cm)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: widget.anchoController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: "Ancho",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: widget.altoController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: "Alto",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: widget.medianilController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: "Medianil",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                "Medida Final (con medianil): ${widget.anchoFinalController.text} cm  x  ${widget.altoFinalController.text} cm",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            const Divider(),
                            const Text(
                              "Pruebas de Color (Internas)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

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
                                      controller:
                                          widget.cantidadCartaController,
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
                                      controller:
                                          widget.cantidadTabloideController,
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
                                      controller:
                                          widget.precioTabloideController,
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
                                      controller:
                                          widget.totalTabloideController,
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
                                      controller:
                                          widget.cantidadMediaCartaController,
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
                                      controller:
                                          widget.precioMediaCartaController,
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
                                      controller:
                                          widget.totalMediaCartaController,
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
                        ),
                      ),
                    ),
                  ],
                ),
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