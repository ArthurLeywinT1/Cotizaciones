import 'package:flutter/material.dart';
import 'cotizacion_plana_clientes.dart';
import 'cotizacion_plana_pliegos.dart';
import 'cotizacion_plana_datos_papel.dart';
import 'cotizacion_plana_costo_papel.dart';
import 'cotizacion_plana_maquina.dart';
import 'cotizacion_plana_acabados.dart';
import 'cotizacion_plana_suaje.dart';
import 'cotizacion_plana_acabados_especiales.dart';
import 'cotizacion_plana_costo_total.dart';

class CotizacionPlanaScreen extends StatefulWidget {
  const CotizacionPlanaScreen({super.key});

  @override
  State<CotizacionPlanaScreen> createState() => _CotizacionPlanaScreenState();
}

class _CotizacionPlanaScreenState extends State<CotizacionPlanaScreen> {
  // =============================
  // CONTROLADORES – CLIENTES
  // =============================
  final TextEditingController razonSocialController = TextEditingController();
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController altoController = TextEditingController();
  final TextEditingController medianilController = TextEditingController();
  final TextEditingController anchoFinalController = TextEditingController(
    text: "0",
  );
  final TextEditingController altoFinalController = TextEditingController(
    text: "0",
  );
  final TextEditingController cantidadImpresionController =
      TextEditingController(text: "0");

  // =============================
  // CONTROLADORES – PLIEGOS
  // =============================
  final TextEditingController pliegoAnchoController = TextEditingController();
  final TextEditingController pliegoAltoController = TextEditingController();
  final TextEditingController posicionPiezasController =
      TextEditingController();
  final TextEditingController piezasPorPliegoController =
      TextEditingController();
  final TextEditingController tamanoPorPliegoController =
      TextEditingController();
  final TextEditingController cantidadPliegosController =
      TextEditingController();
  final TextEditingController pliegosSobrantesController =
      TextEditingController();
  final TextEditingController totalPliegosController = TextEditingController();
  final TextEditingController millaresController = TextEditingController();

  // Controladores papel
  final TextEditingController nombrePapelController = TextEditingController();
  final TextEditingController tipoPapelController = TextEditingController();
  final TextEditingController anchoPapelController = TextEditingController();
  final TextEditingController largoPapelController = TextEditingController();
  final TextEditingController pesoPapelController = TextEditingController();
  final TextEditingController proveedorPapelController =
      TextEditingController();
  final TextEditingController costoMillarController = TextEditingController();
  final TextEditingController costoTotalPapelController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController descuentoPapelController = TextEditingController(
    text: "0",
  );
  final TextEditingController costoPapelConIvaController =
      TextEditingController(text: "0.00");

  // Controladores maquina
  final TextEditingController nombreMaquinaController = TextEditingController();
  final TextEditingController costoPlacaController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController tintasFteController = TextEditingController();
  final TextEditingController tintasRevController = TextEditingController();
  final TextEditingController cantidadTotalTintasController =
      TextEditingController();
  final TextEditingController costoUnitFteController = TextEditingController();
  final TextEditingController costoTotalFteController = TextEditingController();
  final TextEditingController costoUnitRevController = TextEditingController();
  final TextEditingController costoTotalRevController = TextEditingController();
  final TextEditingController costoGranTotalTintasController =
      TextEditingController();
  final TextEditingController cantidadPlacasController = TextEditingController(
    text: "0",
  );
  final TextEditingController costoBarnizController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController costoTotalPlacasController =
      TextEditingController(text: "0.00");

  // Contoladores suaje
  final TextEditingController tamanoSuajeController = TextEditingController();
  final TextEditingController costoSuajeCmController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController costoTotalSuajeController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController costoArregloSuajeController =
      TextEditingController(text: "0.00");
  final TextEditingController costoTotalSuajadoController =
      TextEditingController(text: "0.00");

