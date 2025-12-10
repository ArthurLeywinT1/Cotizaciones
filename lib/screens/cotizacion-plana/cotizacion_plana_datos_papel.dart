import 'package:flutter/material.dart';

class PanelDatosPapel extends StatelessWidget {
  final TextEditingController totalPliegosController;

  const PanelDatosPapel({
    super.key,
    required this.totalPliegosController,
  });

  // ============================================
  // MÉTODO PARA ABRIR LA BASE DE DATOS DEL PAPEL
  // ============================================
  void _buscarPapel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Buscar Papel"),
        content: const Text(
          "Aquí se abrirá tu base de datos de papeles.\n"
          "(Luego se reemplaza por tu módulo completo)",
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Datos del Papel a Usar:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),

          // ================= NOMBRE PAPEL ====================
          Row(
            children: [
              const SizedBox(
                width: 120,
                child: Text("Nombre Papel:"),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 🔍 ← YA FUNCIONA
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _buscarPapel(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ================= TIPO PAPEL ====================
          Row(
            children: [
              const SizedBox(
                width: 120,
                child: Text("Tipo Papel:"),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ================= MEDIDAS / PESO ====================
          Row(
            children: [
              const SizedBox(
                width: 180,
                child: Text("Medidas Papel a Comprar (cm):"),
              ),

              SizedBox(
                width: 70,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text("X"),
              const SizedBox(width: 10),

              SizedBox(
                width: 70,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 28),

              const SizedBox(
                width: 120,
                child: Text("Peso del Papel (g):"),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ================= PROVEEDOR ====================
          Row(
            children: [
              const SizedBox(
                width: 150,
                child: Text("Proveedor del Papel:"),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ================= COSTO POR MILLAR ====================
          Row(
            children: [
              const SizedBox(
                width: 170,
                child: Text("Costo por Millar del Papel:"),
              ),
              const Text("\$"),
              const SizedBox(width: 6),
              SizedBox(
                width: 120,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ================= CANTIDAD DE PLIEGOS ====================
          const Text(
            "Cantidad de Pliegos a Comprar:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: 200,
            child: TextField(
              controller: totalPliegosController,   // ← ¡AQUÍ ESTÁ LO IMPORTANTE!
              enabled: false,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
