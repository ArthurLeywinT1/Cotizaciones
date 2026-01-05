import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/barra.dart';

import 'usuario_screen.dart';
import 'cliente_screen.dart';
import 'proveedor_screen.dart';
import 'papel_screen.dart';
import 'maquina_screen.dart';
import 'extra_screen.dart';
import 'descuento_screen.dart';
import 'segmentacion_pliegos_screen.dart';
import 'cotizacion-plana/cotizacion_plana_screen.dart';
import 'catalogo_cotizaciones_screen.dart';
import 'login.dart';

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

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  String _getTitulo(String? usuarioNombre) {
    switch (pantallaActual) {
      case 'usuarios':
        return 'Gestión de Usuarios';
      case 'clientes':
        return 'Catálogo de Clientes';
      case 'proveedores':
        return 'Catálogo de Proveedores';
      case 'papeles':
        return 'Catálogo de Papeles';
      case 'descuentos':
        return 'Descuentos de Papel';
      case 'maquinas':
        return 'Catálogo de Máquinas';
      case 'extras':
        return 'Catálogo de Extras';
      case 'segmentacion':
        return 'Segmentación de Pliegos';
      case 'catalogo_cotizaciones':
        return 'Catálogo de Cotizaciones';
      case 'cotizacion_plana':
        return 'Catálogo de Cotización Plana';
      default:
        return 'Romosso - Cotizador - Usuario: ${usuarioNombre ?? 'Desconocido'}';
    }
  }

  Widget _construirPantallaActual() {
    switch (pantallaActual) {
      case 'usuarios':
        return const UsuarioScreen();
      case 'clientes':
        return const ClienteScreen();
      case 'proveedores':
        return const ProveedorScreen();
      case 'papeles':
        return const PapelScreen();
      case 'descuentos':
        return const DescuentoScreen();
      case 'maquinas':
        return const MaquinaScreen();
      case 'extras':
        return const ExtraScreen();
      case 'segmentacion':
        return const SegmentacionPliegosScreen();
      case 'catalogo_cotizaciones':
        return const CatalogoCotizacionesScreen();
      case 'cotizacion_plana':
        return const CotizacionPlanaScreen();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final themeMode = ref.watch(themeProvider);

    return WillPopScope(
      onWillPop: () async {
        if (pantallaActual.isNotEmpty) {
          _volverPrincipal();
          return false;
        }
        return true;
      },
      child: Theme(
        data: themeMode == ThemeMode.dark
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData.light(useMaterial3: true),
        child: Scaffold(
          appBar: AppBar(
            leading: pantallaActual.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _volverPrincipal,
                  )
                : null,
            title: Text(_getTitulo(usuario?.usuario)),
            actions: [
              IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                tooltip: 'Modo oscuro',
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
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
              Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  children: [
                    BarraItem(
                      texto: 'Usuarios',
                      onTap: () => _abrirPantalla('usuarios'),
                    ),
                    BarraDropdown(
                      titulo: "Catálogos",
                      opciones: const [
                        PopupMenuItem(
                            value: "clientes", child: Text("Clientes")),
                        PopupMenuItem(
                            value: "proveedores",
                            child: Text("Proveedores")),
                        PopupMenuItem(
                            value: "papeles", child: Text("Papeles")),
                        PopupMenuItem(
                            value: "descuentos",
                            child: Text("Descuentos Papel")),
                        PopupMenuItem(
                            value: "maquinas", child: Text("Máquinas")),
                        PopupMenuItem(
                            value: "extras", child: Text("Extras")),
                      ],
                      onSelected: _abrirPantalla,
                    ),
                    BarraItem(
                      texto: 'Segmentación',
                      onTap: () => _abrirPantalla('segmentacion'),
                    ),
                    BarraDropdown(
                      titulo: "Cotizaciones",
                      opciones: const [
                        PopupMenuItem(
                          value: "catalogo_cotizaciones",
                          child: Text("Catálogo de Cotizaciones"),
                        ),
                        PopupMenuItem(
                          value: "cotizacion_plana",
                          child: Text("Crear Cotización Plana"),
                        ),
                      ],
                      onSelected: _abrirPantalla,
                    ),
                  ],
                ),
              ),
              Expanded(child: _construirPantallaActual()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Center(
      child: Text(
        'Área principal vacía',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
