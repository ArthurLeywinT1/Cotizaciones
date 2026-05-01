import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/auth_provider.dart';
import '/providers/theme_provider.dart';
import '/widgets/barra.dart';
import '/screens/login.dart';
import '/widgets/tabla.dart'; 

class HomeOperarioScreen extends ConsumerStatefulWidget {
  final String area; // Recibe: offset, diseño, corte, etc.

  const HomeOperarioScreen({super.key, required this.area});

  @override
  ConsumerState<HomeOperarioScreen> createState() => _HomeOperarioScreenState();
}

class _HomeOperarioScreenState extends ConsumerState<HomeOperarioScreen> {
  // Estado para controlar qué lista mostrar
  bool _verHistorial = false;

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

    return Theme(
      data: themeMode == ThemeMode.dark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(
          title: Text('ÁREA: ${widget.area.toUpperCase()} - ${usuario?.usuario ?? 'Operario'}'),
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(
                themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
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
            // BARRA DE TAREAS DINÁMICA
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              height: 45,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: [
                  BarraItem(
                    texto: 'Órdenes Pendientes',
                    onTap: () {
                      setState(() => _verHistorial = false);
                    },
                  ),
                  BarraItem(
                    texto: 'Historial de Trabajo',
                    onTap: () {
                      setState(() => _verHistorial = true);
                    },
                  ),
                ],
              ),
            ),
            
            // CUERPO DE LA PANTALLA
            Expanded(
              child: _buildContenidoPrincipal(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoPrincipal() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título dinámico según el botón presionado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _verHistorial ? "HISTORIAL DE ÓRDENES" : "PENDIENTES POR PROCESAR",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _verHistorial ? Colors.blueGrey : Colors.blue,
                ),
              ),
              // Indicador visual de qué lista estás viendo
              Chip(
                label: Text(_verHistorial ? "Finalizado" : "En Proceso"),
                avatar: Icon(
                  _verHistorial ? Icons.check_circle : Icons.pending,
                  size: 18,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          
          // ESPACIO PARA LA TABLA
          Expanded(
            child: _buildTablaDeDatos(),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaDeDatos() {
    // Aquí es donde harás el ref.watch de tu provider de base de datos
    // pasando widget.area y _verHistorial como filtros.
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _verHistorial ? Icons.history : Icons.assignment_late,
            size: 60,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _verHistorial 
              ? "Cargando órdenes terminadas de ${widget.area}..."
              : "Cargando órdenes pendientes de ${widget.area}...",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Conectando con Neon PostgreSQL...",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}