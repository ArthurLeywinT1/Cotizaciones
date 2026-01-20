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
import 'cotizacion_plana_laminado.dart';

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
  final TextEditingController descripcionController = TextEditingController();
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
  final TextEditingController paginasInternasTotalesController =
      TextEditingController(text: "0");

  // ===== PORTADA =====
  bool portada = false;

  // ===== PRUEBA COLOR PORTADA =====
  bool pruebaColorPortada = false;
  bool pruebaColorPortadaCarta = false;
  bool pruebaColorPortadaTabloide = false;
  bool pruebaColorPortadaMediaCarta = false;
  // ===== PRUEBA COLOR PORTADA POR TAMAÑO =====
  final TextEditingController cantidadPruebaPortadaCartaController =
      TextEditingController(text: "0");
  final TextEditingController precioPruebaPortadaCartaController =
      TextEditingController(text: "0.00");
  final TextEditingController totalPruebaPortadaCartaController =
      TextEditingController(text: "0.00");

  final TextEditingController cantidadPruebaPortadaTabloideController =
      TextEditingController(text: "0");
  final TextEditingController precioPruebaPortadaTabloideController =
      TextEditingController(text: "0.00");
  final TextEditingController totalPruebaPortadaTabloideController =
      TextEditingController(text: "0.00");

  final TextEditingController cantidadPruebaPortadaMediaCartaController =
      TextEditingController(text: "0");
  final TextEditingController precioPruebaPortadaMediaCartaController =
      TextEditingController(text: "0.00");
  final TextEditingController totalPruebaPortadaMediaCartaController =
      TextEditingController(text: "0.00");

  // ===== PRUEBA DE COLOR INTERNAS =====
  bool pruebaCarta = false;
  bool pruebaTabloide = false;
  bool pruebaMediaCarta = false;

  final TextEditingController cantidadCartaController = TextEditingController(
    text: "0",
  );
  final TextEditingController precioCartaController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController totalCartaController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController cantidadTabloideController =
      TextEditingController(text: "0");
  final TextEditingController precioTabloideController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController totalTabloideController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController cantidadMediaCartaController =
      TextEditingController(text: "0");
  final TextEditingController precioMediaCartaController =
      TextEditingController(text: "0.00");
  final TextEditingController totalMediaCartaController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController anchoPortadaController = TextEditingController();
  final TextEditingController altoPortadaController = TextEditingController();
  final TextEditingController medianilPortadaController =
      TextEditingController();
  final TextEditingController anchoFinalPortadaController =
      TextEditingController(text: "0");
  final TextEditingController altoFinalPortadaController =
      TextEditingController(text: "0");
  final TextEditingController piezasPortadaController = TextEditingController(
    text: "0",
  );
  final TextEditingController costoPruebaPortadaController =
      TextEditingController();

  // CONTROLADORES – PLIEGOS
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

  // PLIEGOS PORTADA
  final TextEditingController pliegoAnchoPortadaController =
      TextEditingController();
  final TextEditingController pliegoAltoPortadaController =
      TextEditingController();
  final TextEditingController posicionPiezasPortadaController =
      TextEditingController();
  final TextEditingController piezasPorPliegoPortadaController =
      TextEditingController();
  final TextEditingController tamanoPorPliegoPortadaController =
      TextEditingController();
  final TextEditingController cantidadPliegosPortadaController =
      TextEditingController();
  final TextEditingController pliegosSobrantesPortadaController =
      TextEditingController();
  final TextEditingController totalPliegosPortadaController =
      TextEditingController();
  final TextEditingController millaresPortadaController =
      TextEditingController();

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

  // PAPEL PORTADA

  final TextEditingController nombrePapelPortadaController =
      TextEditingController();
  final TextEditingController tipoPapelPortadaController =
      TextEditingController();
  final TextEditingController anchoPapelPortadaController =
      TextEditingController();
  final TextEditingController largoPapelPortadaController =
      TextEditingController();
  final TextEditingController pesoPapelPortadaController =
      TextEditingController();
  final TextEditingController proveedorPapelPortadaController =
      TextEditingController();
  final TextEditingController costoMillarPortadaController =
      TextEditingController();
  final TextEditingController costoTotalPapelPortadaController =
      TextEditingController();
  final TextEditingController descuentoPapelPortadaController =
      TextEditingController();
  final TextEditingController costoPapelPortadaConIvaController =
      TextEditingController();

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

  // MAQUINA PORTADA
  final TextEditingController nombreMaquinaPortadaController =
      TextEditingController();
  final TextEditingController costoPlacaPortadaController =
      TextEditingController();
  final TextEditingController tintasFtePortadaController =
      TextEditingController();
  final TextEditingController tintasRevPortadaController =
      TextEditingController();
  final TextEditingController cantidadTotalTintasPortadaController =
      TextEditingController();
  final TextEditingController costoUnitFtePortadaController =
      TextEditingController();
  final TextEditingController costoTotalFtePortadaController =
      TextEditingController();
  final TextEditingController costoUnitRevPortadaController =
      TextEditingController();
  final TextEditingController costoTotalRevPortadaController =
      TextEditingController();
  final TextEditingController costoGranTotalTintasPortadaController =
      TextEditingController();
  final TextEditingController cantidadPlacasPortadaController =
      TextEditingController();
  final TextEditingController costoBarnizPortadaController =
      TextEditingController();
  final TextEditingController costoTotalPlacasPortadaController =
      TextEditingController();

  bool barnizMaquinaPortada = false;
  bool cambiarPrecioPlacaPortada = false;

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

  // ACABADOS
  final Map<String, TextEditingController> acabadosCostoCm2Controllers = {};
  final Map<String, TextEditingController> acabadosCostoTotalControllers = {};

  // LAMINADOS – ESTADO

  final Map<String, Map<String, bool>> laminados = {
    "Plastificado Brillante": {"frente": false, "vuelta": false},
    "Plastificado Mate": {"frente": false, "vuelta": false},
  };

  // =======================
  // CONTROLADORES DE COSTO
  // =======================

  final Map<String, TextEditingController> laminadosCostoCm2Controllers = {};
  final Map<String, TextEditingController> laminadosCostoTotalControllers = {};
  final Map<String, TextEditingController> laminadosPortadaCostoCm2Controllers =
      {};
  final Map<String, TextEditingController>
  laminadosPortadaCostoTotalControllers = {};

  // ACABADOS PORTADA
  final Map<String, Map<String, bool>> acabadosPortada = {
    "Barniz UV a Registro": {"frente": false, "vuelta": false},
    "Barniz UV Brillante a Plasta": {"frente": false, "vuelta": false},
    "Barniz UV Mate Plasta": {"frente": false, "vuelta": false},
  };

  final Map<String, TextEditingController> acabadosPortadaCostoCm2Controllers =
      {};
  final Map<String, TextEditingController>
  acabadosPortadaCostoTotalControllers = {};

  // ACABADOS PORTADA
  final Map<String, Map<String, bool>> laminadosPortadaMap = {
    "Plastificado Brillante": {"frente": false, "vuelta": false},
    "Plastificado Mate": {"frente": false, "vuelta": false},
  };

  // ESTADOS GENERALES
  bool suaje = false;
  bool panelAcabadosActivo = true;
  bool barnizMaquina = false;
  bool cambiarPrecioPlaca = false;
  bool gastosEntrega = false;
  bool duplicarCostoSuaje = false;
  bool offsetActivo = false;
  bool barnizUV = false;
  bool barnizUVPortada = false;
  bool laminadosActivo = false;
  bool laminadosPortada = false;
  bool acabadosEspeciales = false;

  Map<String, Map<String, bool>> acabados = {
    "Barniz UV a Registro": {"frente": false, "vuelta": false},
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
    for (var key in acabadosPortada.keys) {
      acabadosPortadaCostoCm2Controllers[key] = TextEditingController(
        text: "0.00",
      );
      acabadosPortadaCostoTotalControllers[key] = TextEditingController(
        text: "0.00",
      );
    }
    for (var key in laminados.keys) {
      laminadosCostoCm2Controllers[key] = TextEditingController(text: "0.00");
      laminadosCostoTotalControllers[key] = TextEditingController(text: "0.00");
    }
    for (var key in laminadosPortadaMap.keys) {
      laminadosPortadaCostoCm2Controllers[key] = TextEditingController(
        text: "0.00",
      );
      laminadosPortadaCostoTotalControllers[key] = TextEditingController(
        text: "0.00",
      );
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

  void calcularPruebaColor({
    required TextEditingController cantidad,
    required TextEditingController precio,
    required TextEditingController total,
  }) {
    final c = double.tryParse(cantidad.text) ?? 0;
    final p = double.tryParse(precio.text) ?? 0;
    total.text = (c * p).toStringAsFixed(2);
  }

  void actualizarAcabado(String nombre, String lado, bool valor) {
    setState(() {
      acabados[nombre]?[lado] = valor;
    });
  }

  void actualizarLaminado(String nombre, String lado, bool valor) {
    setState(() {
      laminados[nombre]?[lado] = valor;
    });
  }

  void actualizarAcabadoPortada(String nombre, String lado, bool valor) {
    setState(() {
      acabadosPortada[nombre]?[lado] = valor;
    });
  }

  void actualizarLaminadoPortada(String nombre, String lado, bool valor) {
    setState(() {
      laminadosPortadaMap[nombre]?[lado] = valor;
    });
  }

  void calcularMedidasFinalesPortada() {
    final ancho = double.tryParse(anchoPortadaController.text) ?? 0;
    final alto = double.tryParse(altoPortadaController.text) ?? 0;
    final medianil = double.tryParse(medianilPortadaController.text) ?? 0;

    setState(() {
      anchoFinalPortadaController.text = (ancho + medianil).toStringAsFixed(2);
      altoFinalPortadaController.text = (alto + medianil).toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    razonSocialController.dispose();
    descripcionController.dispose();
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
    paginasInternasTotalesController.dispose();
    costoArregloSuajeController.dispose();
    costoTotalSuajadoController.dispose();
    for (var controller in acabadosCostoCm2Controllers.values)
      controller.dispose();
    for (var controller in acabadosCostoTotalControllers.values)
      controller.dispose();
    anchoPortadaController.dispose();
    altoPortadaController.dispose();
    medianilPortadaController.dispose();
    anchoFinalPortadaController.dispose();
    altoFinalPortadaController.dispose();
    piezasPortadaController.dispose();
    costoPruebaPortadaController.dispose();
    for (var c in acabadosPortadaCostoCm2Controllers.values) {
      c.dispose();
    }
    for (var c in acabadosPortadaCostoTotalControllers.values) {
      c.dispose();
    }
    cantidadCartaController.dispose();
    precioCartaController.dispose();
    totalCartaController.dispose();
    cantidadTabloideController.dispose();
    precioTabloideController.dispose();
    totalTabloideController.dispose();
    cantidadMediaCartaController.dispose();
    precioMediaCartaController.dispose();
    totalMediaCartaController.dispose();
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
              descripcionController: descripcionController,
              cantidadImpresionController: cantidadImpresionController,
              anchoController: anchoController,
              altoController: altoController,
              medianilController: medianilController,
              anchoFinalController: anchoFinalController,
              altoFinalController: altoFinalController,
              cantidadPruebaPortadaCartaController:
                  cantidadPruebaPortadaCartaController,
              precioPruebaPortadaCartaController:
                  precioPruebaPortadaCartaController,
              totalPruebaPortadaCartaController:
                  totalPruebaPortadaCartaController,

              onPruebaColorPortadaChanged: (v) {
                setState(() {
                  pruebaColorPortada = v ?? false;
                  if (!pruebaColorPortada) {
                    pruebaColorPortadaCarta = false;
                    pruebaColorPortadaTabloide = false;
                    pruebaColorPortadaMediaCarta = false;
                  }
                });
              },

              cantidadPruebaPortadaTabloideController:
                  cantidadPruebaPortadaTabloideController,
              precioPruebaPortadaTabloideController:
                  precioPruebaPortadaTabloideController,
              totalPruebaPortadaTabloideController:
                  totalPruebaPortadaTabloideController,

              cantidadPruebaPortadaMediaCartaController:
                  cantidadPruebaPortadaMediaCartaController,
              precioPruebaPortadaMediaCartaController:
                  precioPruebaPortadaMediaCartaController,
              totalPruebaPortadaMediaCartaController:
                  totalPruebaPortadaMediaCartaController,

              barnizUV: barnizUV,
              onBarnizUVChanged: (v) => setState(() => barnizUV = v ?? false),
              suaje: suaje,
              onSuajeChanged: (v) => setState(() => suaje = v),
              offset: offsetActivo,
              onOffsetChanged: (v) => setState(() => offsetActivo = v),
              onCalcular: calcularMedidasFinales,
              portada: portada,
              onPortadaChanged: (v) {
                setState(() {
                  portada = v ?? false;
                  if (!portada) {
                    barnizUVPortada = false;
                    acabadosPortada.forEach((_, lados) {
                      lados.updateAll((_, __) => false);
                    });
                  }
                });
              },
              anchoPortadaController: anchoPortadaController,
              altoPortadaController: altoPortadaController,
              medianilPortadaController: medianilPortadaController,
              anchoFinalPortadaController: anchoFinalPortadaController,
              altoFinalPortadaController: altoFinalPortadaController,
              piezasPortadaController: piezasPortadaController,
              onCalcularPortada: calcularMedidasFinalesPortada,
              pruebaColorPortada: pruebaColorPortada,
              pruebaColorPortadaCarta: pruebaColorPortadaCarta,
              pruebaColorPortadaTabloide: pruebaColorPortadaTabloide,
              pruebaColorPortadaMediaCarta: pruebaColorPortadaMediaCarta,
              paginasInternasTotalesController:
                  paginasInternasTotalesController,
              onPruebaColorPortadaCartaChanged: (v) {
                setState(() {
                  pruebaColorPortadaCarta = v ?? false;
                  if (!pruebaColorPortadaCarta) {
                    cantidadPruebaPortadaCartaController.text = "0";
                    precioPruebaPortadaCartaController.text = "0.00";
                    totalPruebaPortadaCartaController.text = "0.00";
                  }
                });
              },

              onPruebaColorPortadaTabloideChanged: (v) {
                setState(() {
                  pruebaColorPortadaTabloide = v ?? false;
                  if (!pruebaColorPortadaTabloide) {
                    cantidadPruebaPortadaTabloideController.text = "0";
                    precioPruebaPortadaTabloideController.text = "0.00";
                    totalPruebaPortadaTabloideController.text = "0.00";
                  }
                });
              },

              onPruebaColorPortadaMediaCartaChanged: (v) {
                setState(() {
                  pruebaColorPortadaMediaCarta = v ?? false;
                  if (!pruebaColorPortadaMediaCarta) {
                    cantidadPruebaPortadaMediaCartaController.text = "0";
                    precioPruebaPortadaMediaCartaController.text = "0.00";
                    totalPruebaPortadaMediaCartaController.text = "0.00";
                  }
                });
              },

              barnizUVPortada: barnizUVPortada,
              onBarnizUVPortadaChanged: (v) {
                setState(() {
                  barnizUVPortada = v ?? false;
                  if (!barnizUVPortada) {
                    acabadosPortada.forEach((_, lados) {
                      lados.updateAll((_, __) => false);
                    });
                  }
                });
              },
              laminadosActivo: laminadosActivo,
              onLaminadosChanged: (v) {
                setState(() {
                  laminadosActivo = v ?? false;
                  if (!laminadosActivo) {
                    laminados.forEach((_, lados) {
                      lados.updateAll((_, __) => false);
                    });
                  }
                });
              },
              laminadosPortada: laminadosPortada,
              onLaminadosPortadaChanged: (v) =>
                  setState(() => laminadosPortada = v ?? false),
              pruebaCarta: pruebaCarta,
              onPruebaCartaChanged: (v) {
                setState(() {
                  pruebaCarta = v ?? false;
                  if (!(v ?? false)) {
                    cantidadCartaController.text = "0";
                    precioCartaController.text = "0.00";
                    totalCartaController.text = "0.00";
                  }
                });
              },
              pruebaTabloide: pruebaTabloide,
              onPruebaTabloideChanged: (v) {
                setState(() {
                  pruebaTabloide = v ?? false;
                  if (!(v ?? false)) {
                    cantidadTabloideController.text = "0";
                    precioTabloideController.text = "0.00";
                    totalTabloideController.text = "0.00";
                  }
                });
              },
              pruebaMediaCarta: pruebaMediaCarta,
              onPruebaMediaCartaChanged: (v) {
                setState(() {
                  pruebaMediaCarta = v ?? false;
                  if (!(v ?? false)) {
                    cantidadMediaCartaController.text = "0";
                    precioMediaCartaController.text = "0.00";
                    totalMediaCartaController.text = "0.00";
                  }
                });
              },
              cantidadCartaController: cantidadCartaController,
              precioCartaController: precioCartaController,
              totalCartaController: totalCartaController,
              cantidadTabloideController: cantidadTabloideController,
              precioTabloideController: precioTabloideController,
              totalTabloideController: totalTabloideController,
              cantidadMediaCartaController: cantidadMediaCartaController,
              precioMediaCartaController: precioMediaCartaController,
              totalMediaCartaController: totalMediaCartaController,
              acabadosEspeciales: acabadosEspeciales,
              onAcabadosEspecialesChanged: (v) =>
                  setState(() => acabadosEspeciales = v ?? false),
            ),

            if (offsetActivo) ...[
              PanelPliegos(
                anchoFinalController: anchoFinalController,
                altoFinalController: altoFinalController,
                pliegoAnchoController: pliegoAnchoController,
                pliegoAltoController: pliegoAltoController,
                posicionPiezasController: posicionPiezasController,
                piezasPorPliegoController: piezasPorPliegoController,
                tamanoPorPliegoController: tamanoPorPliegoController,
                cantidadImpresionesController: portada
                    ? paginasInternasTotalesController
                    : cantidadImpresionController,
                pliegosSobrantesController: pliegosSobrantesController,
                totalPliegosController: totalPliegosController,
                millaresController: millaresController,
                cantidadPliegosController: cantidadPliegosController,
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
                pliegoAnchoController: pliegoAnchoController,
                pliegoAltoController: pliegoAltoController,
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
            ],

            if (barnizUV)
              PanelAcabados(
                read_Only: panelAcabadosActivo,
                acabados: acabados,
                onAcabadoChanged: actualizarAcabado,
                anchoFinalController: anchoFinalController,
                altoFinalController: altoFinalController,
                totalPliegosController: totalPliegosController,
                controllersCostoCm2: acabadosCostoCm2Controllers,
                controllersCostoTotal: acabadosCostoTotalControllers,
              ),

            /// LAMINADOS
            if (laminadosActivo)
              PanelLaminados(
                readOnly: laminadosActivo,
                laminados: laminados,
                onLaminadoChanged: actualizarLaminado,
                pliegoAnchoController: pliegoAnchoController,
                pliegoAltoController: pliegoAltoController,
                totalPliegosController: totalPliegosController,
                controllersCostoCm2: laminadosCostoCm2Controllers,
                controllersCostoTotal: laminadosCostoTotalControllers,
                isOffset: offsetActivo,
              ),

            if (offsetActivo && portada) ...[
              const Divider(thickness: 2),
              const Text(
                "PORTADA",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              /// PLIEGOS PORTADA
              PanelPliegos(
                cantidadImpresionesController: piezasPortadaController,
                anchoFinalController: anchoFinalPortadaController,
                altoFinalController: altoFinalPortadaController,

                pliegoAnchoController: pliegoAnchoPortadaController,
                pliegoAltoController: pliegoAltoPortadaController,
                posicionPiezasController: posicionPiezasPortadaController,
                piezasPorPliegoController: piezasPorPliegoPortadaController,
                tamanoPorPliegoController: tamanoPorPliegoPortadaController,
                cantidadPliegosController: cantidadPliegosPortadaController,
                pliegosSobrantesController: pliegosSobrantesPortadaController,
                totalPliegosController: totalPliegosPortadaController,
                millaresController: millaresPortadaController,
              ),

              /// PAPEL PORTADA
              PanelDatosPapel(
                nombrePapelController: nombrePapelPortadaController,
                tipoPapelController: tipoPapelPortadaController,
                anchoPapelController: anchoPapelPortadaController,
                largoPapelController: largoPapelPortadaController,
                pesoPapelController: pesoPapelPortadaController,
                proveedorPapelController: proveedorPapelPortadaController,
                costoMillarController: costoMillarPortadaController,
                totalPliegosController: totalPliegosPortadaController,
                pliegoAnchoController: pliegoAnchoPortadaController,
                pliegoAltoController: pliegoAltoPortadaController,
              ),

              PanelCostoPapel(
                costoMillarController: costoMillarPortadaController,
                totalPliegosController: totalPliegosPortadaController,
                costoTotalPapelController: costoTotalPapelPortadaController,
                descuentoController: descuentoPapelPortadaController,
                costoConIvaController: costoPapelPortadaConIvaController,
              ),

              /// MAQUINA PORTADA
              PanelMaquina(
                nombreMaquinaController: nombreMaquinaPortadaController,
                costoPlacaController: costoPlacaPortadaController,
                tintasFteController: tintasFtePortadaController,
                tintasRevController: tintasRevPortadaController,
                cantidadTotalTintasController:
                    cantidadTotalTintasPortadaController,
                costoUnitFteController: costoUnitFtePortadaController,
                costoTotalFteController: costoTotalFtePortadaController,
                costoUnitRevController: costoUnitRevPortadaController,
                costoTotalRevController: costoTotalRevPortadaController,
                costoGranTotalTintasController:
                    costoGranTotalTintasPortadaController,
                cantidadPlacasController: cantidadPlacasPortadaController,
                costoBarnizController: costoBarnizPortadaController,
                costoTotalPlacasController: costoTotalPlacasPortadaController,
                barnizMaquina: barnizMaquinaPortada,
                onBarnizMaquinaChanged: (v) =>
                    setState(() => barnizMaquinaPortada = v ?? false),
                cambiarPrecioPlaca: cambiarPrecioPlacaPortada,
                onCambiarPrecioPlacaChanged: (v) =>
                    setState(() => cambiarPrecioPlacaPortada = v ?? false),
              ),
            ],

            /// ACABADOS PORTADA
            if (offsetActivo && portada && barnizUVPortada)
              PanelAcabados(
                read_Only: panelAcabadosActivo,
                acabados: acabadosPortada,
                onAcabadoChanged: actualizarAcabadoPortada,
                anchoFinalController: anchoFinalPortadaController,
                altoFinalController: altoFinalPortadaController,
                totalPliegosController: totalPliegosPortadaController,
                controllersCostoCm2: acabadosPortadaCostoCm2Controllers,
                controllersCostoTotal: acabadosPortadaCostoTotalControllers,
              ),

            if (offsetActivo && portada && laminadosPortada)
              PanelLaminados(
                readOnly: laminadosPortada,
                laminados: laminadosPortadaMap,
                onLaminadoChanged: actualizarLaminadoPortada,
                pliegoAnchoController: pliegoAnchoPortadaController,
                pliegoAltoController: pliegoAltoPortadaController,
                totalPliegosController: totalPliegosPortadaController,
                controllersCostoCm2: laminadosPortadaCostoCm2Controllers,
                controllersCostoTotal: laminadosPortadaCostoTotalControllers,
                isOffset: offsetActivo,
              ),

            if (suaje) ...[
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
            ],

            if (acabadosEspeciales)
              PanelAcabadosEspeciales(
                piezasPorPliegoController: piezasPorPliegoController,
              ),

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
