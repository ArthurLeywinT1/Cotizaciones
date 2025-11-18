import 'package:flutter/material.dart';

// Usuarios de prueba
const usuariosDemo = {
  'admin': {'contrasena': '1234', 'tipo': 'administrador'},
  'usuario1': {'contrasena': 'pass1', 'tipo': 'usuario'},
};

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool isLoading = false;
  String error = '';

  Future<void> login() async {
    setState(() { isLoading = true; error = ''; });
    await Future.delayed(Duration(milliseconds: 500)); // Simula demora

    final usuario = usuarioController.text.trim();
    final contrasena = contrasenaController.text;
    if (usuariosDemo.containsKey(usuario) &&
        usuariosDemo[usuario]!['contrasena'] == contrasena) {
      if (usuariosDemo[usuario]!['tipo'] == 'administrador') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(usuario: usuario)),
        );
      } else {
        setState(() {
          error = 'Solo administradores pueden iniciar sesión.';
        });
      }
    } else {
      setState(() { error = 'Usuario o contraseña incorrectos'; });
    }
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Iniciar Sesión', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 20),
                  TextField(
                    controller: usuarioController,
                    decoration: InputDecoration(labelText: 'Usuario'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: contrasenaController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  if (error.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(error, style: TextStyle(color: Colors.red)),
                    ),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: login,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            child: Text('Ingresar'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String pantallaActual = '';

  void abrirUsuarios() {
    setState(() {
      pantallaActual = 'usuarios';
    });
  }

  void volverPrincipal() {
    setState(() {
      pantallaActual = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      appBar: AppBar(
        leading: pantallaActual == 'usuarios'
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: volverPrincipal,
              )
            : null,
        title: Text(pantallaActual == 'usuarios'
            ? 'Romosso - Cotizador - Usuario: ${widget.usuario}'
            : 'Romosso - Cotizador'),
        backgroundColor: const Color.fromARGB(255, 18, 41, 248),
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
                SizedBox(width: 8),
                BarraItem(
                  texto: 'Usuarios',
                  onTap: abrirUsuarios,
                ),
                BarraItem(texto: 'Contraseña'),
                BarraItem(texto: 'Configuración'),
                BarraItem(texto: 'Valor IVA'),
                BarraItem(texto: 'Catálogos'),
                BarraItem(texto: 'Segmentación Pliegos'),
                BarraItem(texto: 'Cotizaciones'),
                BarraItem(texto: 'Órdenes Trabajo'),
                BarraItem(texto: 'Reportes'),
                BarraItem(texto: 'Mostrar Ventanas'),
                SizedBox(width: 8),
              ],
            ),
          ),
          // Contenido dinámico según pantalla actual
          Expanded(
            child: pantallaActual == 'usuarios'
                ? UsuariosScreen()
                : Container(
                    color: Colors.grey[400],
                    child: Center(
                      child: Text(
                        'Área principal vacía\n(aquí irá tu cotizador)',
                        style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class BarraItem extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  const BarraItem({super.key, required this.texto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          texto,
          style: TextStyle(
            color: const Color.fromARGB(255, 33, 33, 33),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () {}, child: Text('Agregar')),
              ElevatedButton(onPressed: () {}, child: Text('Modificar')),
              ElevatedButton(onPressed: () {}, child: Text('Eliminar')),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
