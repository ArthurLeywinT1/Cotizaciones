import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/maquina_model.dart';
import '../../providers/maquina_provider.dart';
import '../modals/modal_maquina.dart';
import 'buscador_maquina.dart';
import '../../providers/extra_provider.dart';

class PanelMaquina extends ConsumerStatefulWidget {
  final TextEditingController nombreMaquinaController;
  final TextEditingController costoPlacaController;

  final TextEditingController tintasFteController;
  final TextEditingController tintasRevController;
  final TextEditingController cantidadTotalTintasController;

  final TextEditingController costoUnitFteController;
  final TextEditingController costoTotalFteController;
  final TextEditingController costoUnitRevController;
  final TextEditingController costoTotalRevController;
  final TextEditingController costoGranTotalTintasController;

  final TextEditingController cantidadPlacasController;
  final TextEditingController costoBarnizController;
  final TextEditingController costoTotalPlacasController;

  final bool barnizMaquina;
  final ValueChanged<bool?> onBarnizMaquinaChanged;
  final bool cambiarPrecioPlaca;
  final ValueChanged<bool?> onCambiarPrecioPlacaChanged;

  const PanelMaquina({
    super.key,
    required this.nombreMaquinaController,
    required this.costoPlacaController,
    required this.tintasFteController,
    required this.tintasRevController,
    required this.cantidadTotalTintasController,
    required this.costoUnitFteController,
    required this.costoTotalFteController,
    required this.costoUnitRevController,
    required this.costoTotalRevController,
    required this.costoGranTotalTintasController,
    required this.cantidadPlacasController,
    required this.costoBarnizController,
    required this.costoTotalPlacasController,
    required this.barnizMaquina,
    required this.onBarnizMaquinaChanged,
    required this.cambiarPrecioPlaca,
    required this.onCambiarPrecioPlacaChanged,
  });

  @override
  ConsumerState<PanelMaquina> createState() => _PanelMaquinaState();
}

