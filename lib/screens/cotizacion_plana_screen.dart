import 'package:flutter/material.dart';

class CotizacionPlanaScreen extends StatelessWidget {
  const CotizacionPlanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panelDatosCliente(context),
            _panelPliegoUsar(),
            _panelPapelUsar(),
            _panelCostoPapel(),
            _panelMaquinaImpresion(),
            _panelAcabados(),
            _panelSuaje(),
            _panelAcabadosEspeciales(),
            _panelCostoTotal(),

            const SizedBox(height: 100),

            // ------------------
            // BOTONES FINALES
            // ------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _boton("Guardar Cotización", Colors.green),
                _boton("Cancelar", Colors.red),
                _boton("Modificar Descuentos", Colors.blueGrey),
                _boton("Recotizar", Colors.orange),
                _boton("Generar Orden Trabajo", Colors.blue),
                _boton("Cancelar Cotización", Colors.redAccent),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PANEL — DATOS DEL CLIENTE (COMPLETO + TINTAS)
  // =====================================================
  Widget _panelDatosCliente(BuildContext context) {
    return _panel(
      "Datos del Cliente y del Trabajo Solicitado",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------
          // RAZON SOCIAL + ICONOS
          // -----------------------------------
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Razón Social Cliente",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () => _abrirBusquedaCliente(context),
                icon: const Icon(Icons.search),
                tooltip: "Buscar Cliente",
              ),

              IconButton(
                onPressed: () => _abrirAgregarCliente(context),
                icon: const Icon(Icons.add),
                tooltip: "Agregar Cliente",
              ),
            ],
          ),

          const SizedBox(height: 16),

          _textField("Tipo Trabajo"),
          _textField("Descripción del Trabajo"),

          // -----------------------------------
          // MEDIDAS DEL TRABAJO
          // -----------------------------------
          const Text("Medidas del Trabajo (cm):"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _textField("Ancho")),
              const SizedBox(width: 10),
              const Text("X"),
              const SizedBox(width: 10),
              Expanded(child: _textField("Alto")),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text("Tamaño Medianil (cm):"),
              const SizedBox(width: 15),
              SizedBox(width: 90, child: _textField("0.5")),
            ],
          ),

          const SizedBox(height: 16),

          // -----------------------------------
          // MEDIDAS FINALES
          // -----------------------------------
          const Text("Medidas Finales del Trabajo (cm):"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _textField("Ancho Final")),
              const SizedBox(width: 10),
              const Text("X"),
              const SizedBox(width: 10),
              Expanded(child: _textField("Alto Final")),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Suaje"),
            ],
          ),

          const SizedBox(height: 16),

          // =====================================================
          // ⭐⭐⭐ TINTAS A UTILIZAR EN LA IMPRESIÓN (COMPLETO)
          // =====================================================
          const Text(
            "Tintas a Utilizar en la Impresión:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const SizedBox(width: 10),
              SizedBox(width: 80, child: _textField("")),
              const Text(" X"),
              const SizedBox(width: 10),
              SizedBox(width: 80, child: _textField("")),
              const SizedBox(width: 20),
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Barniz de Máquina"),
            ],
          ),

          const SizedBox(height: 10),

          // Cantidad Impresiones
          const Text("Cantidad Impresiones Pedidas por el Cliente:"),
          SizedBox(width: 150, child: _textField("")),

          const SizedBox(height: 10),

          const Text(
            "Cantidad de Impresiones:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 150, child: _textField("")),

          const SizedBox(height: 12),

          // Acabados que estaban en la imagen
          _check("Barniz UV a Registro"),
          _check("Plastificado Brillante"),
          _check("Plastificado Mate"),
          _check("Barniz UV Brillante Plasta"),
          _check("Barniz UV Mate Plasta"),

          const SizedBox(height: 12),

          // Prueba de color
          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Prueba de Color"),
            ],
          ),

          Row(
            children: [
              const Text("Porcentaje para Prueba Color: "),
              const SizedBox(width: 10),
              SizedBox(width: 80, child: _textField("%")),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                "Costo Prueba de Color:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20),
              const Text("\$"),
              const SizedBox(width: 5),
              SizedBox(width: 120, child: _textField("")),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DIALOGOS
  // =====================================================
  void _abrirBusquedaCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buscar Cliente"),
        content: const Text("Aquí aparecerá la búsqueda de clientes (sin BD aún)."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  void _abrirAgregarCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Cliente"),
        content: const Text("Formulario para agregar cliente (sin BD aún)."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  // =====================================================
  // RESTO DE PANELES
  // =====================================================
  // =====================================================
// PANEL CORREGIDO — DATOS DEL PLIEGO (IDÉNTICO A LA IMAGEN)
// =====================================================
Widget _panelPliegoUsar() {
  return _panel(
    "Datos del Pliego a Usar",
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Medidas del Pliego de Papel a Utilizar (cm):"),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(child: _textField("Ancho")),
            const SizedBox(width: 10),
            const Text("X"),
            const SizedBox(width: 10),
            Expanded(child: _textField("Alto")),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Posición Piezas por Pliego:"),
                  _smallTextField(""),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Piezas por Pliego:"),
                  _smallTextField(""),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text("Tamaños por Pliego:"),
        _smallTextField(""),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cantidad de Pliegos:"),
                  _smallTextField(""),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pliegos Sobrantes:"),
                  _smallTextField(""),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text("Total de Pliegos a Utilizar:"),
        _smallTextField(""),

        const SizedBox(height: 16),

        const Text("Millares a Imprimir:"),
        _smallTextField(""),
      ],
    ),
  );
  
}

  Widget _panelPapelUsar() {
    return _panel(
      "Datos del Papel a Usar",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField("Nombre Papel"),
          _textField("Tipo Papel"),
          Row(
            children: [
              Expanded(child: _textField("Medida Papel a Comprar")),
              const SizedBox(width: 10),
              Expanded(child: _textField("Peso Papel (g)")),
            ],
          ),
          _textField("Proveedor del Papel"),
          _textField("Costo por Millar del Papel"),
          _textField("Cantidad de Pliegos a Comprar"),
        ],
      ),
    );
  }

  Widget _panelCostoPapel() {
    return _panel(
      "Costo del Papel a Usar",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField("Costo Papel Sin Descuento"),
          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Usar descuento general del papel"),
            ],
          ),
          _textField("Descuento a Aplicar (%)"),
          _textField("Costo Papel Sin IVA"),
          _textField("Costo Papel Con IVA"),
        ],
      ),
    );
  }

  Widget _panelMaquinaImpresion() {
    return _panel(
      "Datos de Máquina de Impresión a Usar",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField("Nombre de la Máquina"),
          _textField("Cantidad Total de Tintas"),
          Row(
            children: [
              Expanded(child: _textField("Costo por Tinta Frontal")),
              const SizedBox(width: 10),
              Expanded(child: _textField("Costo por Tinta Reverso")),
            ],
          ),
          _textField("Costo Total de Tintas"),
          Row(
            children: [
              Expanded(child: _textField("Cantidad Placas")),
              const SizedBox(width: 10),
              Expanded(child: _textField("Costo por Placa")),
            ],
          ),
          _textField("Costo Total de Placas"),
        ],
      ),
    );
  }

  Widget _panelAcabados() {
    return _panel(
      "Acabados",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _check("Barniz UV a Registro"),
          _check("Plastificado Brillante"),
          _check("Plastificado Mate"),
          _check("Barniz UV Brillante a Placa"),
          _check("Barniz UV Mate a Placa"),
        ],
      ),
    );
  }

  Widget _panelSuaje() {
    return _panel(
      "Datos Suaje, Suajado",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField("Tamaño Suaje por Pieza (cm)"),
          _textField("Costo del Suaje por cm²"),
          _textField("Costo Total Suaje"),
          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Duplicar costo suajado"),
            ],
          ),
          _textField("Costo Total Suajado"),
          _textField("Gastos de Entrega"),
        ],
      ),
    );
  }

  Widget _panelAcabadosEspeciales() {
    return _panel(
      "Acabados Especiales",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _check("Acabado Especial 1"),
          _check("Acabado Especial 2"),
          _check("Acabado Especial 3"),
          _check("Acabado Especial 4"),
          _check("Acabado Especial 5"),
        ],
      ),
    );
  }

  Widget _panelCostoTotal() {
    return _panel(
      "Costo Total",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField("Costo Total"),
          _textField("Margen de Utilidad (%)"),
          _textField("Descuento a Aplicar (%)"),
          _textField("Días de Entrega"),
          _textField("Precio con Utilidad"),
          _textField("Precio con Descuento"),
          _textField("Precio con Entrega"),
          _textField("Precio Unitario"),
          _textField("IVA"),
          _textField("Precio con IVA"),
        ],
      ),
    );
  }

  // =====================================================
  // WIDGETS BASE
  // =====================================================
  Widget _panel(String titulo, Widget contenido) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            contenido,
          ],
        ),
      ),
    );
  }

  Widget _textField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
        ),
      ),
    );
  }

  Widget _check(String text) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        Text(text),
      ],
    );
  }

  Widget _boton(String texto, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: () {},
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
    Widget _smallTextField(String label) {
    return SizedBox(
      height: 38,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true, 
        ),
      ),
    );
  }
}

