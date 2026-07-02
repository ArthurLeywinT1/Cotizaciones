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
import 'segmentacion.dart';
import 'cotizacion-plana/cotizacion_plana.dart';
import 'cotizacion_screen.dart';
import 'login.dart';
import '../orden de trabajo/ordenTrabajo.dart';
import '../orden de trabajo/catalogo_OT.dart';
import 'calendario_screen.dart';
import 'cotizacion-revista/revista.dart';

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
      case 'cotizacion_revista': // 🔥 2. TÍTULO PARA LA NUEVA PANTALLA
        return 'Crear Cotización Revista';
      case 'catalogo_ot':
        return 'Catálogo de Órdenes de Trabajo';
      case 'OrdenTrabajo':
        return 'Crear / Editar Orden de Trabajo';
      case 'calendario': 
        return 'Calendario de Actividades';
      default:
        return 'Romosso - Cotizador';
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
        return CotizacionPlanaScreen(
          onNavigateToCatalog: () => _abrirPantalla('catalogo_cotizaciones'),
        );
      case 'cotizacion_revista': // 🔥 3. ENRUTAMIENTO HACIA REVISTAPAGE
        return const RevistaPage(); 
      case 'catalogo_ot':
        return const CatalogoOTScreen();
      case 'OrdenTrabajo':
        return const OrdenTrabajoScreen(cotizacionId: '');
      case 'calendario': 
        return const CalendarioScreen();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final themeMode = ref.watch(themeProvider);

    final bool esDesktop = MediaQuery.of(context).size.width > 750;

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
                : (!esDesktop 
                    ? Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      )
                    : null),
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
          
          drawer: !esDesktop ? Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    'Menú Cotizador\nUsuario: ${usuario?.usuario ?? 'Admin'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 18,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Usuarios'),
                  onTap: () { Navigator.pop(context); _abrirPantalla('usuarios'); },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Catálogos'),
                  children: [
                    ListTile(title: const Text('Clientes'), onTap: () { Navigator.pop(context); _abrirPantalla('clientes'); }),
                    ListTile(title: const Text('Proveedores'), onTap: () { Navigator.pop(context); _abrirPantalla('proveedores'); }),
                    ListTile(title: const Text('Papeles'), onTap: () { Navigator.pop(context); _abrirPantalla('papeles'); }),
                    ListTile(title: const Text('Descuentos Papel'), onTap: () { Navigator.pop(context); _abrirPantalla('descuentos'); }),
                    ListTile(title: const Text('Máquinas'), onTap: () { Navigator.pop(context); _abrirPantalla('maquinas'); }),
                    ListTile(title: const Text('Extras'), onTap: () { Navigator.pop(context); _abrirPantalla('extras'); }),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('Segmentación'),
                  onTap: () { Navigator.pop(context); _abrirPantalla('segmentacion'); },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.request_quote),
                  title: const Text('Cotizaciones'),
                  children: [
                    ListTile(title: const Text('Catálogo'), onTap: () { Navigator.pop(context); _abrirPantalla('catalogo_cotizaciones'); }),
                    ListTile(title: const Text('Crear Plana'), onTap: () { Navigator.pop(context); _abrirPantalla('cotizacion_plana'); }),
                    ListTile(title: const Text('Crear Revista'), onTap: () { Navigator.pop(context); _abrirPantalla('cotizacion_revista'); }), // 🔥 4a. NUEVA OPCIÓN EN EL DRAWER (MÓVIL)
                  ],
                ),
                ExpansionTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Órdenes de Trabajo'),
                  children: [
                    ListTile(title: const Text('Catálogo'), onTap: () { Navigator.pop(context); _abrirPantalla('catalogo_ot'); }),
                    ListTile(title: const Text('Crear Orden'), onTap: () { Navigator.pop(context); _abrirPantalla('OrdenTrabajo'); }),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: const Text('Calendario de Actividades'),
                  onTap: () { Navigator.pop(context); _abrirPantalla('calendario'); },
                ),
              ],
            ),
          ) : null,
          
          body: Column(
            children: [
              if (esDesktop)
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
                          PopupMenuItem(value: "clientes", child: Text("Clientes")),
                          PopupMenuItem(value: "proveedores", child: Text("Proveedores")),
                          PopupMenuItem(value: "papeles", child: Text("Papeles")),
                          PopupMenuItem(value: "descuentos", child: Text("Descuentos Papel")),
                          PopupMenuItem(value: "maquinas", child: Text("Máquinas")),
                          PopupMenuItem(value: "extras", child: Text("Extras")),
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
                          PopupMenuItem(value: "catalogo_cotizaciones", child: Text("Catálogo de Cotizaciones")),
                          PopupMenuItem(value: "cotizacion_plana", child: Text("Crear Cotización Plana")),
                          PopupMenuItem(value: "cotizacion_revista", child: Text("Crear Cotización Revista")), // 🔥 4b. NUEVA OPCIÓN EN EL DROPDOWN (PC)
                        ],
                        onSelected: _abrirPantalla,
                      ),
                      BarraDropdown(
                        titulo: "Órdenes de Trabajo",
                        opciones: const [
                          PopupMenuItem(value: "catalogo_ot", child: Text("Catálogo de Órdenes de Trabajo")),
                          PopupMenuItem(value: "OrdenTrabajo", child: Text("Crear Orden de Trabajo")),
                        ],
                        onSelected: _abrirPantalla,
                      ),
                      BarraItem(
                        texto: 'Calendario de Actividades',
                        onTap: () => _abrirPantalla('calendario'),
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