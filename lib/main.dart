import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  //Esta madre  del provider guarda todos los datos, no le muevas
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cotizador Imprenta',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}