import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/extra_provider.dart';

class PanelSuaje extends ConsumerStatefulWidget {
  final bool enabled;
  final TextEditingController tamanoSuajeController;
  final TextEditingController costoSuajeCmController;
  final TextEditingController costoTotalSuajeController;
  final TextEditingController costoArregloSuajeController;
  final TextEditingController costoTotalSuajadoController;
  final TextEditingController anchoSuajeController;
  final TextEditingController largoSuajeController;
  final bool seCuentaConSuaje;
  final ValueChanged<bool?> onSeCuentaConSuajeChanged;
  final TextEditingController pliegosSuajeController;
  final TextEditingController costoMillarSuajeController;
  final VoidCallback? onChanged; // Callback para actualización inmediata en el padre

  const PanelSuaje({
    super.key,
    required this.enabled,
    required this.tamanoSuajeController,
    required this.costoSuajeCmController,
    required this.costoTotalSuajeController,
    required this.costoArregloSuajeController,
    required this.costoTotalSuajadoController,
    required this.anchoSuajeController,
    required this.largoSuajeController,
    required this.seCuentaConSuaje,
    required this.onSeCuentaConSuajeChanged,
    required this.pliegosSuajeController,
    required this.costoMillarSuajeController,
    this.onChanged,
  });

  @override
  ConsumerState<PanelSuaje> createState() => _PanelSuajeState();
}

class _PanelSuajeState extends ConsumerState<PanelSuaje> {
  // Controladores para las 3 opciones dinámicas
  final TextEditingController _opcion1Base = TextEditingController(text: "20");
  final TextEditingController _opcion1Multiplicador = TextEditingController(text: "8");
  
  final TextEditingController _opcion2Base = TextEditingController(text: "15");
  final TextEditingController _opcion2Multiplicador = TextEditingController(text: "4");
  
  final TextEditingController _opcion3Base = TextEditingController(text: "12");
  final TextEditingController _opcion3Multiplicador = TextEditingController(text: "2");

  bool _mostrarPestanaOpciones = false;
  bool _ocultarLargoField = true; // Inicia en true para ocultar "Alto" desde el principio

  @override
  void initState() {
    super.initState();
    widget.tamanoSuajeController.addListener(_calcularTotales);
    widget.costoSuajeCmController.addListener(_calcularTotales);
    widget.costoArregloSuajeController.addListener(_calcularTotales);
    widget.pliegosSuajeController.addListener(_calcularTotales);
    widget.costoMillarSuajeController.addListener(_calcularTotales);
    widget.anchoSuajeController.addListener(_calcularTotales);
    widget.largoSuajeController.addListener(_calcularTotales);

    // Inicializamos el primer cuadro con la suma por defecto si entra vacío
    if (widget.anchoSuajeController.text.isEmpty) {
      _calcularSumaInicialSilenciosa();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarCostosBD());
  }

  @override
  void dispose() {
    widget.tamanoSuajeController.removeListener(_calcularTotales);
    widget.costoSuajeCmController.removeListener(_calcularTotales);
    widget.costoArregloSuajeController.removeListener(_calcularTotales);
    widget.pliegosSuajeController.removeListener(_calcularTotales);
    widget.costoMillarSuajeController.removeListener(_calcularTotales);
    widget.anchoSuajeController.removeListener(_calcularTotales);
    widget.largoSuajeController.removeListener(_calcularTotales);

    _opcion1Base.dispose();
    _opcion1Multiplicador.dispose();
    _opcion2Base.dispose();
    _opcion2Multiplicador.dispose();
    _opcion3Base.dispose();
    _opcion3Multiplicador.dispose();
    super.dispose();
  }

  // Realiza la suma predeterminada al arrancar para que el campo no inicie en blanco
  void _calcularSumaInicialSilenciosa() {
    final double op1 = (double.tryParse(_opcion1Base.text) ?? 0) * (double.tryParse(_opcion1Multiplicador.text) ?? 0);
    final double op2 = (double.tryParse(_opcion2Base.text) ?? 0) * (double.tryParse(_opcion2Multiplicador.text) ?? 0);
    final double op3 = (double.tryParse(_opcion3Base.text) ?? 0) * (double.tryParse(_opcion3Multiplicador.text) ?? 0);
    widget.anchoSuajeController.text = (op1 + op2 + op3).toStringAsFixed(2);
  }

  void _cargarCostosBD() {
    final extrasState = ref.read(extrasProvider);

    try {
      final extraSuaje = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'suaje',
      );
      final double valorActualSuaje = double.tryParse(widget.costoSuajeCmController.text) ?? 0.0;
      if (valorActualSuaje == 0) {
        widget.costoSuajeCmController.text = (extraSuaje.costoCm2 ?? 0.0).toStringAsFixed(4);
      }
    } catch (_) {}

