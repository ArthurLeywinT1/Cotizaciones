import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario_model.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/boton.dart';
import '../../widgets/tabla.dart';
import 'modals/modal_usuario.dart';

final usuariosSeleccionadosProvider = StateProvider<List<Usuario>>((ref) => []);

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
            (
              usuario,
              correo,
              contrasena,
              tipo,
              nombre,
              apellidoP,
              apellidoM,
            ) async {
              final success = await ref
                  .read(usuariosProvider.notifier)
                  .crearUsuario(
                    usuario: usuario,
                    correo: correo,
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
              correo,
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
                    correo: correo,
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

  void _eliminarUsuarios(BuildContext context, WidgetRef ref, List<Usuario> usuarios) {
    final esMultiple = usuarios.length > 1;
    final mensaje = esMultiple
        ? '¿Estás seguro de que deseas eliminar a los ${usuarios.length} usuarios seleccionados?'
        : '¿Estás seguro de que deseas eliminar al usuario "${usuarios.first.usuario}"?';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('$mensaje\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              int eliminados = 0;
              for (final u in usuarios) {
                final ok = await ref.read(usuariosProvider.notifier).eliminarUsuario(u.id);
                if (ok) eliminados++;
              }
              if (context.mounted) {
                ref.read(usuariosSeleccionadosProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(esMultiple ? '$eliminados usuarios eliminados' : 'Usuario eliminado')),
                );
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
    final usuariosSeleccionados = ref.watch(usuariosSeleccionadosProvider);

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
                    onSelectAll: (selected) {
                      if (selected == true) {
                        ref.read(usuariosSeleccionadosProvider.notifier).state = List.from(usuariosState.usuarios);
                      } else {
                        ref.read(usuariosSeleccionadosProvider.notifier).state = [];
                      }
                    },
                    columns: const [
                      DataColumn(label: Text('Usuario')),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Rol')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Apellido Paterno')),
                      DataColumn(label: Text('Apellido Materno')),
                    ],
                    rows: usuariosState.usuarios.map((usuario) {
                      final isSelected = usuariosSeleccionados.any((u) => u.id == usuario.id);
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (selected) {
                          final actual = List<Usuario>.from(ref.read(usuariosSeleccionadosProvider));
                          if (selected == true) {
                            actual.add(usuario);
                          } else {
                            actual.removeWhere((u) => u.id == usuario.id);
                          }
                          ref.read(usuariosSeleccionadosProvider.notifier).state = actual;
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
                          DataCell(Text(usuario.correo)),
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            color: Colors.grey.shade200,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Boton(
                  icon: Icons.edit,
                  label: "Modificar",
                  onPressed: () {
                    if (usuariosSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un usuario para modificar')),
                      );
                      return;
                    }
                    if (usuariosSeleccionados.length > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo puedes modificar un usuario a la vez')),
                      );
                      return;
                    }
                    _modificarUsuario(context, ref, usuariosSeleccionados.first);
                  },
                ),
                Boton(
                  icon: Icons.delete,
                  label: "Eliminar",
                  isDestructive: true,
                  onPressed: () {
                    if (usuariosSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona al menos un usuario para eliminar')),
                      );
                      return;
                    }
                    _eliminarUsuarios(context, ref, usuariosSeleccionados);
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
