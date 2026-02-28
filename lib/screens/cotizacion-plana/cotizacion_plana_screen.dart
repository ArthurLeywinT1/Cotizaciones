import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cotizacion_model.dart';
import '../../providers/cotizacion_provider.dart';
import '../../providers/auth_provider.dart';
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
import 'cotizacion_plana_serigrafia.dart';
import 'embalaje.dart';
import 'cotizacion_plana_grabado.dart';

// Pantalla principal de cotización plana
class CotizacionPlanaScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToCatalog;

  const CotizacionPlanaScreen({super.key, this.onNavigateToCatalog});

  @override
  ConsumerState<CotizacionPlanaScreen> createState() =>
      _CotizacionPlanaScreenState();
}

class _CotizacionPlanaScreenState extends ConsumerState<CotizacionPlanaScreen> {
  // =============================
  // CONTROLADORES – CLIENTES
  // =============================
  String? clienteIdSeleccionado;
  final TextEditingController proyectoController = TextEditingController();
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
  final TextEditingController paginasInternasPorPiezaController =
      TextEditingController(text: "0");

  // ===== PORTADA =====
  bool portada = false;
  bool cambiarPrecioTinta = false;
  bool cambiarPrecioTintaPortada = false;
  bool cambiarPrecioBarniz = false;
  bool cambiarPrecioBarnizPortada = false;

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
  final TextEditingController cantidadPlacas790Controller =
      TextEditingController(text: "0");

  final TextEditingController costoPlaca790Controller = TextEditingController(
    text: "0.00",
  );

  final TextEditingController costoTotalPlacas790Controller =
      TextEditingController(text: "0.00");
  List<String> opcionesFrente = [];
  List<String> opcionesVuelta = [];

  bool barnizFte = false;
  bool barnizRev = false;

  late final TextEditingController barnizFteController;
  late final TextEditingController barnizRevController;

  late final TextEditingController costoUnitBarnizFteController;
  late final TextEditingController costoUnitBarnizRevController;

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

  final TextEditingController cantidadPlacas790PortadaController =
      TextEditingController(text: "0");

  final TextEditingController costoPlaca790PortadaController =
      TextEditingController(text: "0.00");

  final TextEditingController costoTotalPlacas790PortadaController =
      TextEditingController(text: "0.00");

  bool barnizMaquinaPortada = false;
  bool cambiarPrecioPlacaPortada = false;
  List<String> opcionesFrentePortada = [];
  List<String> opcionesVueltaPortada = [];

  bool barnizFtePortada = false;
  bool barnizRevPortada = false;

  late final TextEditingController barnizFtePortadaController;
  late final TextEditingController barnizRevPortadaController;

  late final TextEditingController costoUnitBarnizFtePortadaController;
  late final TextEditingController costoUnitBarnizRevPortadaController;

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
  final TextEditingController anchoSuajeController = TextEditingController();
  final TextEditingController largoSuajeController = TextEditingController();
  final TextEditingController pliegosSuajeController = TextEditingController(
    text: "0",
  );
  final TextEditingController costoMillarSuajeController =
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
  // MARCOS
  final cantidadMarcosController = TextEditingController();
  final totalMarcosController = TextEditingController();
  List<TextEditingController> anchoMarcos = [];
  List<TextEditingController> altoMarcos = [];
  List<TextEditingController> precioMarcos = [];

  // NEGATIVOS
  final cantidadNegativosController = TextEditingController();
  final precioNegativoController = TextEditingController();
  final totalNegativosController = TextEditingController();

  // TINTAS
  final cantidadTintasController = TextEditingController();
  final costoTintasController = TextEditingController();
  final totalTintasController = TextEditingController();

  // ENTRADAS
  final numeroEntradasController = TextEditingController();
  final TextEditingController costoMillarSerigrafiaController =
      TextEditingController();
  final totalEntradaController = TextEditingController();

  // GRABADO
  final cantidadPlacasGrabadoController = TextEditingController(text: "0");
  final costoPlacaGrabadoController = TextEditingController(text: "0.00");
  final costoTotalPlacasGrabadoController = TextEditingController(text: "0.00");

  final costoEntradaGrabadoController = TextEditingController(text: "0.00");
  final costoTotalEntradaGrabadoController = TextEditingController(
    text: "0.00",
  );

  final costoTotalGrabadoController = TextEditingController(text: "0.00");

  // EMBALAJE

  final List<String> embalajeItems = [
    "Cajas",
    "Envoltura",
    "Cinta canela",
    "Ligas",
    "Celofán",
    "Cinta diurex",
    "Otro",
  ];