    try {
      final extraArreglo = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'arreglo suaje',
      );
      final double valorActualArreglo = double.tryParse(widget.costoArregloSuajeController.text) ?? 0.0;
      if (valorActualArreglo == 0) {
        widget.costoArregloSuajeController.text = (extraArreglo.costoFijo ?? 0.0).toStringAsFixed(2);
      }
    } catch (_) {}

    try {
      final extraMillar = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'entrada suaje por millar',
      );
      final double valorActualMillar = double.tryParse(widget.costoMillarSuajeController.text) ?? 0.0;
      if (valorActualMillar == 0) {
        widget.costoMillarSuajeController.text = (extraMillar.costoFijo ?? 0.0).toStringAsFixed(2);
      }
    } catch (_) {}

    _calcularTotales();
  }

  void _procesarSumaOpciones() {
    final double op1 = (double.tryParse(_opcion1Base.text) ?? 0) * (double.tryParse(_opcion1Multiplicador.text) ?? 0);
    final double op2 = (double.tryParse(_opcion2Base.text) ?? 0) * (double.tryParse(_opcion2Multiplicador.text) ?? 0);
    final double op3 = (double.tryParse(_opcion3Base.text) ?? 0) * (double.tryParse(_opcion3Multiplicador.text) ?? 0);

    final double sumaTotal = op1 + op2 + op3;

    setState(() {
      widget.anchoSuajeController.text = sumaTotal.toStringAsFixed(2);
      _ocultarLargoField = true;
      _mostrarPestanaOpciones = false;
    });

    _calcularTotales();
  }

  void _calcularTotales() {
    if (!widget.enabled) return;

    double tamano = 0.0;
    if (_ocultarLargoField) {
      tamano = double.tryParse(widget.anchoSuajeController.text) ?? 0.0;
    } else {
      final double ancho = (double.tryParse(widget.anchoSuajeController.text) ?? 0.0) / 10;
      final double alto = (double.tryParse(widget.largoSuajeController.text) ?? 0.0) / 10;
      tamano = ancho * alto;
    }

    widget.tamanoSuajeController.text = tamano.toStringAsFixed(2);

    final double costoCm = double.tryParse(widget.costoSuajeCmController.text) ?? 0.0;
    final double costoTotalSuaje = widget.seCuentaConSuaje ? 0.0 : (tamano * costoCm);
    widget.costoTotalSuajeController.text = costoTotalSuaje.toStringAsFixed(2);

    final double costoArreglo = double.tryParse(widget.costoArregloSuajeController.text) ?? 0.0;
    final double pliegos = double.tryParse(widget.pliegosSuajeController.text) ?? 0.0;
    final double costoMillar = double.tryParse(widget.costoMillarSuajeController.text) ?? 0.0;

    final double costoTiraje = (pliegos / 1000) * costoMillar;
    final double granTotal = costoTotalSuaje + costoArreglo + costoTiraje;

    widget.costoTotalSuajadoController.text = granTotal.toStringAsFixed(2);

    // Disparo inmediato para actualizar el total global en la pantalla principal
    if (widget.onChanged != null) {
      Future.microtask(() {
        if (mounted) widget.onChanged!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) => _cargarCostosBD());

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: widget.enabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !widget.enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Datos Suaje, Suajado",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Tamaño Suaje por Pieza (cm):"),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.anchoSuajeController,
                            readOnly: _ocultarLargoField, 
                            onTap: () {
                              setState(() {
                                _mostrarPestanaOpciones = !_mostrarPestanaOpciones;
                              });
                            },
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: _ocultarLargoField ? "Medida Total Suaje" : "Ancho",
                              border: const OutlineInputBorder(),
                              isDense: true,
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              contentPadding: const EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        if (!_ocultarLargoField) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("x"),
                          ),
                          Expanded(
                            child: TextField(
                              controller: widget.largoSuajeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: "Alto",
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (_mostrarPestanaOpciones) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Cálculo de Medidas Múltiples",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            _buildFilaOpcion("Opción 1", _opcion1Base, _opcion1Multiplicador),
                            const SizedBox(height: 8),
                            _buildFilaOpcion("Opción 2", _opcion2Base, _opcion2Multiplicador),
                            const SizedBox(height: 8),
                            _buildFilaOpcion("Opción 3", _opcion3Base, _opcion3Multiplicador),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _ocultarLargoField = false; // Permite volver a ver el campo Ancho x Alto
                                      _mostrarPestanaOpciones = false;
                                    });
                                  },
                                  child: const Text("Usar Ancho x Alto"),
                                ),
                                ElevatedButton(
                                  onPressed: _procesarSumaOpciones,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Continuar"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text("Se cuenta con suaje"),
                      value: widget.seCuentaConSuaje,
                      onChanged: (val) {
                        widget.onSeCuentaConSuajeChanged(val);
                        _calcularTotales();
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text("Costo del Suaje por cm:"),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.costoSuajeCmController,
                      readOnly: true,
                      enabled: !widget.seCuentaConSuaje,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Costo Total Suaje:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.costoTotalSuajeController,
                      readOnly: true,
                      enabled: !widget.seCuentaConSuaje,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Costo Arreglo Suajado:"),
                    const SizedBox(height: 4),
                    TextField(
                      readOnly: true,
                      controller: widget.costoArregloSuajeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("# de Pliegos:"),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.pliegosSuajeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Costo por Millar:"),
                    const SizedBox(height: 4),
                    TextField(
                      readOnly: true,
                      controller: widget.costoMillarSuajeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Costo Total Suajado:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: widget.costoTotalSuajadoController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: "\$ ",
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaOpcion(String etiqueta, TextEditingController base, TextEditingController multi) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(etiqueta, style: const TextStyle(fontSize: 12))),
        Expanded(
          flex: 3,
          child: TextField(
            controller: base,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(6)),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text("x")),
        Expanded(
          flex: 3,
          child: TextField(
            controller: multi,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(6)),
          ),
        ),
      ],
    );
  }
}