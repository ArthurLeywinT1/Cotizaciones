import 'package:flutter/material.dart';
import '../../models/maquina_model.dart';

class ModalMaquina extends StatefulWidget {
  final String titulo;
  final Maquina? maquinaInicial;
  final Future<void> Function(Maquina) onGuardar;

  const ModalMaquina({
    super.key,
    required this.titulo,
    required this.onGuardar,
    this.maquinaInicial,
  });

  @override
  State<ModalMaquina> createState() => _ModalMaquinaState();
}

class _ModalMaquinaState extends State<ModalMaquina> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  late TextEditingController nombreCtrl;
  late TextEditingController tintasCtrl;
  late TextEditingController tamanosCtrl;
  late TextEditingController anchoCtrl;
  late TextEditingController largoCtrl;
  late TextEditingController costo615Ctrl;
  late TextEditingController costo790Ctrl;

  @override
  void initState() {
    super.initState();
    final m = widget.maquinaInicial;
    nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    tintasCtrl = TextEditingController(
      text: m?.cantidadTintas?.toString() ?? '',
    );
    tamanosCtrl = TextEditingController(
      text: m?.cantidadTamanos?.toString() ?? '',
    );
    anchoCtrl = TextEditingController(text: m?.anchoMaximo?.toString() ?? '');
    largoCtrl = TextEditingController(text: m?.largoMaximo?.toString() ?? '');

    costo615Ctrl = TextEditingController(
      text: m?.costoPlaca615x724.toString() ?? '',
    );
    costo790Ctrl = TextEditingController(
      text: m?.costoPlaca790x1030.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    tintasCtrl.dispose();
    tamanosCtrl.dispose();
    anchoCtrl.dispose();
    largoCtrl.dispose();
    costo615Ctrl.dispose();
    costo790Ctrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      final nuevaMaquina = Maquina(
        id: widget.maquinaInicial?.id ?? '',
        nombre: nombreCtrl.text,
        cantidadTintas: int.tryParse(tintasCtrl.text),
        cantidadTamanos: int.tryParse(tamanosCtrl.text),
        anchoMaximo: int.tryParse(anchoCtrl.text),
        largoMaximo: int.tryParse(largoCtrl.text),
        costoPlaca615x724: double.tryParse(costo615Ctrl.text) ?? 0.0,
        costoPlaca790x1030: double.tryParse(costo790Ctrl.text) ?? 0.0,
        fechaModificacion: DateTime.now(),
      );

      await widget.onGuardar(nuevaMaquina);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput(nombreCtrl, 'Nombre de la Máquina', required: true),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        tintasCtrl,
                        'No. Tintas',
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInput(
                        tamanosCtrl,
                        'Cant. Tamaños',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Formato Máximo de Impresión",
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInput(
                        largoCtrl,
                        'Largo (cm)',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Costos por Placa (\$)",
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
                        costo615Ctrl,
                        '615x724',
                        required: true,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInput(
                        costo790Ctrl,
                        '790x1030',
                        required: true,
                        isNumber: true,
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
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Requerido';
        }
        return null;
      },
    );
  }
}
