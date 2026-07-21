// revista_cliente.dart
import 'package:flutter/material.dart';

class RevistaCliente extends StatefulWidget {
  final Function(String)? onPliegosChanged;
  final Function(String)? onPiezasChanged; // 🔥 Agregado al contrato

  const RevistaCliente({super.key, this.onPliegosChanged, this.onPiezasChanged});

  @override
  State<RevistaCliente> createState() => _RevistaClienteState();
}

// 1. Se agregó "with AutomaticKeepAliveClientMixin" para preservar el estado al hacer scroll
class _RevistaClienteState extends State<RevistaCliente> with AutomaticKeepAliveClientMixin {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController proyectoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController piezasController = TextEditingController();
  final TextEditingController pliegosController = TextEditingController(text: '2');
  final TextEditingController anchoPliegoCtrl = TextEditingController();
  final TextEditingController altoPliegoCtrl = TextEditingController();

  // 2. Este getter es obligatorio para que el Mixin funcione y no borre los datos
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // 3. Es obligatorio llamar a super.build(context) al inicio
    super.build(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos del cliente y del trabajo solicitado',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).colorScheme.primary
              ),
            ),
            const SizedBox(height: 20),

            // FILA 1: RAZÓN SOCIAL
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: clienteController,
                    decoration: const InputDecoration(
                      labelText: 'Razón Social Cliente', 
                      border: OutlineInputBorder(), 
                      prefixIcon: Icon(Icons.business)
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FILA 2: PROYECTO Y DESCRIPCIÓN
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: _calcularAncho(context),
                  child: TextFormField(
                    controller: proyectoController, 
                    decoration: const InputDecoration(labelText: 'Proyecto', border: OutlineInputBorder())
                  ),
                ),
                SizedBox(
                  width: _calcularAncho(context),
                  child: TextFormField(
                    controller: descripcionController, 
                    decoration: const InputDecoration(labelText: 'Descripción del proyecto', border: OutlineInputBorder())
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FILA 3: PIEZAS Y PLIEGOS
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: _calcularAncho(context),
                  child: TextFormField(
                    controller: piezasController,
                    keyboardType: TextInputType.number,
                    onChanged: widget.onPiezasChanged, // 🔥 Notifica cambio de piezas
                    decoration: const InputDecoration(labelText: 'Piezas totales solicitadas', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: _calcularAncho(context),
                  child: TextFormField(
                    controller: pliegosController,
                    keyboardType: TextInputType.number,
                    onChanged: widget.onPliegosChanged, 
                    decoration: const InputDecoration(labelText: 'Cantidad de pliegos', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: _calcularAncho(context),
                  child: TextFormField(
                    controller: anchoPliegoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ancho del trabajo final', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(
                  width: _calcularAncho(context),
                  child: TextFormField(
                    controller: altoPliegoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Alto del trabajo final', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calcularAncho(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    if (anchoPantalla > 750) return (anchoPantalla / 2) - 60;
    return anchoPantalla;
  }
}