import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/barra.dart';
import 'usuario_screen.dart';
import 'cliente_screen.dart';
import 'proveedor_screen.dart';
import 'papel_screen.dart';
import 'maquina_screen.dart';
import 'extra_screen.dart';
import 'descuento_screen.dart';
import 'login.dart';
import 'segmentacion_pliegos_screen.dart';
import 'cotizacion_plana_screen.dart';


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
        return 'Cátalago de Cotizaciones';
      case 'cotizacion_plana':
        return 'Cátalago de Cotización Plana';
      case 'cotizacion_revista':
        return 'Cátalogo de Cotización Revista';
      default:
        return 'Pagina principal';
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
      case 'cotizacion_plana':
        return const CotizacionPlanaScreen();
      case 'cotizacion_revista':
      case 'historial_cotizaciones':
      case 'segmentacion':
        return const SegmentacionPliegosScreen();
      default:
        return _buildDashboard();
    }
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
          leading: pantallaActual.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _volverPrincipal,
                )
              : null,
          title: Text(_getTitulo(usuario?.usuario)),
          backgroundColor: const Color.fromARGB(255, 18, 41, 248),
          foregroundColor: Colors.white,
          elevation: 0,
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
            Container(
              color: const Color.fromARGB(255, 219, 253, 255),
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
                      PopupMenuItem(
                        value: "proveedores",
                        child: Text("Proveedores"),
                      ),
                      PopupMenuItem(value: "papeles", child: Text("Papeles")),
                      PopupMenuItem(
                        value: "descuentos",
                        child: Text("Descuentos Papel"),
                      ),
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
                      PopupMenuItem(
                        value: "catalogo_cotizaciones",
                        child: Text("Cátalago de Cotizaciones"),
                      ),
                      PopupMenuItem(
                        value: "cotizacion_plana",
                        child: Text("Crear Cotización Plana"),
                      ),
                      PopupMenuItem(
                        value: "cotizacion_revista",
                        child: Text("Crear Cotización Revista"),
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
    );
  }

  Widget _buildDashboard() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text('Área principal vacía', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
