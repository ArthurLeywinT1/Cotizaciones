import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';

class ModalUsuario extends StatefulWidget {
  final String titulo;
  final Usuario? usuarioInicial;
  final Function(
    String usuario,
    String contrasena,
    String tipoUsuario,
    String nombre,
    String apellidoPaterno,
    String? apellidoMaterno,
  )
  onGuardar;

  const ModalUsuario({
    super.key,
    required this.titulo,
    required this.onGuardar,
    this.usuarioInicial,
  });

  @override
  State<ModalUsuario> createState() => _ModalUsuarioState();
}

class _ModalUsuarioState extends State<ModalUsuario> {
  late TextEditingController usuarioController;
  late TextEditingController contrasenaController;
  late TextEditingController nombreController;
  late TextEditingController apellidoPController;
  late TextEditingController apellidoMController;
  String tipoUsuarioSeleccionado = 'Admin';
  bool esModificacion = false;

  final tiposUsuario = [
    'Admin',
    'Offset',
    'Diseño',
    'Corte',
    'Suaje',
    'Laminado',
    'Acabado',
    'Logistica',
    'Serigrafia',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    esModificacion = widget.usuarioInicial != null;

    usuarioController = TextEditingController(
      text: widget.usuarioInicial?.usuario ?? '',
    );
    contrasenaController = TextEditingController();
    nombreController = TextEditingController(
      text: widget.usuarioInicial?.nombre ?? '',
    );
    apellidoPController = TextEditingController(
      text: widget.usuarioInicial?.apellidoPaterno ?? '',
    );
    apellidoMController = TextEditingController(
      text: widget.usuarioInicial?.apellidoMaterno ?? '',
    );
    tipoUsuarioSeleccionado = widget.usuarioInicial?.tipoUsuario ?? 'Admin';
  }

  @override
  void dispose() {
    usuarioController.dispose();
    contrasenaController.dispose();
    nombreController.dispose();
    apellidoPController.dispose();
    apellidoMController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (usuarioController.text.isEmpty ||
        nombreController.text.isEmpty ||
        apellidoPController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos requeridos'),
        ),
      );
      return;
    }

    if (!esModificacion && contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña es requerida para crear un usuario'),
        ),
      );
      return;
    }

    if (contrasenaController.text.isNotEmpty &&
        contrasenaController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    widget.onGuardar(
      usuarioController.text,
      contrasenaController.text,
      tipoUsuarioSeleccionado,
      nombreController.text,
      apellidoPController.text,
      apellidoMController.text.isEmpty ? null : apellidoMController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usuarioController,
              decoration: const InputDecoration(
                labelText: 'Usuario (nombre de login)',
                border: OutlineInputBorder(),
                helperText: 'Debe ser único en el sistema',
              ),
              enabled: !esModificacion,
            ),
            const SizedBox(height: 12),
            if (!esModificacion)
              Column(
                children: [
                  TextField(
                    controller: contrasenaController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      helperText: 'Mínimo 6 caracteres',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                ],
              )
            else
              Column(
                children: [
                  TextField(
                    controller: contrasenaController,
                    decoration: const InputDecoration(
                      labelText:
                          'Nueva Contraseña (dejar vacío para no cambiar)',
                      border: OutlineInputBorder(),
                      helperText: 'Si deseas cambiarla, mínimo 6 caracteres',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            DropdownButtonFormField<String>(
              value: tipoUsuarioSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Usuario',
                border: OutlineInputBorder(),
              ),
              items: tiposUsuario
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => tipoUsuarioSeleccionado = valor);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apellidoPController,
              decoration: const InputDecoration(
                labelText: 'Apellido Paterno',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apellidoMController,
              decoration: const InputDecoration(
                labelText: 'Apellido Materno (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
}
