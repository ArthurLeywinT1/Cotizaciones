import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RevistaPanelClientes extends StatefulWidget {
  final TextEditingController cantidadImpresionController;
  final TextEditingController tipoTrabajoController;
  final TextEditingController descripcionController;

  // ===== PÁGINAS INTERIORES - MEDIDAS =====
  final TextEditingController anchoController;
  final TextEditingController altoController;
  final TextEditingController medianilController;
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;

  // ===============================================
  // CONTROLADORES: CANTIDADES INTERIORES
  // ===============================================
  final TextEditingController multiplosImpresionController;
  final TextEditingController paginasPorPiezaController;
  final TextEditingController cantidadPiezasTotalesController;
  final TextEditingController cantidadPaginasTotalesController;

  final bool suaje;
  final ValueChanged<bool> onSuajeChanged;

  const RevistaPanelClientes({
    super.key,
    required this.cantidadImpresionController,
    required this.tipoTrabajoController,
    required this.descripcionController,
    required this.anchoController,
    required this.altoController,
    required this.medianilController,
    required this.anchoFinalController,
    required this.altoFinalController,
    
    required this.multiplosImpresionController,
    required this.paginasPorPiezaController,
    required this.cantidadPiezasTotalesController,
    required this.cantidadPaginasTotalesController,

    required this.suaje,
    required this.onSuajeChanged,
  });

  @override
  State<RevistaPanelClientes> createState() => _RevistaPanelClientesState();
}

class _RevistaPanelClientesState extends State<RevistaPanelClientes> {
  // =============================
  // ESTADOS Y LISTAS (MODIFICADOS)
  // =============================
  bool utilizarPortada = false;
  bool medianilPortada = false;
  final List<int> multiplosOptions = List<int>.generate(50, (i) => i + 1);
  late int selectedMultiplo;


  // =============================
  // CONTROLADORES PORTADA
  // =============================
  final TextEditingController anchoPortadaController =
      TextEditingController();
  final TextEditingController altoPortadaController =
      TextEditingController();
  final TextEditingController medianilPortadaController =
      TextEditingController();
  final TextEditingController anchoFinalPortadaController =
      TextEditingController();
  final TextEditingController altoFinalPortadaController =
      TextEditingController();
  final TextEditingController paginasPortadaController =
    TextEditingController(text: "0");



  // =============================
  // PRUEBA DE COLOR
  // =============================
  bool pruebaColor = false;

  int pruebaCantidad = 1;
  int pruebaPorcentaje = 100;
  final List<int> pruebaPorcentajeOptions =
      List.generate(100, (i) => i + 1);

  final TextEditingController costoPruebaColorController =
      TextEditingController();

  final List<int> pruebaCantidadOptions =
      List.generate(10, (i) => i + 1);


  // =============================
  // PRUEBA DE COLOR - PORTADA
  // =============================
  bool pruebaColorPortada = false;

  int pruebaPortadaCantidad = 1;
  int pruebaPortadaPorcentaje = 100;

  final List<int> pruebaPortadaCantidadOptions =
      List.generate(10, (i) => i + 1);

  final List<int> pruebaPortadaPorcentajeOptions =
      List.generate(100, (i) => i + 1);

  final TextEditingController costoPruebaColorPortadaController =
      TextEditingController();


      
  // =============================
  // INIT STATE
  // =============================
  @override
  void initState() {
    super.initState();
    selectedMultiplo = int.tryParse(widget.multiplosImpresionController.text) ?? 1;
  }