  List<bool> embalajeActivoItems = List.generate(7, (_) => false);

  late final List<TextEditingController> embalajeCostoControllers;
  late final List<TextEditingController> embalajeCantidadControllers;
  late final List<TextEditingController> embalajeTotalControllers;
  // =======================
  // COSTO TOTAL (NUEVOS)
  // =======================

  final TextEditingController costoTotalController = TextEditingController(
    text: "0.00",
  );

  final TextEditingController margenController = TextEditingController(
    text: "0",
  );

  final TextEditingController descuentoController = TextEditingController(
    text: "0",
  );

  final TextEditingController diasEntregaController = TextEditingController(
    text: "1",
  );

  final TextEditingController precioUtilidadController = TextEditingController(
    text: "0.00",
  );

  final TextEditingController precioDescuentoController = TextEditingController(
    text: "0.00",
  );

  final TextEditingController precioUnitarioController = TextEditingController(
    text: "0.00",
  );

  final TextEditingController ivaController = TextEditingController(
    text: "0.00",
  );

  final TextEditingController precioConIvaController = TextEditingController(
    text: "0.00",
  );

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
  bool seCuentaConSuaje = false;
  bool serigrafia = false;
  bool embalaje = false;
  bool grabado = false;

  Map<String, Map<String, bool>> acabados = {
    "Barniz UV a Registro": {"frente": false, "vuelta": false},
    "Barniz UV Brillante a Plasta": {"frente": false, "vuelta": false},
    "Barniz UV Mate Plasta": {"frente": false, "vuelta": false},
  };

