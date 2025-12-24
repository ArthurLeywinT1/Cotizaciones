import 'package:flutter/material.dart';
import '../../models/extra_model.dart';

class ModalExtra extends StatefulWidget {
  final String titulo;
  final Extra? extraInicial;
  final Future<void> Function(Extra) onGuardar;

  const ModalExtra({
    super.key,
    required this.titulo,
    required this.onGuardar,
    this.extraInicial,
  });

  @override
  State<ModalExtra> createState() => _ModalExtraState();
}

class _ModalExtraState extends State<ModalExtra> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  late TextEditingController nombreCtrl;
  late TextEditingController costoCm2Ctrl;
  late TextEditingController costoMinimoCtrl;
  late TextEditingController costoFijoCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.extraInicial;
    nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    costoCm2Ctrl = TextEditingController(text: e?.costoCm2?.toString() ?? '');
    costoMinimoCtrl = TextEditingController(
      text: e?.costoMinimoTotal?.toString() ?? '',
    );
    costoFijoCtrl = TextEditingController(text: e?.costoFijo?.toString() ?? '');
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    costoCm2Ctrl.dispose();
    costoMinimoCtrl.dispose();
    costoFijoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final nuevoExtra = Extra(
        id: widget.extraInicial?.id ?? '',
        nombre: nombreCtrl.text,
        costoCm2: double.tryParse(costoCm2Ctrl.text),
        costoMinimoTotal: double.tryParse(costoMinimoCtrl.text),
        costoFijo: double.tryParse(costoFijoCtrl.text),
        fechaModificacion: DateTime.now(),
      );

      await widget.onGuardar(nuevoExtra);

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
                _buildInput(nombreCtrl, 'Nombre del Extra', required: true),
                const SizedBox(height: 16),

                const Text(
                  "Configuración de Costos (Llenar al menos uno)",
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
                        costoCm2Ctrl,
                        'Costo por cm²',
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInput(
                        costoFijoCtrl,
                        'Costo Fijo',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildInput(
                  costoMinimoCtrl,
                  'Costo Mínimo Total',
                  isNumber: true,
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
