import 'package:flutter/material.dart';

class OrdenTrabajoScreen extends StatelessWidget {
  const OrdenTrabajoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Orden de Trabajo',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
