// revista.dart
import 'package:flutter/material.dart';
import 'revista_cliente.dart';
import 'cantidad_pliegos.dart';

class RevistaPage extends StatefulWidget {
  const RevistaPage({super.key});

  @override
  State<RevistaPage> createState() => _RevistaPageState();
}

class _RevistaPageState extends State<RevistaPage> {
  int cantidadDePliegos = 0;
  int piezasTotales = 0; // 🔥 Nueva variable para los cálculos matemáticos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Cotización Revista',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // HOJA 1: Datos Cliente (Escucha cambios de pliegos y piezas)
          RevistaCliente(
            onPliegosChanged: (value) {
              setState(() {
                cantidadDePliegos = int.tryParse(value) ?? 0;
              });
            },
            onPiezasChanged: (value) {
              setState(() {
                piezasTotales = int.tryParse(value) ?? 0;
              });
            },
          ),

          const SizedBox(height: 20),

          // HOJA 2: Procesos por Pliego (Recibe ambos datos obligatorios)
          CantidadPliegos(
            numeroDePliegos: cantidadDePliegos,
            piezasTotales: piezasTotales,
          ),
          
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: () {
              // Aquí puedes llamar a una GlobalKey o pasar una función para obtener los datos listos de la DB
            },
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cotización Completa'),
          ),
        ],
      ),
    );
  }
}