  // =============================
  // ACABADOS
  // =============================
  final Map<String, TextEditingController> acabadosCostoCm2Controllers = {};
  final Map<String, TextEditingController> acabadosCostoTotalControllers = {};

  // =============================
  // ESTADOS GENERALES
  // =============================
  bool suaje = false;
  bool panelAcabadosActivo = true;
  bool barnizMaquina = false;
  bool cambiarPrecioPlaca = false;

  bool gastosEntrega = false;
  bool duplicarCostoSuaje = false;

  Map<String, Map<String, bool>> acabados = {
    "Barniz UV a Registro": {"frente": false, "vuelta": false},
    "Plastificado Brillante": {"frente": false, "vuelta": false},
    "Plastificado Mate": {"frente": false, "vuelta": false},
    "Barniz UV Brillante a Plasta": {"frente": false, "vuelta": false},
    "Barniz UV Mate Plasta": {"frente": false, "vuelta": false},
  };

  @override
  void initState() {
    super.initState();
    for (var key in acabados.keys) {
      acabadosCostoCm2Controllers[key] = TextEditingController(text: "0.00");
      acabadosCostoTotalControllers[key] = TextEditingController(text: "0.00");
    }
  }

  void calcularMedidasFinales() {
    final ancho = double.tryParse(anchoController.text) ?? 0;
    final alto = double.tryParse(altoController.text) ?? 0;
    final medianil = double.tryParse(medianilController.text) ?? 0;

    setState(() {
      anchoFinalController.text = (ancho + medianil).toStringAsFixed(2);
      altoFinalController.text = (alto + medianil).toStringAsFixed(2);
    });
  }

  void actualizarAcabado(String nombre, String lado, bool valor) {
    setState(() {
      acabados[nombre]?[lado] = valor;
    });
  }