  // =============================
  // MÉTODOS
  // =============================
  void _buscarCliente() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Buscar Cliente"),
        content: const Text("Aquí irá la búsqueda de clientes."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _calcularInteriores() {
    final double ancho =
        double.tryParse(widget.anchoController.text) ?? 0;
    final double alto =
        double.tryParse(widget.altoController.text) ?? 0;
    final double medianil =
        double.tryParse(widget.medianilController.text) ?? 0;

    widget.anchoFinalController.text =
        (ancho + medianil).toStringAsFixed(2);
    widget.altoFinalController.text =
        (alto + medianil).toStringAsFixed(2);
  }

  void _calcularPortada() {
    final double ancho =
        double.tryParse(anchoPortadaController.text) ?? 0;
    final double alto =
        double.tryParse(altoPortadaController.text) ?? 0;
    final double medianil =
        double.tryParse(medianilPortadaController.text) ?? 0;

    final double anchoFinal =
        medianilPortada ? ancho + medianil : ancho;
    final double altoFinal =
        medianilPortada ? alto + medianil : alto;

    anchoFinalPortadaController.text =
        anchoFinal.toStringAsFixed(2);
    altoFinalPortadaController.text =
        altoFinal.toStringAsFixed(2);
  }

  @override
  void dispose() {
    // Se hace dispose de los controladores internos aquí
    costoPruebaColorController.dispose();
    costoPruebaColorPortadaController.dispose();
    paginasPortadaController.dispose();
    anchoPortadaController.dispose();
    altoPortadaController.dispose();
    medianilPortadaController.dispose();
    anchoFinalPortadaController.dispose();
    altoFinalPortadaController.dispose();
    super.dispose();

  }

  // =============================
  // UI
  // =============================
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
              "Datos del Cliente y del Trabajo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            /// Razón Social
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Razón Social Cliente",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _buscarCliente,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            /// Tipo Trabajo
            TextField(
              controller: widget.tipoTrabajoController,
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
            const Divider(),

            // =====================================================
            // PÁGINAS INTERIORES - MEDIDAS
            // =====================================================
            const Text(
              "Páginas Interiores",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.anchoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Ancho",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _calcularInteriores(),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("X"),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: widget.altoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Alto",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _calcularInteriores(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: 160,
              child: TextField(
                controller: widget.medianilController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Medianil (cm)",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => _calcularInteriores(),
              ),
            ),

            const SizedBox(height: 8),

            /// Medidas Finales
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.anchoFinalController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Ancho Final",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("X"),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: widget.altoFinalController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Alto Final",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            
            // =====================================================
            // CANTIDADES INTERIORES (MODIFICADA)
            // =====================================================
            const SizedBox(height: 12),
            
            /// Fila 1: Múltiplos (Dropdown) y Páginas por Pieza (Editable, vacío)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Multiplos en los que se hará la impresión:"),
                      const SizedBox(height: 4),
                      
                      // ✅ DROPWDOWN PARA SELECCIONAR MÚLTIPLOS (1 al 50)
                      DropdownButtonFormField<int>(
                        value: selectedMultiplo,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        ),
                        items: multiplosOptions.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedMultiplo = newValue;
                              // Actualizar controlador para que el padre (RevistaScreen) lo vea
                              widget.multiplosImpresionController.text = newValue.toString();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cantidad de Páginas Internas Por Pieza:"),
                      const SizedBox(height: 4),
                      // ✅ EDITABLE Y VACÍO (la inicialización vacía está en RevistaScreen.dart)
                      TextField(
                        controller: widget.paginasPorPiezaController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: 'Ingrese un número', // Sugerencia visual
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Fila 2: Piezas Totales (Editable, vacío) y Páginas Totales (Calculado, no editable)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cantidad de Piezas Totales:"),
                      const SizedBox(height: 4),
                      // ✅ EDITABLE Y VACÍO (la inicialización vacía está en RevistaScreen.dart)
                      TextField(
                        controller: widget.cantidadPiezasTotalesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          hintText: 'Ingrese un número', // Sugerencia visual
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cantidad de Páginas Internas Totales:"),
                      const SizedBox(height: 4),
                      // ✅ CALCULADO Y NO MODIFICABLE
                      TextField(
                        controller: widget.cantidadPaginasTotalesController,
                        keyboardType: TextInputType.number,
                        enabled: false, 
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)
                        ),
                      ),
                    ],
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

            // =====================================================
            // PRUEBA DE COLOR
            // =====================================================
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Prueba de color"),
              value: pruebaColor,
              onChanged: (v) {
                setState(() {
                  pruebaColor = v ?? false;
                  if (!pruebaColor) {
                    costoPruebaColorController.clear();
                    pruebaCantidad = 1;
                    pruebaPorcentaje = 1;
                  }
                });
              },
            ),

            if (pruebaColor) ...[
              const SizedBox(height: 8),

              Row(
                children: [
                  // Cantidad de pruebas (1 - 10)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Cantidad de pruebas"),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<int>(
                          value: pruebaCantidad,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: pruebaCantidadOptions.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text('$e'),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => pruebaCantidad = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Personajes (1 - 100)
                  // Porcentaje (1% - 100%)
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Porcentaje"),
      const SizedBox(height: 4),
      DropdownButtonFormField<int>(
        value: pruebaPorcentaje,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: pruebaPorcentajeOptions.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text('$e %'),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => pruebaPorcentaje = v);
          }
        },
      ),
    ],
  ),
),

                ],
              ),

              const SizedBox(height: 8),

              // Costo de la prueba de color
              SizedBox(
                width: 200,
                child: TextField(
                  controller: costoPruebaColorController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Costo prueba de color",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],


            const Divider(),
            
            // =====================================================
            // PORTADA
            // =====================================================
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Utilizar Portada"),
              value: utilizarPortada,
              onChanged: (v) {
                setState(() {
                  utilizarPortada = v ?? false;
                  if (!utilizarPortada) {
                      anchoPortadaController.clear();
                      altoPortadaController.clear();
                      medianilPortadaController.clear();
                      anchoFinalPortadaController.clear();
                      altoFinalPortadaController.clear();
                      medianilPortada = false;
                  }
                });
              },
            ),
            
            /// Campos de Portada (Condicionales)
            if (utilizarPortada) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: anchoPortadaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Ancho Portada",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _calcularPortada(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text("X"),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: altoPortadaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Alto Portada",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _calcularPortada(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: medianilPortada,
                    onChanged: (v) {
                      setState(() {
                        medianilPortada = v ?? false;
                        _calcularPortada();
                      });
                    },
                  ),
                  const Text("Medianil"),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: medianilPortadaController,
                      enabled: medianilPortada,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: "Medianil Portada",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => _calcularPortada(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: anchoFinalPortadaController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Ancho Final",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text("X"),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: altoFinalPortadaController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Alto Final",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 250,
                child: TextField(
                controller: paginasPortadaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                    ],
                  decoration: const InputDecoration(
                  labelText: "Cantidad total de páginas de portada",
                  border: OutlineInputBorder(),
                  isDense: true,
                    ),
                ),
              ),
              const Divider(),

