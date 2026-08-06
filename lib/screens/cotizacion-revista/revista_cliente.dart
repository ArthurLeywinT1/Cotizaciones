// revista_cliente.dart
import 'package:flutter/material.dart';
// Asegúrate de importar la ubicación correcta de tu DialogoSelectorCliente y Cliente model
import '../../screens/cotizacion-plana/buscador_cliente.dart'; 
import '../../models/cliente_model.dart'; 

class RevistaCliente extends StatefulWidget {
  final Function(String)? onPliegosChanged;
  final Function(String)? onPiezasChanged;
  final Function(Cliente)? onClienteSeleccionado; // Opcional: si deseas notificar el cliente al padre

  final String? clienteIdInicial;
  final String? clienteNombreInicial;
  final String? proyectoInicial;
  final String? descripcionInicial;
  final double? anchoMedidaInicial;
  final double? altoMedidaInicial;
  final int? cantidadPliegosInicial;
  final int? piezasTotalesInicial;

  const RevistaCliente({
    super.key,
    this.onPliegosChanged,
    this.onPiezasChanged,
    this.onClienteSeleccionado,
    this.clienteIdInicial,
    this.clienteNombreInicial,
    this.proyectoInicial,
    this.descripcionInicial,
    this.anchoMedidaInicial,
    this.altoMedidaInicial,
    this.cantidadPliegosInicial,
    this.piezasTotalesInicial,
  });


  @override
  State<RevistaCliente> createState() => RevistaClienteState();
}

class RevistaClienteState extends State<RevistaCliente> with AutomaticKeepAliveClientMixin {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController proyectoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController piezasController = TextEditingController();
  final TextEditingController pliegosController = TextEditingController();
  final TextEditingController anchoPliegoCtrl = TextEditingController();
  final TextEditingController altoPliegoCtrl = TextEditingController();

  Cliente? clienteSeleccionado;

  @override
  void initState() {
    super.initState();

    // AGREGAR: inicializar si hay valores iniciales
    if (widget.clienteIdInicial != null) {
      // Aquí deberías cargar el cliente completo desde un provider o dejar solo el nombre
      clienteSeleccionado = Cliente(
        id: widget.clienteIdInicial!,
        razonSocial: widget.clienteNombreInicial ?? '',
        rfc: '',
      );
      clienteController.text = widget.clienteNombreInicial ?? '';
    }

    if (widget.proyectoInicial != null) {
      proyectoController.text = widget.proyectoInicial!;
    }

    if (widget.descripcionInicial != null) {
      descripcionController.text = widget.descripcionInicial!;
    }

    if (widget.piezasTotalesInicial != null) {
      piezasController.text = widget.piezasTotalesInicial.toString();
    }

    if (widget.cantidadPliegosInicial != null) {
      pliegosController.text = widget.cantidadPliegosInicial.toString();
    }

    if (widget.anchoMedidaInicial != null) {
      anchoPliegoCtrl.text = widget.anchoMedidaInicial.toString();
    }

    if (widget.altoMedidaInicial != null) {
      altoPliegoCtrl.text = widget.altoMedidaInicial.toString();
    }
  }

  Map<String, dynamic> obtenerDatos() {
    return {
      'cliente_id': clienteSeleccionado?.id,
      'cliente_nombre': clienteController.text.trim(),
      'proyecto': proyectoController.text.trim(),
      'descripcion': descripcionController.text.trim(),
      'piezas_totales': int.tryParse(piezasController.text) ?? 0,
      'cantidad_pliegos': int.tryParse(pliegosController.text) ?? 0,
      'ancho_medida': double.tryParse(anchoPliegoCtrl.text) ?? 0.0,
      'alto_medida': double.tryParse(altoPliegoCtrl.text) ?? 0.0,
    };
  }


  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    clienteController.dispose();
    proyectoController.dispose();
    descripcionController.dispose();
    piezasController.dispose();
    pliegosController.dispose();
    anchoPliegoCtrl.dispose();
    altoPliegoCtrl.dispose();
    super.dispose();
  }

  void _abrirBuscadorCliente() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogoSelectorCliente(
          onSeleccionado: (cliente) {
            setState(() {
              clienteSeleccionado = cliente;
              clienteController.text = cliente.razonSocial;
            });
            if (widget.onClienteSeleccionado != null) {
              widget.onClienteSeleccionado!(cliente);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

            // FILA 1: RAZÓN SOCIAL CON BUSCADOR INTEGRADO
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: clienteController,
                    readOnly: true, // Evita escritura manual para forzar el uso del selector (Opcional)
                    onTap: _abrirBuscadorCliente, // Abre el buscador al tocar el campo
                    decoration: InputDecoration(
                      labelText: 'Razón Social Cliente', 
                      border: const OutlineInputBorder(), 
                      prefixIcon: const Icon(Icons.business),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _abrirBuscadorCliente,
                        tooltip: 'Buscar Cliente',
                      ),
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
                    onChanged: widget.onPiezasChanged,
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
