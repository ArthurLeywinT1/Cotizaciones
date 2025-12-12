import 'package:flutter/material.dart';

class PanelMaquina extends StatefulWidget {
  const PanelMaquina({super.key});

  @override
  State<PanelMaquina> createState() => _PanelMaquinaState();
}

class _PanelMaquinaState extends State<PanelMaquina> {

  /// FUNCIÓN IGUAL A LA DEL PANEL CLIENTES
  void _buscarMaquina() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Buscar Máquina"),
        content: const Text("Aquí irá la búsqueda de máquinas."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO PRINCIPAL
            const Text(
              "Datos Máquina de Impresión a Usar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // NOMBRE DE LA MÁQUINA + BOTÓN SEARCH
            Row(
              children: [
                const Expanded(
                  child: Text("Nombre de la Máquina:"),
                ),

                /// AQUÍ YA FUNCIONA LA LUPA
                IconButton(
                  onPressed: _buscarMaquina,
                  icon: const Icon(Icons.search),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 16),

            // ===============================================
            // BLOQUE NUEVO: TINTAS A UTILIZAR
            // ===============================================
            const Text("Tintas a Utilizar en la Impresión:"),
            SizedBox(height: 4),

            Row(
              children: [
                SizedBox(
                  width: 55,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                const Text("X"),
                SizedBox(width: 6),
                SizedBox(
                  width: 55,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Checkbox(value: false, onChanged: (_) {}),
                const Text("Barniz de Máquina"),
              ],
            ),

            const SizedBox(height: 20),

            // CANTIDAD TOTAL TINTAS
            const Text("Cantidad Total Tintas:"),
            const SizedBox(height: 4),
            const SizedBox(
              width: 80,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DOS COLUMNAS (FRONTAL / REVERSO)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Costo por Tinta Frontal:"),
                      const SizedBox(height: 4),
                      const _MonedaInput(),

                      const SizedBox(height: 12),

                      const Text("Costo Tintas Frontal:"),
                      const SizedBox(height: 4),
                      const _MonedaInput(),
                    ],
                  ),
                ),

                const SizedBox(width: 25),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Costo por Tinta Reverso:"),
                      const SizedBox(height: 4),
                      const _MonedaInput(),

                      const SizedBox(height: 12),

                      const Text("Costo Tintas Reverso:"),
                      const SizedBox(height: 4),
                      const _MonedaInput(),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // COSTO TOTAL TINTAS
            const Text(
              "Costo Total Tintas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const _MonedaInput(),

            const SizedBox(height: 20),

            // CANTIDAD PLACAS
            const Text("Cantidad Placas:"),
            const SizedBox(height: 4),
            const SizedBox(
              width: 80,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                const Text("Cambiar Precio\nPor Placa:"),
              ],
            ),

            const SizedBox(height: 16),

            // COSTO BARNIZ
            const Text(
              "Costo Barniz de Máquina:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const _MonedaInput(),

            const SizedBox(height: 16),

            const Text("Costo por Placa:"),
            const SizedBox(height: 4),
            const _MonedaInput(),

            const SizedBox(height: 16),

            const Text(
              "Costo Total Placas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const _MonedaInput(),
          ],
        ),
      ),
    );
  }
}

class _MonedaInput extends StatelessWidget {
  const _MonedaInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        prefixText: "\$ ",
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
