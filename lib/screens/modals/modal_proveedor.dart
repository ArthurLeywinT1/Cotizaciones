import 'package:flutter/material.dart';
import '../../models/proveedor_model.dart';

class ModalProveedor extends StatefulWidget {
  final String titulo;
  final Proveedor? proveedorInicial;
  final Future<void> Function(Proveedor) onGuardar;

  const ModalProveedor({
    super.key,
    required this.titulo,
    required this.onGuardar,
    this.proveedorInicial,
  });

  @override
  State<ModalProveedor> createState() => _ModalProveedorState();
}

class _ModalProveedorState extends State<ModalProveedor> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  late TextEditingController razonSocialCtrl;
  late TextEditingController rfcCtrl;
  late TextEditingController direccionCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController emailCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.proveedorInicial;
    razonSocialCtrl = TextEditingController(text: p?.razonSocial ?? '');
    rfcCtrl = TextEditingController(text: p?.rfc ?? '');
    direccionCtrl = TextEditingController(text: p?.direccion ?? '');
    telefonoCtrl = TextEditingController(text: p?.telefono ?? '');
    emailCtrl = TextEditingController(text: p?.correoElectronico ?? '');
  }

  @override
  void dispose() {
    razonSocialCtrl.dispose();
    rfcCtrl.dispose();
    direccionCtrl.dispose();
    telefonoCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final nuevoProveedor = Proveedor(
        id: widget.proveedorInicial?.id ?? '',
        razonSocial: razonSocialCtrl.text,
        rfc: rfcCtrl.text.trim().isEmpty ? null : rfcCtrl.text.trim(),
        direccion: direccionCtrl.text.trim().isEmpty
            ? null
            : direccionCtrl.text.trim(),
        telefono: telefonoCtrl.text.trim().isEmpty
            ? null
            : telefonoCtrl.text.trim(),
        correoElectronico: emailCtrl.text.trim().isEmpty
            ? null
            : emailCtrl.text.trim(),
        fechaModificacion: DateTime.now(),
      );

      await widget.onGuardar(nuevoProveedor);
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
                _buildInput(razonSocialCtrl, 'Razón Social', required: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInput(rfcCtrl, 'RFC')),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInput(
                        telefonoCtrl,
                        'Teléfono',
                        isPhone: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildInput(emailCtrl, 'Correo Electrónico', isEmail: true),
                const SizedBox(height: 16),

                _buildInput(direccionCtrl, 'Dirección', maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _guardar,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    bool isPhone = false,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: !_isSaving,
      maxLines: maxLines,
      keyboardType: isPhone
          ? TextInputType.phone
          : isEmail
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: null,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Este campo es requerido';
        }
        return null;
      },
    );
  }
}
