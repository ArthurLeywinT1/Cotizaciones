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
  final ValueChanged<bool?> onPruebaColorPortadaChanged;
  final TextEditingController porcentajePruebaPortadaController;
  final TextEditingController costoPruebaPortadaController;
  final TextEditingController paginasInternasTotalesController;


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
    required this.porcentajePruebaPortadaController,
    required this.costoPruebaPortadaController,
    required this.paginasInternasTotalesController,
    required this.barnizUV,
    required this.onBarnizUVChanged,
    required this.barnizUVPortada,
    required this.onBarnizUVPortadaChanged,
    required this.laminadosActivo,
    required this.onLaminadosChanged,
    required this.laminadosPortada,
    required this.onLaminadosPortadaChanged,
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
  bool pruebaColor = false;
  

  final TextEditingController porcentajePruebaController =
      TextEditingController();
  final TextEditingController costoPruebaController =
      TextEditingController();
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
          await ref
              .read(clientesProvider.notifier)
              .crearCliente(clienteNuevo);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _calcularPaginasInternas() {
    final piezas =
        int.tryParse(widget.cantidadImpresionController.text) ?? 0;
    final paginas =
        int.tryParse(paginasInternasPorPiezaController.text) ?? 0;

    widget.paginasInternasTotalesController.text =
      (piezas * paginas).toString();

  }

  @override
  void dispose() {
    porcentajePruebaController.dispose();
    costoPruebaController.dispose();
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
              title: const Text("Pre Prensa"),
              value: prePrensa,
              onChanged: (v) => setState(() => prePrensa = v ?? false),
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
              title: const Text("Serigrafía"),
              value: serigrafia,
              onChanged: (v) => setState(() => serigrafia = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Grabado"),
              value: grabado,
              onChanged: (v) => setState(() => grabado = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Acabado"),
              value: acabado,
              onChanged: (v) => setState(() => acabado = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Corte"),
              value: corte,
              onChanged: (v) => setState(() => corte = v ?? false),
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
                      decoration:
                          const InputDecoration(labelText: "Ancho"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.altoController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Alto"),
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
                      decoration:
                          const InputDecoration(labelText: "Medianil"),
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
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Aplicar Prueba de Color"),
                value: pruebaColor,
                onChanged: (v) =>
                    setState(() => pruebaColor = v ?? false),
              ),

              if (pruebaColor)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: porcentajePruebaController,
                        decoration: const InputDecoration(
                          labelText: "% Prueba Color",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: costoPruebaController,
                        decoration: const InputDecoration(
                          labelText: "Costo Prueba Color \$",
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
                const Text("PORTADA – Medidas (cm)",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.anchoPortadaController,
                        decoration:
                            const InputDecoration(labelText: "Ancho"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.altoPortadaController,
                        decoration:
                            const InputDecoration(labelText: "Alto"),
                      ),
                    ),
                  ],
                ),

                TextField(
                  controller: widget.medianilPortadaController,
                  decoration:
                      const InputDecoration(labelText: "Medianil"),
                ),

                ElevatedButton(
                  onPressed: widget.onCalcularPortada,
                  child: const Text("Calcular medidas finales"),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                            widget.anchoFinalPortadaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: "Ancho Final"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.altoFinalPortadaController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: "Alto Final"),
                      ),
                    ),
                  ],
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title:
                      const Text("Aplicar Prueba de Color (Portada)"),
                  value: widget.pruebaColorPortada,
                  onChanged:
                      widget.onPruebaColorPortadaChanged,
                ),

                if (widget.pruebaColorPortada)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget
                              .porcentajePruebaPortadaController,
                          decoration: const InputDecoration(
                              labelText: "% Prueba Color"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: widget
                              .costoPruebaPortadaController,
                          decoration: const InputDecoration(
                              labelText:
                                  "Costo Prueba Color \$"),
                        ),
                      ),
                    ],
                  ),

                TextField(
                  controller: widget.piezasPortadaController,
                  decoration: const InputDecoration(
                      labelText: "Piezas Totales Portada"),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
