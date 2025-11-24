import 'package:cotizador/screens/usuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
<<<<<<< HEAD
import '../Widgets/barra.dart';
=======
import '../widgets/barra.dart';

// PANTALLAS
import 'usuarios_screen.dart';
import 'clientes_screen.dart';
import 'proveedores_screen.dart';
import 'papel_screen.dart';
import 'descuentos_papel_screen.dart';
import 'maquinas_screen.dart';
import 'extras_screen.dart';
import 'segmentacion_pliegos_screen.dart';
import 'catalogo_cotizaciones_screen.dart';
import 'cotizacion_plana_screen.dart';
import 'cotizacion_revista_screen.dart';
>>>>>>> origin/funcional

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String pantallaActual = '';

  void _abrir(String pantalla) {
    setState(() => pantallaActual = pantalla);
  }

  void _volver() {
    setState(() => pantallaActual = '');
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }

  String _tituloPantalla() {
    switch (pantallaActual) {
      case "usuarios": return "Usuarios";
      case "clientes": return "Clientes";
      case "proveedores": return "Proveedores";
      case "papel": return "Papel";
      case "descuentos_papel": return "Descuentos Papel";
      case "maquinas": return "Maquinas";
      case "extras": return "Extras";
      case "segmentacion": return "Segmentación Pliegos";
      case "catalogo_cotizaciones": return "Catálogo Cotizaciones";
      case "cotizacion_plana": return "Crear Cotización Plana";
      case "cotizacion_revista": return "Crear Cotización Revista";
      default: return "Pantalla Principal";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario?.usuario ?? "";

    return WillPopScope(
      onWillPop: () async {
        if (pantallaActual.isNotEmpty) {
          _volver();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          leading: pantallaActual.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _volver,
                )
              : null,

          title: Text("Romosso - Cotizador - ${_tituloPantalla()}"),

          backgroundColor: const Color.fromARGB(255, 18, 41, 248),

          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Cerrar sesión",
              onPressed: _logout,
            )
          ],
        ),

        body: Column(
          children: [
<<<<<<< HEAD
=======
            // ------- BARRA SUPERIOR ----------
>>>>>>> origin/funcional
            Container(
              color: const Color.fromARGB(255, 212, 249, 255),
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),

                  BarraItem(texto: "Usuarios", onTap: () => _abrir("usuarios")),

                  PopupMenuButton<String>(
                    child: _barraTexto("Catálogos"),
                    onSelected: (opcion) => _abrir(opcion),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "clientes", child: Text("Clientes")),
                      PopupMenuItem(value: "proveedores", child: Text("Proveedores")),
                      PopupMenuItem(value: "papel", child: Text("Papel")),
                      PopupMenuItem(value: "descuentos_papel", child: Text("Descuentos Papel")),
                      PopupMenuItem(value: "maquinas", child: Text("Maquinas")),
                      PopupMenuItem(value: "extras", child: Text("Extras")),
                    ],
                  ),

                  BarraItem(
                    texto: "Segmentación Pliegos",
                    onTap: () => _abrir("segmentacion"),
                  ),

                  PopupMenuButton<String>(
                    child: _barraTexto("Cotizaciones"),
                    onSelected: (opcion) => _abrir(opcion),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "catalogo_cotizaciones", child: Text("Catálogo Cotizaciones")),
                      PopupMenuItem(value: "cotizacion_plana", child: Text("Crear Cotización Plana")),
                      PopupMenuItem(value: "cotizacion_revista", child: Text("Crear Cotización Revista")),
                    ],
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),
<<<<<<< HEAD
            Expanded(
              child: pantallaActual == 'usuarios'
                  ? const UsuarioScreen()
=======

            // ------- CONTENIDO ----------
            Expanded(
              child: pantallaActual == "usuarios"
                  ? const UsuariosScreen()
                  : pantallaActual == "clientes"
                      ? const ClientesScreen()
                  : pantallaActual == "proveedores"
                      ? const ProveedoresScreen()
                  : pantallaActual == "papel"
                      ? const PapelScreen()
                  : pantallaActual == "descuentos_papel"
                      ? const DescuentosPapelScreen()
                  : pantallaActual == "maquinas"
                      ? const MaquinasScreen()
                  : pantallaActual == "extras"
                      ? const ExtrasScreen()
                  : pantallaActual == "segmentacion"
                      ? SegmentacionPliegosScreen()
                  : pantallaActual == "catalogo_cotizaciones"
                      ? const CatalogoCotizacionesScreen()
                  : pantallaActual == "cotizacion_plana"
                      ? const CotizacionPlanaScreen()
                  : pantallaActual == "cotizacion_revista"
                      ? const CotizacionRevistaScreen()
>>>>>>> origin/funcional
                  : Container(
                       color: Colors.grey[300],
                       child: const Center(
                         child: Text(
                           "Área principal vacía",
                           style: TextStyle(fontSize: 20),
                         ),
                       ),
                     ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraTexto(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
