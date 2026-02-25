import 'package:flutter/material.dart';
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
  final bool offset;
  final ValueChanged<bool> onOffsetChanged;
  final bool suaje;
  final ValueChanged<bool> onSuajeChanged;
  final VoidCallback onCalcular;
  final bool barnizUV;
  final ValueChanged<bool?> onBarnizUVChanged;
  final bool barnizUVPortada;
  final ValueChanged<bool?> onBarnizUVPortadaChanged;
  final bool laminadosActivo;
  final ValueChanged<bool?> onLaminadosChanged;
  final bool laminadosPortada;
  final ValueChanged<bool?> onLaminadosPortadaChanged;
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
  // ===== PORTADA =====
  final bool portada;
  final ValueChanged<bool?> onPortadaChanged;
  final TextEditingController anchoPortadaController;
  final TextEditingController altoPortadaController;
  final TextEditingController medianilPortadaController;
  final TextEditingController anchoFinalPortadaController;
  final TextEditingController altoFinalPortadaController;
  final TextEditingController piezasPortadaController;
  final VoidCallback onCalcularPortada;
  // ===== PRUEBA COLOR PORTADA =====
  final bool pruebaColorPortada;
  final bool pruebaColorPortadaCarta;
  final bool pruebaColorPortadaTabloide;
  final bool pruebaColorPortadaMediaCarta;

  final ValueChanged<bool?> onPruebaColorPortadaChanged;
  final ValueChanged<bool?> onPruebaColorPortadaTabloideChanged;
  final ValueChanged<bool?> onPruebaColorPortadaMediaCartaChanged;
  final TextEditingController cantidadPruebaPortadaCartaController;
  final TextEditingController precioPruebaPortadaCartaController;
  final TextEditingController totalPruebaPortadaCartaController;
  final TextEditingController cantidadPruebaPortadaTabloideController;
  final TextEditingController precioPruebaPortadaTabloideController;
  final TextEditingController totalPruebaPortadaTabloideController;
  final TextEditingController cantidadPruebaPortadaMediaCartaController;
  final TextEditingController precioPruebaPortadaMediaCartaController;
  final TextEditingController totalPruebaPortadaMediaCartaController;
  final ValueChanged<bool?>? onPruebaColorPortadaCartaChanged;

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
    required this.offset,
    required this.onOffsetChanged,
    required this.suaje,
    required this.onSuajeChanged,
    required this.onCalcular,
    required this.portada,
    required this.onPortadaChanged,
    required this.anchoPortadaController,
    required this.altoPortadaController,
    required this.medianilPortadaController,
    required this.anchoFinalPortadaController,
    required this.altoFinalPortadaController,
    required this.piezasPortadaController,
    required this.onCalcularPortada,
    required this.pruebaColorPortada,
    required this.onPruebaColorPortadaChanged,
    required this.onPruebaColorPortadaTabloideChanged,
    required this.onPruebaColorPortadaMediaCartaChanged,
    required this.paginasInternasTotalesController,
    required this.barnizUV,
    required this.onBarnizUVChanged,
    required this.barnizUVPortada,
    required this.onBarnizUVPortadaChanged,
    required this.laminadosActivo,
    required this.onLaminadosChanged,
    required this.laminadosPortada,
    required this.onLaminadosPortadaChanged,
    required this.pruebaCarta,
    required this.pruebaTabloide,
    required this.pruebaMediaCarta,
    required this.cantidadCartaController,
    required this.precioCartaController,
    required this.totalCartaController,
    required this.cantidadTabloideController,
    required this.precioTabloideController,
    required this.totalTabloideController,
    required this.cantidadMediaCartaController,
    required this.precioMediaCartaController,
    required this.totalMediaCartaController,
    required this.onPruebaCartaChanged,
    required this.onPruebaTabloideChanged,
    required this.onPruebaMediaCartaChanged,
    required this.cantidadPruebaPortadaCartaController,
    required this.precioPruebaPortadaCartaController,
    required this.totalPruebaPortadaCartaController,
    required this.cantidadPruebaPortadaTabloideController,
    required this.precioPruebaPortadaTabloideController,
    required this.totalPruebaPortadaTabloideController,
    required this.cantidadPruebaPortadaMediaCartaController,
    required this.precioPruebaPortadaMediaCartaController,
    required this.totalPruebaPortadaMediaCartaController,
    required this.onPruebaColorPortadaCartaChanged,
    required this.pruebaColorPortadaCarta,
    required this.pruebaColorPortadaTabloide,
    required this.pruebaColorPortadaMediaCarta,



  });

  @override
  ConsumerState<PanelClientes> createState() => _PanelClientesState();
}

class _PanelClientesState extends ConsumerState<PanelClientes> {
  bool prePrensa = false;
  bool serigrafia = false;
  bool grabado = false;
  bool acabado = false;
  bool corte = false;
  