  @override
  void dispose() {
    razonSocialController.dispose();
    anchoController.dispose();
    altoController.dispose();
    medianilController.dispose();
    anchoFinalController.dispose();
    altoFinalController.dispose();
    cantidadImpresionController.dispose();

    pliegoAnchoController.dispose();
    pliegoAltoController.dispose();
    posicionPiezasController.dispose();
    piezasPorPliegoController.dispose();
    tamanoPorPliegoController.dispose();
    cantidadPliegosController.dispose();
    pliegosSobrantesController.dispose();
    totalPliegosController.dispose();
    millaresController.dispose();

    nombrePapelController.dispose();
    tipoPapelController.dispose();
    anchoPapelController.dispose();
    largoPapelController.dispose();
    pesoPapelController.dispose();
    proveedorPapelController.dispose();
    costoMillarController.dispose();
    costoTotalPapelController.dispose();
    descuentoPapelController.dispose();
    costoPapelConIvaController.dispose();

    nombreMaquinaController.dispose();
    costoPlacaController.dispose();
    tintasFteController.dispose();
    tintasRevController.dispose();
    cantidadTotalTintasController.dispose();
    costoUnitFteController.dispose();
    costoTotalFteController.dispose();
    costoUnitRevController.dispose();
    costoTotalRevController.dispose();
    costoGranTotalTintasController.dispose();
    cantidadPlacasController.dispose();
    costoBarnizController.dispose();
    costoTotalPlacasController.dispose();

    tamanoSuajeController.dispose();
    costoSuajeCmController.dispose();
    costoTotalSuajeController.dispose();
    costoArregloSuajeController.dispose();
    costoTotalSuajadoController.dispose();

    for (var controller in acabadosCostoCm2Controllers.values) {
      controller.dispose();
    }
    for (var controller in acabadosCostoTotalControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cotización Plana")),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PanelClientes(
              razonSocialController: razonSocialController,
              cantidadImpresionController: cantidadImpresionController,
              anchoController: anchoController,
              altoController: altoController,
              medianilController: medianilController,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              suaje: suaje,
              onCalcular: calcularMedidasFinales,
              onSuajeChanged: (v) => setState(() => suaje = v),
            ),

            PanelPliegos(
              cantidadImpresionesController: cantidadImpresionController,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              pliegoAnchoController: pliegoAnchoController,
              pliegoAltoController: pliegoAltoController,
              posicionPiezasController: posicionPiezasController,
              piezasPorPliegoController: piezasPorPliegoController,
              tamanoPorPliegoController: tamanoPorPliegoController,
              cantidadPliegosController: cantidadPliegosController,
              pliegosSobrantesController: pliegosSobrantesController,
              totalPliegosController: totalPliegosController,
              millaresController: millaresController,
            ),

            PanelDatosPapel(
              nombrePapelController: nombrePapelController,
              tipoPapelController: tipoPapelController,
              anchoPapelController: anchoPapelController,
              largoPapelController: largoPapelController,
              pesoPapelController: pesoPapelController,
              proveedorPapelController: proveedorPapelController,
              costoMillarController: costoMillarController,
              totalPliegosController: totalPliegosController,
            ),

            PanelCostoPapel(
              costoMillarController: costoMillarController,
              totalPliegosController: totalPliegosController,
              costoTotalPapelController: costoTotalPapelController,
              descuentoController: descuentoPapelController,
              costoConIvaController: costoPapelConIvaController,
            ),

            PanelMaquina(
              nombreMaquinaController: nombreMaquinaController,
              costoPlacaController: costoPlacaController,
              tintasFteController: tintasFteController,
              tintasRevController: tintasRevController,
              cantidadTotalTintasController: cantidadTotalTintasController,
              costoUnitFteController: costoUnitFteController,
              costoTotalFteController: costoTotalFteController,
              costoUnitRevController: costoUnitRevController,
              costoTotalRevController: costoTotalRevController,
              costoGranTotalTintasController: costoGranTotalTintasController,
              cantidadPlacasController: cantidadPlacasController,
              costoBarnizController: costoBarnizController,
              costoTotalPlacasController: costoTotalPlacasController,
              barnizMaquina: barnizMaquina,
              onBarnizMaquinaChanged: (v) =>
                  setState(() => barnizMaquina = v ?? false),
              cambiarPrecioPlaca: cambiarPrecioPlaca,
              onCambiarPrecioPlacaChanged: (v) =>
                  setState(() => cambiarPrecioPlaca = v ?? false),
            ),

            PanelAcabados(
              read_Only: panelAcabadosActivo,
              acabados: acabados,
              onAcabadoChanged: actualizarAcabado,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              controllersCostoCm2: acabadosCostoCm2Controllers,
              controllersCostoTotal: acabadosCostoTotalControllers,
            ),

            PanelSuaje(
              enabled: suaje,
              tamanoSuajeController: tamanoSuajeController,
              costoSuajeCmController: costoSuajeCmController,
              costoTotalSuajeController: costoTotalSuajeController,
              costoArregloSuajeController: costoArregloSuajeController,
              costoTotalSuajadoController: costoTotalSuajadoController,

              gastosEntrega: gastosEntrega,
              onGastosEntregaChanged: (v) =>
                  setState(() => gastosEntrega = v ?? false),

              duplicarCosto: duplicarCostoSuaje,
              onDuplicarCostoChanged: (v) =>
                  setState(() => duplicarCostoSuaje = v ?? false),
            ),

            const PanelAcabadosEspeciales(),
            const PanelCostoTotal(),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                botonAccion("Guardar Cotización"),
                botonAccion("Cancelar"),
                botonAccion("Modificar Descuentos"),
                botonAccion("Recotizar"),
                botonAccion("Recotizar Cantidad"),
                botonAccion("Generar OT"),
                botonAccion("Cancelar Cotización"),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget botonAccion(String texto) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      child: Text(texto, textAlign: TextAlign.center),
    );
  }
}
