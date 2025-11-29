import 'package:flutter/material.dart';
import '../../models/papel_model.dart';
import '../../models/proveedor_model.dart';

class ModalPapel extends StatefulWidget {
  final String titulo;
  final Papel? papelInicial;
  final List<Proveedor> listaProveedores;
  final Function(Papel) onGuardar;

  const ModalPapel({
    super.key,
    required this.titulo,
    required this.onGuardar,
    required this.listaProveedores,
    this.papelInicial,
  });

  @override
  State<ModalPapel> createState() => _ModalPapelState();
}

class _ModalPapelState extends State<ModalPapel> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreCtrl;
  late TextEditingController tipoCtrl;
  late TextEditingController anchoCtrl;
  late TextEditingController largoCtrl;
  late TextEditingController pesoCtrl;
  late TextEditingController costoCtrl;

  String? proveedorSeleccionadoId;

  @override
  void initState() {
    super.initState();
    final p = widget.papelInicial;
    nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    tipoCtrl = TextEditingController(text: p?.tipo ?? '');
    anchoCtrl = TextEditingController(text: p?.ancho?.toString() ?? '');
    largoCtrl = TextEditingController(text: p?.largo?.toString() ?? '');
    pesoCtrl = TextEditingController(text: p?.peso?.toString() ?? '');
    costoCtrl = TextEditingController(text: p?.costoMillar.toString() ?? '');

    if (p?.proveedorId != null) {
      final existe = widget.listaProveedores.any(
        (prov) => prov.id == p!.proveedorId,
      );
      if (existe) {
        proveedorSeleccionadoId = p!.proveedorId;
      }
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    tipoCtrl.dispose();
    anchoCtrl.dispose();
    largoCtrl.dispose();
    pesoCtrl.dispose();
    costoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevoPapel = Papel(
        id: widget.papelInicial?.id ?? '',
        nombre: nombreCtrl.text,
        tipo: tipoCtrl.text.isEmpty ? null : tipoCtrl.text,
        ancho: int.tryParse(anchoCtrl.text),
        largo: int.tryParse(largoCtrl.text),
        peso: int.tryParse(pesoCtrl.text),
        costoMillar: double.tryParse(costoCtrl.text) ?? 0.0,
        proveedorId: proveedorSeleccionadoId,
        fechaModificacion: DateTime.now(),
      );

      widget.onGuardar(nuevoPapel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 600,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInput(
                        nombreCtrl,
                        'Nombre del Papel',
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(tipoCtrl, 'Tipo (Bond, Couché...)'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Dimensiones y Peso",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        anchoCtrl,
                        'Ancho (cm)',
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(
                        largoCtrl,
                        'Largo (cm)',
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(pesoCtrl, 'Peso (g)', isNumber: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Costos y Proveedor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        costoCtrl,
                        'Costo por Millar (\$)',
                        required: true,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: proveedorSeleccionadoId,
                        decoration: const InputDecoration(
                          labelText: 'Proveedor',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: widget.listaProveedores.map((prov) {
                          return DropdownMenuItem(
                            value: prov.id,
                            child: Text(
                              prov.razonSocial,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => proveedorSeleccionadoId = val),
                        validator: (val) =>
                            val == null ? 'Selecciona un proveedor' : null,
                      ),
                    ),
                  ],
                ),
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
    bool required = false,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Requerido';
        }
        return null;
      },
    );
  }
}