  final TextEditingController paginasInternasPorPiezaController =
      TextEditingController();

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

  void _calcularPaginasInternas() {
    final piezas = int.tryParse(widget.cantidadImpresionController.text) ?? 0;
    final paginas = int.tryParse(paginasInternasPorPiezaController.text) ?? 0;

    widget.paginasInternasTotalesController.text = (piezas * paginas)
        .toString();
  }

  @override
  void dispose() {
    paginasInternasPorPiezaController.dispose();
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
            const TextField(
              decoration: InputDecoration(
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
              title: const Text("Suaje"),
              value: widget.suaje,
              onChanged: (v) => widget.onSuajeChanged(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Laminado"),
              value: widget.laminadosActivo,
              onChanged: widget.onLaminadosChanged,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Acabados Especiales"),
              value: widget.acabadosEspeciales,
              onChanged: widget.onAcabadosEspecialesChanged,
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
            const Text("Piezas totales solicitadas"),

            SizedBox(
              width: 180,
              child: TextField(
                controller: widget.cantidadImpresionController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calcularPaginasInternas(),
                decoration: const InputDecoration(labelText: "Piezas"),
              ),
            ),

            if (widget.portada) ...[
              const SizedBox(height: 8),

              SizedBox(
                width: 260,
                child: TextField(
                  controller: paginasInternasPorPiezaController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calcularPaginasInternas(),
                  decoration: const InputDecoration(
                    labelText: "Páginas internas por pieza",
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: 260,
                child: TextField(
                  controller: widget.paginasInternasTotalesController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Páginas internas totales",
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                ),
              ),
            ],

            /// =======================
            /// PORTADA
            /// =======================
            if (widget.offset) ...[
              const Divider(),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Portada",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: widget.portada,
                onChanged: widget.onPortadaChanged,
              ),
              if (widget.portada)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Barniz UV (Portada)"),
                  value: widget.barnizUVPortada,
                  onChanged: widget.onBarnizUVPortadaChanged,
                ),
              if (widget.portada)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Laminado (Portada)"),
                  value: widget.laminadosPortada,
                  onChanged: widget.onLaminadosPortadaChanged,
                ),

              if (widget.portada) ...[
                const Text(
                  "PORTADA – Medidas (cm)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.anchoPortadaController,
                        decoration: const InputDecoration(labelText: "Ancho"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.altoPortadaController,
                        decoration: const InputDecoration(labelText: "Alto"),
                      ),
                    ),
                  ],
                ),

                TextField(
                  controller: widget.medianilPortadaController,
                  decoration: const InputDecoration(labelText: "Medianil"),
                ),

                ElevatedButton(
                  onPressed: widget.onCalcularPortada,
                  child: const Text("Calcular medidas finales"),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.anchoFinalPortadaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Ancho Final",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.altoFinalPortadaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Alto Final",
                        ),
                      ),
                    ),
                  ],
                ),

                CheckboxListTile(
                  title: const Text("Prueba de Color (Portada)"),
                  value: widget.pruebaColorPortada,
                  onChanged: widget.onPruebaColorPortadaChanged,
                ),

                if (widget.pruebaColorPortada) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      children: [
                        /// ===== CARTA =====
                        CheckboxListTile(
                          title: const Text("Prueba Carta"),
                          value: widget.pruebaColorPortadaCarta,
                          onChanged: widget.onPruebaColorPortadaCartaChanged,
                        ),

                        if (widget.pruebaColorPortadaCarta)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .cantidadPruebaPortadaCartaController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Cantidad",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller:
                                      widget.precioPruebaPortadaCartaController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Costo",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller:
                                      widget.totalPruebaPortadaCartaController,
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
                          title: const Text("Prueba Tabloide"),
                          value: widget.pruebaColorPortadaTabloide,
                          onChanged: widget.onPruebaColorPortadaTabloideChanged,
                        ),

                        if (widget.pruebaColorPortadaTabloide)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .cantidadPruebaPortadaTabloideController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Cantidad",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .precioPruebaPortadaTabloideController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Costo",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .totalPruebaPortadaTabloideController,
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
                          title: const Text("Prueba Media Carta"),
                          value: widget.pruebaColorPortadaMediaCarta,
                          onChanged:
                              widget.onPruebaColorPortadaMediaCartaChanged,
                        ),

                        if (widget.pruebaColorPortadaMediaCarta)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .cantidadPruebaPortadaMediaCartaController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Cantidad",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .precioPruebaPortadaMediaCartaController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Costo",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: widget
                                      .totalPruebaPortadaMediaCartaController,
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
                ],

                TextField(
                  controller: widget.piezasPortadaController,
                  decoration: const InputDecoration(
                    labelText: "Piezas Totales Portada",
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
