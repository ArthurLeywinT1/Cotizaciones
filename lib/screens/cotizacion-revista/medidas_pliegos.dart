// medidas_pliegos.dart
import 'package:flutter/material.dart';

class MedidasPliegos extends StatelessWidget {
  final Map<String, dynamic> pliego; 
  final int piezasTotales;           
  final VoidCallback onChanged;      

  const MedidasPliegos({
    super.key, 
    required this.pliego, 
    required this.piezasTotales,
    required this.onChanged,
  });

  void _ejecutarCalculosProduccion() {
    int piezasPorPliego = int.tryParse(pliego['piezasController'].text) ?? 0;
    int pliegosExtra = int.tryParse(pliego['pliegosExtraCtrl'].text) ?? 0;

    if (piezasPorPliego > 0 && piezasTotales > 0) {
      int cantidadPliegos = (piezasTotales / piezasPorPliego).ceil();
      pliego['cantidadPliegosCtrl'].text = cantidadPliegos.toString();

      int sobrantes = (cantidadPliegos * piezasPorPliego) - piezasTotales;
      pliego['pliegosSobrantesCtrl'].text = sobrantes.toString();

      int totalUtilizar = cantidadPliegos + pliegosExtra;
      pliego['totalPliegosUtilizarCtrl'].text = totalUtilizar.toString();

      double millares = totalUtilizar / 1000.0;
      pliego['millaresImprimirCtrl'].text = millares.toStringAsFixed(2);
    } else {
      pliego['cantidadPliegosCtrl'].text = '0';
      pliego['pliegosSobrantesCtrl'].text = '0';
      pliego['totalPliegosUtilizarCtrl'].text = '0';
      pliego['millaresImprimirCtrl'].text = '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    _ejecutarCalculosProduccion();

    double anchoPantalla = MediaQuery.of(context).size.width;
    // Cálculo dinámico para que los 3 inputs de la fila media se acomoden perfectamente
    double anchoInputTercio = (anchoPantalla > 750) ? (anchoPantalla / 3) - 60 : double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos Técnicos del Pliego (Producción)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
        const SizedBox(height: 12),
        
        // Fila 1: Ancho pliego y Alto pliego
        Row(
          children: [
            Expanded(child: _buildInput('Ancho pliego (cm)', pliego['anchoPliegoCtrl'], esNumerico: true)),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInput(
                'Alto pliego (cm)', 
                pliego['altoPliegoCtrl'], 
                esNumerico: true,
                suffixIcon: const Icon(Icons.search, color: Colors.black87),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Fila 2: Orientación, Tamaño de Trabajo y Pliegos Extra (Merma)
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: anchoInputTercio,
              child: _buildInput('Orientación de piezas', pliego['orientacionCtrl']),
            ),
            SizedBox(
              width: anchoInputTercio,
              child: _buildInput('Tamaño de trabajo', pliego['tamanoTrabajoCtrl']), // 🔥 ¡Regresó con éxito!
            ),
            SizedBox(
              width: anchoInputTercio,
              child: _buildInput(
                'Cantidad pliegos extra (Merma)', 
                pliego['pliegosExtraCtrl'],
                esNumerico: true,
                onChanged: (val) {
                  _ejecutarCalculosProduccion();
                  onChanged();
                }
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text(
          'Resultados de Operación e Impresión',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F)),
        ),
        const SizedBox(height: 12),

        // Fila de Resultados Computados Automáticos
        Row(
          children: [
            Expanded(child: _buildInputResultado('Cantidad de Pliegos', pliego['cantidadPliegosCtrl'])),
            const SizedBox(width: 16),
            Expanded(child: _buildInputResultado('Piezas Sobrantes', pliego['pliegosSobrantesCtrl'])),
          ],
        ),
        const SizedBox(height: 16),

        _buildInputResultado('Total de Pliegos a Utilizar (Con Merma)', pliego['totalPliegosUtilizarCtrl']),
        const SizedBox(height: 16),

        _buildInputResultado('Millares a Imprimir', pliego['millaresImprimirCtrl']),
      ],
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {Widget? suffixIcon, ValueChanged<String>? onChanged, bool esNumerico = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2F7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF79747E), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: esNumerico ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildInputResultado(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true, 
      style: const TextStyle(fontSize: 15, color: Color(0xFF1C1B1F), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: const Color(0xFFE6E1E5).withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E)), borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E)), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}