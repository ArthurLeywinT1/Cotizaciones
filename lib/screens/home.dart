import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../Widgets/barra.dart';
import 'usuarios_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String pantallaActual = '';

  void _abrirPantalla(String pantalla) {
    setState(() {
      pantallaActual = pantalla;
    });
  }

  void _volverPrincipal() {
    setState(() {
      pantallaActual = '';
    });
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;

    return WillPopScope(
      onWillPop: () async {
        if (pantallaActual.isNotEmpty) {
          _volverPrincipal();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 252, 252),
        appBar: AppBar(
          leading: pantallaActual == 'usuarios'
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _volverPrincipal,
                )
              : null,
          title: Text(
            pantallaActual == 'usuarios'
                ? 'Romosso - Cotizador - Usuario: ${usuario?.usuario}'
                : 'Romosso - Cotizador',
          ),
          backgroundColor: const Color.fromARGB(255, 18, 41, 248),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de tareas superior
            Container(
              color: const Color.fromARGB(255, 219, 253, 255),
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),
                  BarraItem(
                    texto: 'Usuarios',
                    onTap: () => _abrirPantalla('usuarios'),
                  ),
                  const BarraItem(texto: 'Contraseña'),
                  const BarraItem(texto: 'Configuración'),
                  const BarraItem(texto: 'Valor IVA'),
                  const BarraItem(texto: 'Catálogos'),
                  const BarraItem(texto: 'Segmentación Pliegos'),
                  const BarraItem(texto: 'Cotizaciones'),
                  const BarraItem(texto: 'Órdenes Trabajo'),
                  const BarraItem(texto: 'Reportes'),
                  const BarraItem(texto: 'Mostrar Ventanas'),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Contenido dinámico según pantalla actual
            Expanded(
              child: pantallaActual == 'usuarios'
                  ? const UsuariosScreen()
                  : Container(
                      color: Colors.grey[400],
                      child: Center(
                        child: Text(
                          'Aqui no se mete nada, o si?',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
