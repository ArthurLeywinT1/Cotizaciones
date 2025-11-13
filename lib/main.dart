import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = '';

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

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "action": "validar_login",
        "data": {
          "usuario": usuarioController.text.trim(),
          "contrasena": contrasenaController.text
        }
      }),
    );
    setState(() { isLoading = false; });

    if (response.statusCode == 200) {
      final resp = json.decode(response.body);
      if (resp['success'] == true) {
        if ((resp['tipo'] ?? '').toString().toLowerCase() == 'administrador') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(usuario: usuarioController.text))
          );
        } else {
          setState(() {
            error = 'Solo administradores pueden iniciar sesión.';
          });
        }
      } else {
        setState(() { error = 'Usuario o contraseña incorrectos'; });
      }
    } else {
      setState(() { error = 'Error de conexión (${response.statusCode})'; });
    }
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

class HomeScreen extends StatelessWidget {
  final String usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cotizador Romosso')),
      body: Center(
        child: Text('¡Bienvenido, $usuario!\n\nPantalla principal aquí.'),
      ),
    );
  }
}