  @override
  void initState() {
    super.initState();
    pliegoAnchoController.addListener(calcularPliegosSuaje);
    pliegoAltoController.addListener(calcularPliegosSuaje);
    anchoSuajeController.addListener(calcularPliegosSuaje);
    largoSuajeController.addListener(calcularPliegosSuaje);
    totalPliegosController.addListener(calcularPliegosSuaje);
    cantidadImpresionController.addListener(calcularPliegosSuaje);

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
    barnizFteController = TextEditingController(text: "0");
    barnizRevController = TextEditingController(text: "0");
    costoUnitBarnizFteController = TextEditingController(text: "0.00");
    costoUnitBarnizRevController = TextEditingController(text: "0.00");

    barnizFtePortadaController = TextEditingController(text: "0");
    barnizRevPortadaController = TextEditingController(text: "0");
    costoUnitBarnizFtePortadaController = TextEditingController(text: "0.00");
    costoUnitBarnizRevPortadaController = TextEditingController(text: "0.00");
    embalajeCostoControllers = List.generate(7, (_) => TextEditingController());

    embalajeCantidadControllers = List.generate(
      7,
      (_) => TextEditingController(),
    );

    embalajeTotalControllers = List.generate(7, (_) => TextEditingController());
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

  void calcularTotalEmbalaje(int index) {
    final costo = double.tryParse(embalajeCostoControllers[index].text) ?? 0.0;

    final cantidad =
        double.tryParse(embalajeCantidadControllers[index].text) ?? 0.0;

    final total = costo * cantidad;

    embalajeTotalControllers[index].text = total.toStringAsFixed(2);
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

  void calcularPliegosSuaje() {
    if (!suaje) return;

    if (offsetActivo) {
      final anchoPliego = double.tryParse(pliegoAnchoController.text) ?? 0;

      final altoPliego = double.tryParse(pliegoAltoController.text) ?? 0;

      final anchoSuaje = double.tryParse(anchoSuajeController.text) ?? 0;

      final altoSuaje = double.tryParse(largoSuajeController.text) ?? 0;

      final totalPliegos = int.tryParse(totalPliegosController.text) ?? 0;

      if (anchoPliego > 0 &&
          altoPliego > 0 &&
          anchoSuaje > 0 &&
          altoSuaje > 0) {
        final areaPliego = anchoPliego * altoPliego;
        final areaSuaje = anchoSuaje * altoSuaje;

        final piezasPorPliego = (areaPliego / areaSuaje).floor();

        final resultado = piezasPorPliego * totalPliegos;

        pliegosSuajeController.text = resultado.toString();
      }
    } else {
      final piezasTotales = int.tryParse(cantidadImpresionController.text) ?? 0;

      pliegosSuajeController.text = piezasTotales.toString();
    }
  }

  void calcularCostoTotalGeneral() {
    double total = 0.0;

    // ==============================
    // 🔹 PRUEBA COLOR INTERNAS
    // ==============================

    if (pruebaCarta) {
      total += double.tryParse(totalCartaController.text) ?? 0;
    }

    if (pruebaTabloide) {
      total += double.tryParse(totalTabloideController.text) ?? 0;
    }

    if (pruebaMediaCarta) {
      total += double.tryParse(totalMediaCartaController.text) ?? 0;
    }

    // ==============================
    // 🔹 PRUEBA COLOR PORTADA
    // ==============================

    if (portada && pruebaColorPortada) {
      if (pruebaColorPortadaCarta) {
        total += double.tryParse(totalPruebaPortadaCartaController.text) ?? 0;
      }

      if (pruebaColorPortadaTabloide) {
        total +=
            double.tryParse(totalPruebaPortadaTabloideController.text) ?? 0;
      }

      if (pruebaColorPortadaMediaCarta) {
        total +=
            double.tryParse(totalPruebaPortadaMediaCartaController.text) ?? 0;
      }
    }

    // ==============================
    // 🔹 PAPEL INTERNAS
    // ==============================

    if (offsetActivo) {
      total += double.tryParse(costoPapelConIvaController.text) ?? 0;
    }

    // ==============================
    // 🔹 PAPEL PORTADA
    // ==============================

    if (offsetActivo && portada) {
      total += double.tryParse(costoPapelPortadaConIvaController.text) ?? 0;
    }

    // ==============================
    // 🔹 TINTAS INTERNAS
    // ==============================

    if (offsetActivo) {
      total += double.tryParse(costoGranTotalTintasController.text) ?? 0;
    }

    // ==============================
    // 🔹 TINTAS PORTADA
    // ==============================

    if (offsetActivo && portada) {
      total += double.tryParse(costoGranTotalTintasPortadaController.text) ?? 0;
    }

    // ==============================
    // 🔹 PLACAS INTERNAS
    // ==============================

    if (offsetActivo) {
      total += double.tryParse(costoTotalPlacasController.text) ?? 0;
      total += double.tryParse(costoTotalPlacas790Controller.text) ?? 0;
    }

    // ==============================
    // 🔹 PLACAS PORTADA
    // ==============================

    if (offsetActivo && portada) {
      total += double.tryParse(costoTotalPlacasPortadaController.text) ?? 0;
      total += double.tryParse(costoTotalPlacas790PortadaController.text) ?? 0;
    }

    // ==============================
    // 🔹 BARNIZ MAQUINA INTERNAS
    // ==============================

    if (offsetActivo) {
      double costoBarniz = double.tryParse(costoBarnizController.text) ?? 0;

      if (barnizFte) {
        total += costoBarniz;
      }

      if (barnizRev) {
        total += costoBarniz;
      }
    }
    // ==============================
    // 🔹 BARNIZ MAQUINA PORTADA
    // ==============================

    if (offsetActivo && portada) {
      double costoBarnizPortada =
          double.tryParse(costoBarnizPortadaController.text) ?? 0;

      if (barnizFtePortada) {
        total += costoBarnizPortada;
      }

      if (barnizRevPortada) {
        total += costoBarnizPortada;
      }
    }

    // ==============================
    // 🔹 ACABADOS UV INTERNAS
    // ==============================

    if (barnizUV) {
      for (var c in acabadosCostoTotalControllers.values) {
        total += double.tryParse(c.text) ?? 0;
      }
    }

    // ==============================
    // 🔹 ACABADOS UV PORTADA
    // ==============================

    if (portada && barnizUVPortada) {
      for (var c in acabadosPortadaCostoTotalControllers.values) {
        total += double.tryParse(c.text) ?? 0;
      }
    }

    // ==============================
    // 🔹 LAMINADOS INTERNAS
    // ==============================

    if (laminadosActivo) {
      for (var c in laminadosCostoTotalControllers.values) {
        total += double.tryParse(c.text) ?? 0;
      }
    }

    // ==============================
    // 🔹 LAMINADOS PORTADA
    // ==============================

    if (portada && laminadosPortada) {
      for (var c in laminadosPortadaCostoTotalControllers.values) {
        total += double.tryParse(c.text) ?? 0;
      }
    }

    // ==============================
    // 🔹 SUAJE
    // ==============================

    if (suaje) {
      total += double.tryParse(costoTotalSuajadoController.text) ?? 0;
    }

    // ==============================
    // 🔹 GRABADO
    // ==============================

    if (grabado) {
      total += double.tryParse(costoTotalGrabadoController.text) ?? 0;
    }

    // ==============================
    // 🔹 SERIGRAFIA
    // ==============================

    if (serigrafia) {
      total += double.tryParse(totalMarcosController.text) ?? 0;
      total += double.tryParse(totalNegativosController.text) ?? 0;
      total += double.tryParse(totalTintasController.text) ?? 0;
      total += double.tryParse(totalEntradaController.text) ?? 0;
    }

    // ==============================
    // 🔹 EMBALAJE
    // ==============================

    if (embalaje) {
      for (int i = 0; i < embalajeTotalControllers.length; i++) {
        if (embalajeActivoItems[i]) {
          total += double.tryParse(embalajeTotalControllers[i].text) ?? 0;
        }
      }
    }

    // ==============================
    // 🔹 SETEAR TOTAL
    // ==============================

    costoTotalController.text = total.toStringAsFixed(2);
  }

  void _calcularUtilidadYFinal(double costoBase) {
    double margen = (double.tryParse(margenController.text) ?? 0) / 100;

    double descuento = (double.tryParse(descuentoController.text) ?? 0) / 100;

    double precioConUtilidad = costoBase * (1 + margen);
    precioUtilidadController.text = precioConUtilidad.toStringAsFixed(2);

    double precioConDescuento = precioConUtilidad * (1 - descuento);
    precioDescuentoController.text = precioConDescuento.toStringAsFixed(2);

    double cantidad = double.tryParse(cantidadImpresionController.text) ?? 1;

    double unitario = cantidad > 0 ? precioConDescuento / cantidad : 0;

    precioUnitarioController.text = unitario.toStringAsFixed(2);

    double iva = precioConDescuento * 0.16;
    ivaController.text = iva.toStringAsFixed(2);

    precioConIvaController.text = (precioConDescuento + iva).toStringAsFixed(2);

    setState(() {});
  }

  Future<void> _guardarCotizacion() async {
    if (clienteIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un Cliente primero'),
        ),
      );
      return;
    }

    final authState = ref.read(authProvider);

    final String? usuarioIdActual = authState.usuario?.id;

    if (usuarioIdActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró una sesión de usuario activa.'),
        ),
      );
      return;
    }

    final nuevaCotizacion = Cotizacion(
      clienteId: clienteIdSeleccionado!,
      usuarioId: usuarioIdActual,
      descripcion: descripcionController.text.trim(),
      anchoMedida: double.tryParse(anchoController.text) ?? 0.0,
      altoMedida: double.tryParse(altoController.text) ?? 0.0,
      tipoCotizacion: 'Plana',
      tintaFrontal: int.tryParse(tintasFteController.text) ?? 0,
      tintaReverso: int.tryParse(tintasRevController.text) ?? 0,
      cantidadImpresiones: int.tryParse(cantidadImpresionController.text) ?? 0,
      precioSinIva: double.tryParse(precioDescuentoController.text) ?? 0.0,
      precioUnitario: double.tryParse(precioUnitarioController.text) ?? 0.0,
      precioConIva: double.tryParse(precioConIvaController.text) ?? 0.0,
    );

    final exito = await ref
        .read(cotizacionesProvider.notifier)
        .crearCotizacion(nuevaCotizacion);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cotización guardada exitosamente')),
      );

      if (widget.onNavigateToCatalog != null) {
        widget.onNavigateToCatalog!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la cotización. Revisa la conexión.'),
        ),
      );
    }
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
    anchoSuajeController.dispose();
    largoSuajeController.dispose();
    pliegosSuajeController.dispose();
    costoMillarSuajeController.dispose();
    cantidadPlacas790Controller.dispose();
    costoPlaca790Controller.dispose();
    costoTotalPlacas790Controller.dispose();
    cantidadPlacas790PortadaController.dispose();
    costoPlaca790PortadaController.dispose();
    costoTotalPlacas790PortadaController.dispose();
    barnizFteController.dispose();
    barnizRevController.dispose();
    costoUnitBarnizFteController.dispose();
    costoUnitBarnizRevController.dispose();

    barnizFtePortadaController.dispose();
    barnizRevPortadaController.dispose();
    costoUnitBarnizFtePortadaController.dispose();
    costoUnitBarnizRevPortadaController.dispose();
    for (var c in embalajeCostoControllers) {
      c.dispose();
    }
    for (var c in embalajeCantidadControllers) {
      c.dispose();
    }
    for (var c in embalajeTotalControllers) {
      c.dispose();
    }
    costoTotalController.dispose();
    margenController.dispose();
    descuentoController.dispose();
    diasEntregaController.dispose();
    precioUtilidadController.dispose();
    precioDescuentoController.dispose();
    precioUnitarioController.dispose();
    ivaController.dispose();
    precioConIvaController.dispose();
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
              onClienteIdSeleccionado: (id) =>
                  setState(() => clienteIdSeleccionado = id),
              proyectoController: proyectoController,
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
              paginasInternasPorPiezaController:
                  paginasInternasPorPiezaController,

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
              onSuajeChanged: (v) {
                setState(() {
                  suaje = v;
                });
                calcularPliegosSuaje();
              },
              serigrafia: serigrafia,
              onSerigrafiaChanged: (v) {
                setState(() {
                  serigrafia = v;
                });
              },

              offset: offsetActivo,
              onOffsetChanged: (v) {
                setState(() {
                  offsetActivo = v;
                });
                calcularPliegosSuaje();
              },
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
              prePrensa: false,
              onPrePrensaChanged: (v) {
                setState(() {});
              },
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
              embalaje: embalaje,
              onEmbalajeChanged: (v) {
                setState(() {
                  embalaje = v;
                });
              },
              grabado: grabado,
              onGrabadoChanged: (v) {
                setState(() {
                  grabado = v;
                });
              },
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
                costoUnitFteController: costoUnitFteController,
                costoTotalFteController: costoTotalFteController,
                costoUnitRevController: costoUnitRevController,
                costoTotalRevController: costoTotalRevController,
                costoGranTotalTintasController: costoGranTotalTintasController,
                cantidadPlacasController: cantidadPlacasController,
                costoBarnizController: costoBarnizController,
                costoTotalPlacasController: costoTotalPlacasController,
                onBarnizMaquinaChanged: (v) =>
                    setState(() => barnizMaquina = v ?? false),
                cambiarPrecioPlaca: cambiarPrecioPlaca,
                onCambiarPrecioPlacaChanged: (v) =>
                    setState(() => cambiarPrecioPlaca = v ?? false),
                cambiarPrecioTinta: cambiarPrecioTinta,
                onCambiarPrecioTintaChanged: (v) =>
                    setState(() => cambiarPrecioTinta = v ?? false),
                cambiarPrecioBarniz: cambiarPrecioBarniz,
                onCambiarPrecioBarnizChanged: (v) =>
                    setState(() => cambiarPrecioBarniz = v ?? false),
                cantidadPlacas790Controller: cantidadPlacas790Controller,
                costoPlaca790Controller: costoPlaca790Controller,
                costoTotalPlacas790Controller: costoTotalPlacas790Controller,
                millaresController: millaresController,
                opcionesFrente: opcionesFrente,
                opcionesVuelta: opcionesVuelta,
                barnizFte: barnizFte,
                barnizRev: barnizRev,
                barnizFteController: barnizFteController,
                barnizRevController: barnizRevController,
                costoUnitBarnizFteController: costoUnitBarnizFteController,
                costoUnitBarnizRevController: costoUnitBarnizRevController,
                onBarnizFteChanged: (v) => setState(() => barnizFte = v),
                onBarnizRevChanged: (v) => setState(() => barnizRev = v),
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
                cantidadImpresionController: cantidadImpresionController,
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
                costoUnitFteController: costoUnitFtePortadaController,
                costoTotalFteController: costoTotalFtePortadaController,
                costoUnitRevController: costoUnitRevPortadaController,
                costoTotalRevController: costoTotalRevPortadaController,
                costoGranTotalTintasController:
                    costoGranTotalTintasPortadaController,
                cantidadPlacasController: cantidadPlacasPortadaController,
                costoBarnizController: costoBarnizPortadaController,
                costoTotalPlacasController: costoTotalPlacasPortadaController,
                onBarnizMaquinaChanged: (v) =>
                    setState(() => barnizMaquinaPortada = v ?? false),
                cambiarPrecioPlaca: cambiarPrecioPlacaPortada,
                onCambiarPrecioPlacaChanged: (v) =>
                    setState(() => cambiarPrecioPlacaPortada = v ?? false),
                cambiarPrecioTinta: cambiarPrecioTinta,
                onCambiarPrecioTintaChanged: (v) =>
                    setState(() => cambiarPrecioTinta = v ?? false),
                cambiarPrecioBarniz: cambiarPrecioBarniz,
                onCambiarPrecioBarnizChanged: (v) =>
                    setState(() => cambiarPrecioBarniz = v ?? false),
                cantidadPlacas790Controller: cantidadPlacas790PortadaController,
                costoPlaca790Controller: costoPlaca790PortadaController,
                costoTotalPlacas790Controller:
                    costoTotalPlacas790PortadaController,
                millaresController: millaresPortadaController,
                opcionesFrente: opcionesFrentePortada,
                opcionesVuelta: opcionesVueltaPortada,
                barnizFte: barnizFtePortada,
                barnizRev: barnizRevPortada,
                barnizFteController: barnizFtePortadaController,
                barnizRevController: barnizRevPortadaController,
                costoUnitBarnizFteController:
                    costoUnitBarnizFtePortadaController,
                costoUnitBarnizRevController:
                    costoUnitBarnizRevPortadaController,
                onBarnizFteChanged: (v) => setState(() => barnizFtePortada = v),
                onBarnizRevChanged: (v) => setState(() => barnizRevPortada = v),
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
                cantidadImpresionController: piezasPortadaController,
                isOffset: offsetActivo,
              ),

            if (suaje)
              PanelSuaje(
                enabled: true,
                tamanoSuajeController: tamanoSuajeController,
                anchoSuajeController: anchoSuajeController,
                largoSuajeController: largoSuajeController,
                costoSuajeCmController: costoSuajeCmController,
                costoTotalSuajeController: costoTotalSuajeController,
                costoArregloSuajeController: costoArregloSuajeController,
                costoTotalSuajadoController: costoTotalSuajadoController,
                pliegosSuajeController: pliegosSuajeController,
                costoMillarSuajeController: costoMillarSuajeController,
                seCuentaConSuaje: seCuentaConSuaje,
                onSeCuentaConSuajeChanged: (value) {
                  setState(() {
                    seCuentaConSuaje = value ?? false;
                  });
                },
              ),
            if (grabado)
              PanelGrabado(
                piezasTotalesController: cantidadImpresionController,

                cantidadPlacasController: cantidadPlacasGrabadoController,
                costoPlacaController: costoPlacaGrabadoController,
                costoTotalPlacasController: costoTotalPlacasGrabadoController,

                costoEntradaController: costoEntradaGrabadoController,
                costoTotalEntradaController: costoTotalEntradaGrabadoController,

                costoTotalGrabadoController: costoTotalGrabadoController,
              ),

            if (serigrafia)
              CotizacionPlanaSerigrafia(
                piezasTotalesController: cantidadImpresionController,

                cantidadMarcosController: cantidadMarcosController,
                totalMarcosController: totalMarcosController,
                anchoMarcos: anchoMarcos,
                altoMarcos: altoMarcos,
                precioMarcos: precioMarcos,

                cantidadNegativosController: cantidadNegativosController,
                precioNegativoController: precioNegativoController,

                cantidadTintasController: cantidadTintasController,
                costoTintasController: costoTintasController,
                totalTintasController: totalTintasController,

                numeroEntradasController: numeroEntradasController,
                costoMillarController: costoMillarSerigrafiaController,
                totalEntradaController: totalEntradaController,
                totalNegativosController: totalNegativosController,
              ),

            if (embalaje)
              PanelEmbalaje(
                items: embalajeItems,
                activo: embalajeActivoItems,
                costoControllers: embalajeCostoControllers,
                cantidadControllers: embalajeCantidadControllers,
                totalControllers: embalajeTotalControllers,
                onCalcular: calcularTotalEmbalaje,
                onItemChanged: (index, value) {
                  setState(() {
                    embalajeActivoItems[index] = value;
                  });
                },
              ),

            if (acabadosEspeciales) ...[
              PanelAcabadosEspeciales(
                cantidadImpresionController: cantidadImpresionController,
              ),
            ],

            PanelCostoTotal(
              costoTotalController: costoTotalController,
              margenController: margenController,
              descuentoController: descuentoController,
              diasEntregaController: diasEntregaController,
              precioUtilidadController: precioUtilidadController,
              precioDescuentoController: precioDescuentoController,
              precioUnitarioController: precioUnitarioController,
              ivaController: ivaController,
              precioConIvaController: precioConIvaController,
              onRecalcular: () {
                calcularCostoTotalGeneral();
                _calcularUtilidadYFinal(
                  double.tryParse(costoTotalController.text) ?? 0,
                );
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                botonAccion(
                  "Guardar Cotización",
                  onPressed: _guardarCotizacion,
                ),
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

  Widget botonAccion(String texto, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      child: Text(texto, textAlign: TextAlign.center),
    );
  }
}
