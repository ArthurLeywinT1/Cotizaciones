import 'package:flutter/material.dart';
import '../../models/descuento_model.dart';
import '../../models/papel_model.dart';

class ModalDescuento extends StatefulWidget {
  final String titulo;
  final DescuentoPapel? descuentoInicial;
  final List<Papel> listaPapeles;
  final Function(DescuentoPapel) onGuardar;

  const ModalDescuento({
    super.key,
    required this.titulo,
    required this.onGuardar,
    required this.listaPapeles,
    this.descuentoInicial,
  });

  @override
  State<ModalDescuento> createState() => _ModalDescuentoState();
}

class _ModalDescuentoState extends State<ModalDescuento> {
  final _formKey = GlobalKey<FormState>();

  String? papelSeleccionadoId;
  late TextEditingController desdeCtrl;
  late TextEditingController hastaCtrl;
  late TextEditingController descuentoCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.descuentoInicial;

    if (d?.papelId != null) {
      if (widget.listaPapeles.any((p) => p.id == d!.papelId)) {
        papelSeleccionadoId = d!.papelId;
      }
    }

    desdeCtrl = TextEditingController(text: d?.cantidadDesde.toString() ?? '');
    hastaCtrl = TextEditingController(text: d?.cantidadHasta.toString() ?? '');
    descuentoCtrl = TextEditingController(text: d?.descuento.toString() ?? '');
  }

  @override
  void dispose() {
    desdeCtrl.dispose();
    hastaCtrl.dispose();
    descuentoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevoDescuento = DescuentoPapel(
        id: widget.descuentoInicial?.id ?? '',
        papelId: papelSeleccionadoId!,
        cantidadDesde: int.parse(desdeCtrl.text),
        cantidadHasta: int.parse(hastaCtrl.text),
        descuento: double.parse(descuentoCtrl.text),
        fechaModificacion: DateTime.now(),
      );

      widget.onGuardar(nuevoDescuento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: papelSeleccionadoId,
                  decoration: const InputDecoration(
                    labelText: 'Papel',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.listaPapeles.map((papel) {
                    return DropdownMenuItem(
                      value: papel.id,
                      child: Text(
                        papel.nombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => papelSeleccionadoId = val),
                  validator: (val) =>
                      val == null ? 'Selecciona un papel' : null,
                ),
                const SizedBox(height: 16),

                const Text(
                  "Rango de Cantidad (Hojas)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(desdeCtrl, 'Desde', isNumber: true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInput(hastaCtrl, 'Hasta', isNumber: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildInput(descuentoCtrl, 'Descuento (%)', isNumber: true),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: null,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        return null;
      },
    );
  }
}