class _PanelMaquinaState extends ConsumerState<PanelMaquina> {
  @override
  void initState() {
    super.initState();
    widget.tintasFteController.addListener(_calcularCostosTintas);
    widget.tintasRevController.addListener(_calcularCostosTintas);

    widget.cantidadPlacasController.addListener(_calcularTotalPlacas);
    widget.costoPlacaController.addListener(_calcularTotalPlacas);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcularCostosTintas();
      _cargarCostoPlacaDefault();
    });
  }

  void _calcularCostosTintas() {
    final extrasState = ref.read(extrasProvider);
    double costoFijoTinta = 0.0;

    try {
      final extraTintas = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'tintas',
      );
      costoFijoTinta = extraTintas.costoFijo ?? 0.0;
    } catch (e) {
      costoFijoTinta = 0.0;
    }

    final double cantFte =
        double.tryParse(widget.tintasFteController.text) ?? 0.0;
    final double cantRev =
        double.tryParse(widget.tintasRevController.text) ?? 0.0;

    widget.costoUnitFteController.text = costoFijoTinta.toStringAsFixed(2);
    final double totalFte = cantFte * costoFijoTinta;
    widget.costoTotalFteController.text = totalFte.toStringAsFixed(2);

    widget.costoUnitRevController.text = costoFijoTinta.toStringAsFixed(2);
    final double totalRev = cantRev * costoFijoTinta;
    widget.costoTotalRevController.text = totalRev.toStringAsFixed(2);

    widget.cantidadTotalTintasController.text = (cantFte + cantRev)
        .toStringAsFixed(0);
    widget.costoGranTotalTintasController.text = (totalFte + totalRev)
        .toStringAsFixed(2);
  }

  void _cargarCostoPlacaDefault() {
    if (widget.costoPlacaController.text.isNotEmpty &&
        widget.costoPlacaController.text != "0" &&
        widget.costoPlacaController.text != "0.0") {
      return;
    }

    final extrasState = ref.read(extrasProvider);
    double costoFijoPlaca = 0.0;

    try {
      final extraPlacas = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'placas',
      );
      costoFijoPlaca = extraPlacas.costoFijo ?? 0.0;
    } catch (e) {
      costoFijoPlaca = 0.0;
    }

    if (costoFijoPlaca > 0) {
      widget.costoPlacaController.text = costoFijoPlaca.toStringAsFixed(2);
      _calcularTotalPlacas();
    }
  }

  void _calcularTotalPlacas() {
    final double cantidad =
        double.tryParse(widget.cantidadPlacasController.text) ?? 0.0;
    final double costoUnitario =
        double.tryParse(widget.costoPlacaController.text) ?? 0.0;

    final double total = cantidad * costoUnitario;
    widget.costoTotalPlacasController.text = total.toStringAsFixed(2);
  }

  void _buscarMaquina() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorMaquina(
        onSeleccionado: (maquina) {
          widget.nombreMaquinaController.text = maquina.nombre;
          widget.costoPlacaController.text = maquina.costoPorPlaca.toString();
          _calcularTotalPlacas();
        },
      ),
    );
  }

  void _agregarMaquina(BuildContext context, WidgetRef ref, Maquina? maquina) {
    showDialog(
      context: context,
      builder: (context) => ModalMaquina(
        titulo: maquina == null ? 'Nueva Máquina' : 'Modificar Máquina',
        maquinaInicial: maquina,
        onGuardar: (nuevaMaquina) async {
          bool success;
          if (maquina == null) {
            success = await ref
                .read(maquinasProvider.notifier)
                .crearMaquina(nuevaMaquina);
          } else {
            success = await ref
                .read(maquinasProvider.notifier)
                .actualizarMaquina(nuevaMaquina);
          }

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  maquina == null ? 'Máquina creada' : 'Máquina actualizada',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) {
      _calcularCostosTintas();
      _cargarCostoPlacaDefault();
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO PRINCIPAL
            const Text(
              "Datos Máquina de Impresión a Usar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // NOMBRE DE LA MÁQUINA + BOTÓN SEARCH
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: widget.nombreMaquinaController,
                    decoration: const InputDecoration(
                      labelText: "Nombre de la Máquina",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _buscarMaquina,
                  icon: const Icon(Icons.search),
                  tooltip: "Buscar máquina",
                ),
                IconButton(
                  onPressed: () => _agregarMaquina(context, ref, null),
                  icon: const Icon(Icons.add),
                  tooltip: "Agregar máquina",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===============================================
            // BLOQUE NUEVO: TINTAS A UTILIZAR
            // ===============================================
            const Text("Tintas a Utilizar en la Impresión:"),
            const SizedBox(height: 4),

            Row(
              children: [
                SizedBox(
                  width: 55,
                  child: TextField(
                    controller: widget.tintasFteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("X"),
                const SizedBox(width: 6),
                SizedBox(
                  width: 55,
                  child: TextField(
                    controller: widget.tintasRevController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Checkbox(
                  value: widget.barnizMaquina,
                  onChanged: widget.onBarnizMaquinaChanged,
                ),
                const Text("Barniz de Máquina"),
              ],
            ),

            const SizedBox(height: 20),

            // CANTIDAD TOTAL TINTAS
            const Text("Cantidad Total Tintas:"),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: TextField(
                controller: widget.cantidadTotalTintasController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Color(0xFFEEEEEE),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DOS COLUMNAS (FRONTAL / REVERSO)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Costo por Tinta Frontal:"),
                      const SizedBox(height: 4),
                      _MonedaInput(readOnly: true),
                      const SizedBox(height: 12),
                      const Text("Costo Tintas Frontal:"),
                      const SizedBox(height: 4),
                      _MonedaInput(readOnly: true),
                    ],
                  ),
                ),
                const SizedBox(width: 25),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Costo por Tinta Reverso:"),
                      const SizedBox(height: 4),
                      _MonedaInput(readOnly: true),
                      const SizedBox(height: 12),
                      const Text("Costo Tintas Reverso:"),
                      const SizedBox(height: 4),
                      _MonedaInput(readOnly: true),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // COSTO TOTAL TINTAS
            const Text(
              "Costo Total Tintas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _MonedaInput(readOnly: true),

            const SizedBox(height: 20),

            // CANTIDAD PLACAS
            const Text("Cantidad Placas:"),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: TextField(
                controller: widget.cantidadPlacasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Checkbox(
                  value: widget.cambiarPrecioPlaca,
                  onChanged: widget.onCambiarPrecioPlacaChanged,
                ),
                const Text("Cambiar Precio Por Placa:"),
              ],
            ),

            const SizedBox(height: 16),

            // COSTO BARNIZ
            const Text(
              "Costo Barniz de Máquina:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _MonedaInput(controller: widget.costoBarnizController),

            const SizedBox(height: 16),

            const Text("Costo por Placa:"),
            const SizedBox(height: 4),
            TextField(
              controller: widget.costoPlacaController,
              readOnly: widget.cambiarPrecioPlaca,
              decoration: InputDecoration(
                prefixText: "\$ ",
                border: const OutlineInputBorder(),
                isDense: true,
                filled: !widget.cambiarPrecioPlaca,
                fillColor: !widget.cambiarPrecioPlaca
                    ? const Color(0xFFEEEEEE)
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Costo Total Placas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _MonedaInput(
              controller: widget.costoTotalPlacasController,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonedaInput extends StatelessWidget {
  final TextEditingController? controller;
  final bool readOnly;

  const _MonedaInput({this.controller, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixText: "\$ ",
        border: const OutlineInputBorder(),
        isDense: true,
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFEEEEEE) : null,
      ),
    );
  }
}
