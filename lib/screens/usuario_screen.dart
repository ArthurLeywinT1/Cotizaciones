import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario_model.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/boton.dart';
import '../../widgets/tabla.dart';
import 'modals/modal_usuario.dart';

class UsuarioScreen extends ConsumerWidget {
  const UsuarioScreen({super.key});

  Color _getColorPorRol(String rol) {
    switch (rol) {
      case 'Admin':
        return Colors.red;
      case 'Offset':
        return Colors.blue;
      case 'Diseño':
        return Colors.purple;
      case 'Corte':
        return Colors.orange;
      default:
        return Colors.grey.shade700;
    }
  }

  void _agregarUsuario(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ModalUsuario(
        titulo: 'Crear Nuevo Usuario',
        onGuardar:
            (usuario, contrasena, tipo, nombre, apellidoP, apellidoM) async {
              final success = await ref
                  .read(usuariosProvider.notifier)
                  .crearUsuario(
                    usuario: usuario,
                    contrasena: contrasena,
                    tipoUsuario: tipo,
                    nombre: nombre,
                    apellidoPaterno: apellidoP,
                    apellidoMaterno: apellidoM,
                  );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario creado exitosamente')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${ref.read(usuariosProvider).error}'),
                  ),
                );
              }
            },
      ),
    );
  }

  void _modificarUsuario(BuildContext context, WidgetRef ref, Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => ModalUsuario(
        titulo: 'Modificar Usuario',
        usuarioInicial: usuario,
        onGuardar:
            (
              usuarioNombre,
              contrasena,
              tipo,
              nombre,
              apellidoP,
              apellidoM,
            ) async {
              final success = await ref
                  .read(usuariosProvider.notifier)
                  .actualizarUsuario(
                    id: usuario.id,
                    usuario: usuarioNombre,
                    nuevaContrasena: contrasena,
                    tipoUsuario: tipo,
                    nombre: nombre,
                    apellidoPaterno: apellidoP,
                    apellidoMaterno: apellidoM,
                  );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario actualizado exitosamente'),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${ref.read(usuariosProvider).error}'),
                  ),
                );
              }
            },
      ),
    );
  }

  void _eliminarUsuario(BuildContext context, WidgetRef ref, Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar al usuario "${usuario.usuario}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(usuariosProvider.notifier)
                  .eliminarUsuario(usuario.id);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ref.read(usuarioSeleccionadoProvider.notifier).state = null;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario eliminado exitosamente'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${ref.read(usuariosProvider).error}',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosState = ref.watch(usuariosProvider);
    final usuarioSeleccionado = ref.watch(usuarioSeleccionadoProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: usuariosState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : usuariosState.error.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${usuariosState.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(usuariosProvider.notifier).recargar(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : usuariosState.usuarios.isEmpty
                ? const Center(child: Text('No hay usuarios registrados'))
                : Tabla(
                    columns: const [
                      DataColumn(label: Text('Usuario')),
                      DataColumn(label: Text('Rol')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Apellido Paterno')),
                      DataColumn(label: Text('Apellido Materno')),
                    ],
                    rows: usuariosState.usuarios.map((usuario) {
                      final isSelected = usuarioSeleccionado?.id == usuario.id;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          if (isSelected) {
                            ref
                                    .read(usuarioSeleccionadoProvider.notifier)
                                    .state =
                                null;
                          } else {
                            ref
                                    .read(usuarioSeleccionadoProvider.notifier)
                                    .state =
                                usuario;
                          }
                        },
                        cells: [
                          DataCell(
                            Text(
                              usuario.usuario,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getColorPorRol(
                                  usuario.tipoUsuario,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _getColorPorRol(usuario.tipoUsuario),
                                ),
                              ),
                              child: Text(
                                usuario.tipoUsuario,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getColorPorRol(usuario.tipoUsuario),
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(usuario.nombre)),
                          DataCell(Text(usuario.apellidoPaterno)),
                          DataCell(Text(usuario.apellidoMaterno ?? '-')),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(top: BorderSide(color: Colors.grey.shade400)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Boton(
                  icon: Icons.person_add,
                  label: "Añadir",
                  onPressed: () => _agregarUsuario(context, ref),
                ),
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (usuarioSeleccionado != null) {
                      _modificarUsuario(context, ref, usuarioSeleccionado);
                    }
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (usuarioSeleccionado != null) {
                      _eliminarUsuario(context, ref, usuarioSeleccionado);
                    }
                  },
                ),

                Boton(
                  icon: Icons.refresh,
                  label: "Recargar",
                  onPressed: () {
                    ref.read(usuariosProvider.notifier).recargar();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
