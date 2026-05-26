import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/auth_provider.dart';
import '/providers/theme_provider.dart';
import '/widgets/barra.dart';
import '/screens/login.dart';
import 'catalogo_operario.dart';
import '/screens/calendario_screen.dart';
class HomeOperarioScreen extends ConsumerStatefulWidget {
  final String area;

  const HomeOperarioScreen({super.key, required this.area});

  @override
  ConsumerState<HomeOperarioScreen> createState() => _HomeOperarioScreenState();
}

class _HomeOperarioScreenState extends ConsumerState<HomeOperarioScreen> {
  // 1. NUEVO ESTADO: Usamos un entero para manejar 3 pestañas
  // 0 = Pendientes, 1 = Historial, 2 = Calendario
  int _tabActual = 0;

  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final themeMode = ref.watch(themeProvider);

    final bool esDesktop = MediaQuery.of(context).size.width > 650;

    return Theme(
      data: themeMode == ThemeMode.dark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ÁREA: ${widget.area.toUpperCase()} - ${usuario?.nombre ?? 'Operario'}',
          ),
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              tooltip: 'Modo oscuro',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        body: Column(
          children: [
            // BARRA DE TAREAS ADAPTATIVA CON 3 OPCIONES
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              height: esDesktop ? 45 : 55,
              width: double.infinity,
              child: esDesktop
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      children: [
                        BarraItem(
                          texto: 'Órdenes Pendientes',
                          onTap: () => setState(() => _tabActual = 0),
                        ),
                        BarraItem(
                          texto: 'Historial de Trabajo',
                          onTap: () => setState(() => _tabActual = 1),
                        ),
                        BarraItem(
                          texto: 'Calendario',
                          onTap: () => setState(() => _tabActual = 2),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        _buildBotonMovil('Pendientes', 0),
                        _buildBotonMovil('Historial', 1),
                        _buildBotonMovil('Calendario', 2),
                      ],
                    ),
            ),

            // CUERPO DE LA PANTALLA
            Expanded(child: _buildContenidoPrincipal()),
          ],
        ),
      ),
    );
  }

  // 2. REFRACTORIZACIÓN: Método limpio para los botones móviles
  Widget _buildBotonMovil(String titulo, int indice) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabActual = indice),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _tabActual == indice ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 3. RENDERIZADO CONDICIONAL: Muestra la tabla o el calendario según la pestaña
  Widget _buildContenidoPrincipal() {
    // Si la pestaña actual es 2, mostramos directamente el calendario
    if (_tabActual == 2) {
      return const CalendarioScreen();
    }

    // Si es 0 o 1, mostramos la tabla con su respectivo título
    final bool esHistorial = _tabActual == 1;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                esHistorial ? "HISTORIAL DE ÓRDENES" : "PENDIENTES POR PROCESAR",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: esHistorial ? Colors.blueGrey : Colors.blue,
                ),
              ),
              Chip(
                label: Text(esHistorial ? "Finalizado" : "En Proceso"),
                avatar: Icon(
                  esHistorial ? Icons.check_circle : Icons.pending,
                  size: 18,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: TablaOperarioScreen(
              area: widget.area,
              verHistorial: esHistorial,
            ),
          ),
        ],
      ),
    );
  }
}