const Text(
  "Prueba de color - Portada",
  style: TextStyle(fontWeight: FontWeight.bold),
),

CheckboxListTile(
  contentPadding: EdgeInsets.zero,
  title: const Text("Prueba de color en portada"),
  value: pruebaColorPortada,
  onChanged: (v) {
    setState(() {
      pruebaColorPortada = v ?? false;
      if (!pruebaColorPortada) {
        costoPruebaColorPortadaController.clear();
        pruebaPortadaCantidad = 1;
        pruebaPortadaPorcentaje = 100;
      }
    });
  },
),

if (pruebaColorPortada) ...[
  const SizedBox(height: 8),

  Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cantidad de pruebas"),
            const SizedBox(height: 4),
            DropdownButtonFormField<int>(
              value: pruebaPortadaCantidad,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: pruebaPortadaCantidadOptions.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text('$e'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => pruebaPortadaCantidad = v);
                }
              },
            ),
          ],
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Porcentaje"),
            const SizedBox(height: 4),
            DropdownButtonFormField<int>(
              value: pruebaPortadaPorcentaje,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: pruebaPortadaPorcentajeOptions.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text('$e %'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => pruebaPortadaPorcentaje = v);
                }
              },
            ),
          ],
        ),
      ),
    ],
  ),

  const SizedBox(height: 8),

  SizedBox(
    width: 220,
    child: TextField(
      controller: costoPruebaColorPortadaController,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d*\.?\d{0,2}$'),
        ),
      ],
      decoration: const InputDecoration(
        labelText: "Costo prueba de color (Portada)",
        border: OutlineInputBorder(),
        isDense: true,
      ),
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