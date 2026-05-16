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

    // MEDIDA EN TIEMPO REAL: Evaluamos el ancho de la ventana actual de la app
    final bool esDesktop = MediaQuery.of(context).size.width > 650;

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
            // BARRA DE TAREAS ADAPTATIVA
            // Si la ventana es grande, muestra tus pestañas tradicionales. Si es tamaño móvil, usa botones más estilizados.
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              height: esDesktop ? 45 : 55, // Un poco más alto en móvil para que sea fácil tocar con el dedo
              width: double.infinity,
              child: esDesktop 
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: [
                      BarraItem(
                        texto: 'Órdenes Pendientes',
                        onTap: () => setState(() => _verHistorial = false),
                      ),
                      BarraItem(
                        texto: 'Historial de Trabajo',
                        onTap: () => setState(() => _verHistorial = true),
                      ),
                    ],
                  )
                : Row( // En tamaño compacto dividimos la barra a la mitad para que no requiera scroll horizontal
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _verHistorial = false),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: !_verHistorial ? Colors.blue : Colors.transparent, width: 3))
                            ),
                            child: const Text('Pendientes', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _verHistorial = true),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _verHistorial ? Colors.blue : Colors.transparent, width: 3))
                            ),
                            child: const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
            
            // CUERPO DE LA PANTALLA
            Expanded(
              child: _buildContenidoPrincipal(esDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoPrincipal(bool esDesktop) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO ADAPTATIVO: Row para PC y Column para celular si la ventana se encoge
          esDesktop 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTituloTexto(),
                  _buildEstadoChip(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTituloTexto(),
                  const SizedBox(height: 8),
                  _buildEstadoChip(),
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

  Widget _buildTituloTexto() {
    return Text(
      _verHistorial ? "HISTORIAL DE ÓRDENES" : "PENDIENTES POR PROCESAR",
      style: TextStyle(
        fontSize: 18, // Reducido ligeramente de 20 a 18 para optimizar espacio
        fontWeight: FontWeight.bold,
        color: _verHistorial ? Colors.blueGrey : Colors.blue,
      ),
    );
  }

  Widget _buildEstadoChip() {
    return Chip(
      label: Text(_verHistorial ? "Finalizado" : "En Proceso"),
      avatar: Icon(
        _verHistorial ? Icons.check_circle : Icons.pending,
        size: 18,
      ),
    );
  }

  Widget _buildTablaDeDatos() {
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Conectando con Neon PostgreSQL...",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}