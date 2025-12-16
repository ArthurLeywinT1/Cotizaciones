import 'package:flutter/material.dart';
import '../../models/descuento_model.dart';

class ModalDescuento extends StatefulWidget {
  final String titulo;
  final DescuentoPapel? descuentoInicial;
  final Function(DescuentoPapel) onGuardar;

  const ModalDescuento({
    super.key,
    required this.titulo,
    required this.onGuardar,
    this.descuentoInicial,
  });

  @override
  State<ModalDescuento> createState() => _ModalDescuentoState();
}

class _ModalDescuentoState extends State<ModalDescuento> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController desdeCtrl;
  late TextEditingController hastaCtrl;
  late TextEditingController descuentoCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.descuentoInicial;

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
                const Text(
                  "Rango de Cantidad (Hojas)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
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
