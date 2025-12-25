import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';

class ModalCliente extends StatefulWidget {
  final String titulo;
  final Cliente? clienteInicial;
  final Future<void> Function(Cliente) onGuardar;

  const ModalCliente({
    super.key,
    required this.titulo,
    required this.onGuardar,
    this.clienteInicial,
  });

  @override
  State<ModalCliente> createState() => _ModalClienteState();
}

class _ModalClienteState extends State<ModalCliente> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  late TextEditingController razonSocialCtrl;
  late TextEditingController rfcCtrl;
  late TextEditingController calleCtrl;
  late TextEditingController noExtCtrl;
  late TextEditingController noIntCtrl;
  late TextEditingController coloniaCtrl;
  late TextEditingController cpCtrl;
  late TextEditingController municipioCtrl;
  late TextEditingController ciudadCtrl;
  late TextEditingController paisCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController margenCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.clienteInicial;
    razonSocialCtrl = TextEditingController(text: c?.razonSocial ?? '');
    rfcCtrl = TextEditingController(text: c?.rfc ?? '');
    calleCtrl = TextEditingController(text: c?.calle ?? '');
    noExtCtrl = TextEditingController(text: c?.noExterior ?? '');
    noIntCtrl = TextEditingController(text: c?.noInterior ?? '');
    coloniaCtrl = TextEditingController(text: c?.colonia ?? '');
    cpCtrl = TextEditingController(text: c?.cp ?? '');
    municipioCtrl = TextEditingController(text: c?.municipio ?? '');
    ciudadCtrl = TextEditingController(text: c?.ciudad ?? '');
    paisCtrl = TextEditingController(text: c?.pais ?? 'México');
    emailCtrl = TextEditingController(text: c?.correoElectronico ?? '');
    margenCtrl = TextEditingController(
      text: c?.margenUtilidad.toString() ?? '0.0',
    );
  }

  @override
  void dispose() {
    razonSocialCtrl.dispose();
    rfcCtrl.dispose();
    calleCtrl.dispose();
    noExtCtrl.dispose();
    noIntCtrl.dispose();
    coloniaCtrl.dispose();
    cpCtrl.dispose();
    municipioCtrl.dispose();
    ciudadCtrl.dispose();
    paisCtrl.dispose();
    emailCtrl.dispose();
    margenCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final nuevoCliente = Cliente(
        id: widget.clienteInicial?.id ?? '',
        razonSocial: razonSocialCtrl.text,
        rfc: rfcCtrl.text,
        calle: calleCtrl.text,
        noExterior: noExtCtrl.text,
        noInterior: noIntCtrl.text,
        colonia: coloniaCtrl.text,
        cp: cpCtrl.text,
        municipio: municipioCtrl.text,
        ciudad: ciudadCtrl.text,
        pais: paisCtrl.text,
        correoElectronico: emailCtrl.text,
        margenUtilidad: double.tryParse(margenCtrl.text) ?? 0.0,
        fechaModificacion: DateTime.now(),
      );
      await widget.onGuardar(nuevoCliente);

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
          width: 600,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionTitle("Datos Generales"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInput(
                        razonSocialCtrl,
                        'Razón Social',
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(rfcCtrl, 'RFC', required: true),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(emailCtrl, 'Correo Electrónico'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInput(
                        margenCtrl,
                        'Margen Utilidad %',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("Dirección"),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(flex: 2, child: _buildInput(calleCtrl, 'Calle')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(noExtCtrl, 'No. Ext')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(noIntCtrl, 'No. Int')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildInput(coloniaCtrl, 'Colonia')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(cpCtrl, 'C.P.')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildInput(municipioCtrl, 'Municipio')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(ciudadCtrl, 'Ciudad')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput(paisCtrl, 'País')),
                  ],
                ),
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
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: !_isSaving,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (v) =>
          required && (v == null || v.isEmpty) ? 'Requerido' : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
