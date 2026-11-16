import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cliente_model.dart';
import '../../models/cotizacion_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/cotizacion_provider.dart';
import '../cotizacion-plana/buscador_cliente.dart';
import 'modal_cliente.dart';

class ModalCotizacionBasica extends ConsumerStatefulWidget {
  const ModalCotizacionBasica({super.key});

  @override
  ConsumerState<ModalCotizacionBasica> createState() =>
      _ModalCotizacionBasicaState();
}

class _ModalCotizacionBasicaState extends ConsumerState<ModalCotizacionBasica> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _clienteCtrl = TextEditingController();
  final TextEditingController _proyectoCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _piezasCtrl = TextEditingController();

  Cliente? _clienteSeleccionado;
  bool _isSaving = false;

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _proyectoCtrl.dispose();
    _descripcionCtrl.dispose();
    _piezasCtrl.dispose();
    super.dispose();
  }

  void _abrirBuscadorCliente() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorCliente(
        onSeleccionado: (cliente) {
          setState(() {
            _clienteSeleccionado = cliente;
            _clienteCtrl.text = cliente.razonSocial;
          });
        },
      ),
    );
  }

  void _abrirNuevoCliente() {
    showDialog(
      context: context,
      builder: (dialogContext) => ModalCliente(
        titulo: 'Nuevo Cliente',
        onGuardar: (clienteNuevo) async {
          final success = await ref
              .read(clientesProvider.notifier)
              .crearCliente(clienteNuevo);

          if (success && dialogContext.mounted) {
            Navigator.pop(dialogContext);

            final listaClientes = ref.read(clientesProvider).clientes;
            try {
              final creado = listaClientes.firstWhere(
                (c) =>
                    c.razonSocial.toLowerCase() ==
                    clienteNuevo.razonSocial.toLowerCase(),
              );
              setState(() {
                _clienteSeleccionado = creado;
                _clienteCtrl.text = creado.razonSocial;
              });
            } catch (_) {}

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cliente creado y seleccionado')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _guardarYContinuar() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona o crea un cliente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final usuarioId = ref.read(authProvider).usuario?.id ?? '';
    if (usuarioId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se detectó sesión de usuario activa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final int piezas = int.tryParse(_piezasCtrl.text.trim()) ?? 0;
    final String proyecto = _proyectoCtrl.text.trim();
    final String descripcion = _descripcionCtrl.text.trim();

    final nuevaCotizacion = Cotizacion(
      clienteId: _clienteSeleccionado!.id,
      clienteNombre: _clienteSeleccionado!.razonSocial,
      usuarioId: usuarioId,
      descripcion: descripcion,
      anchoMedida: 0.0,
      altoMedida: 0.0,
      cantidadImpresiones: piezas,
      tipoCotizacion: 'P',
      status: 'Aprobada',
      configClientes: {
        'id': _clienteSeleccionado!.id,
        'cliente_id': _clienteSeleccionado!.id,
        'razonSocial': _clienteSeleccionado!.razonSocial,
        'razon_social': _clienteSeleccionado!.razonSocial,
        'rfc': _clienteSeleccionado!.rfc ?? '',
        'proyecto': proyecto,
        'descripcion': descripcion,
        'piezas': piezas,
        'piezas_totales': piezas,
        'cantidadImpresiones': piezas,
      },
    );

    final nuevoId = await ref
        .read(cotizacionesProvider.notifier)
        .crearCotizacionYObtenerId(nuevaCotizacion);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (nuevoId != null && nuevoId.isNotEmpty) {
      Navigator.pop(context, nuevoId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear la cotización'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Cotización Plana'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 550,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clienteCtrl,
                        readOnly: true,
                        onTap: _isSaving ? null : _abrirBuscadorCliente,
                        decoration: const InputDecoration(
                          labelText: 'Razón Social Cliente',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Selecciona un cliente'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _isSaving ? null : _abrirBuscadorCliente,
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar Cliente',
                    ),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      onPressed: _isSaving ? null : _abrirNuevoCliente,
                      icon: const Icon(Icons.add),
                      tooltip: 'Crear Nuevo Cliente',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _proyectoCtrl,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Proyecto',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descripcionCtrl,
                  enabled: !_isSaving,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del proyecto',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _piezasCtrl,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Piezas totales solicitadas',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Ingresa una cantidad válida';
                    return null;
                  },
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
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _guardarYContinuar,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_forward),
          label: const Text('Crear y Abrir OT'),
        ),
      ],
    );
  }
}
