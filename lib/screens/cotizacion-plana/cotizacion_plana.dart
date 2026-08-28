import 'package:cotizador/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/cotizacion_model.dart';
import '../../providers/cotizacion_provider.dart';
import '../../providers/auth_provider.dart';
import 'cotizacion_clientes.dart';
import 'cotizacion_pliegos.dart';
import 'cotizacion_datosPapel.dart';
import 'cotizacion_costoPapel.dart';
import 'cotizacion_maquina.dart';
import 'cotizacion_acabados.dart';
import 'cotizacion_suaje.dart';
import 'cotizacion_acabadosEspeciales.dart';
import 'cotizacion_costoTotal.dart';
import 'cotizacion_laminado.dart';
import 'cotizacion_serigrafia.dart';
import 'embalaje.dart';
import 'cotizacion_grabado.dart';
import '../../orden de trabajo/ordenTrabajo.dart';

// Pantalla principal de cotización plana
class CotizacionPlanaScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToCatalog;
  final Cotizacion? cotizacionAEditar;
  final int? piezasOverride;
  final bool esRecotizacion;

  const CotizacionPlanaScreen({
    super.key,
    this.onNavigateToCatalog,
    this.cotizacionAEditar,
    this.piezasOverride,
    this.esRecotizacion = false,
  });

  @override
  ConsumerState<CotizacionPlanaScreen> createState() =>
      _CotizacionPlanaScreenState();
}

class _CotizacionPlanaScreenState extends ConsumerState<CotizacionPlanaScreen> {
  final NumberFormat _f = NumberFormat("#,##0.00", "en_US");
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


  bool cambiarPrecioTinta = false;
  bool cambiarPrecioBarniz = false;


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
  final TextEditingController pliegosExtraController = TextEditingController();

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
  String? configuracionFrente;
  String? configuracionVuelta;

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
  // ACABADOS ESPECIALES
  // =======================
  List<bool> acabadosEspecialesActivos = List.generate(5, (_) => false);
  late final List<TextEditingController> acabadosEspecialesDescControllers;
  late final List<TextEditingController>
  acabadosEspecialesCostoMillarControllers;
  late final List<TextEditingController>
  acabadosEspecialesCostoTotalControllers;

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
  bool laminadosActivo = false;
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

    // Precio total automático: cuando cambian los pliegos (edición,
    // recotización, o segmentación), se vuelve a sumar todo y a recalcular
    // utilidad/IVA sin esperar a que se presione "Calcular" o "Guardar".
    // El Future.delayed(Duration.zero) le da tiempo a Acabados, Laminados,
    // Suaje, etc. de terminar de recalcular SUS propios totales primero
    // (mismo truco que ya usa _guardarCotizacion() más abajo).
    totalPliegosController.addListener(_actualizarPrecioTotalAutomatico);

    for (var key in acabados.keys) {
      acabadosCostoCm2Controllers[key] = TextEditingController(text: "0.00");
      acabadosCostoTotalControllers[key] = TextEditingController(text: "0.00");
    }
    for (var key in laminados.keys) {
      laminadosCostoCm2Controllers[key] = TextEditingController(text: "0.00");
      laminadosCostoTotalControllers[key] = TextEditingController(text: "0.00");
    }

    barnizFteController = TextEditingController(text: "0");
    barnizRevController = TextEditingController(text: "0");
    costoUnitBarnizFteController = TextEditingController(text: "0.00");
    costoUnitBarnizRevController = TextEditingController(text: "0.00");

    embalajeCostoControllers = List.generate(7, (_) => TextEditingController());

    embalajeCantidadControllers = List.generate(
      7,
      (_) => TextEditingController(),
    );

    embalajeTotalControllers = List.generate(7, (_) => TextEditingController());
    acabadosEspecialesDescControllers = List.generate(
      5,
      (_) => TextEditingController(),
    );
    acabadosEspecialesCostoMillarControllers = List.generate(
      5,
      (_) => TextEditingController(),
    );
    acabadosEspecialesCostoTotalControllers = List.generate(
      5,
      (_) => TextEditingController(text: "0.00"),
    );

    if (widget.cotizacionAEditar != null) {
      _cargarDatosEdicion(widget.cotizacionAEditar!);
    }
  }

  void _cargarDatosEdicion(Cotizacion edit) {
    clienteIdSeleccionado = edit.clienteId;
    descripcionController.text = edit.descripcion;
    anchoController.text = edit.anchoMedida.toString();
    altoController.text = edit.altoMedida.toString();
    tintasFteController.text = edit.tintaFrontal.toString();
    tintasRevController.text = edit.tintaReverso.toString();
    // Recotización: si viene un piezasOverride, manda sobre el valor guardado.
    cantidadImpresionController.text =
        (widget.piezasOverride ?? edit.cantidadImpresiones).toString();
    totalPliegosController.text = edit.totalPliegos.toString();

    void restaurarAcabados(
      Map<String, dynamic>? dataJson,
      Map<String, Map<String, bool>> mapEstado,
      Map<String, TextEditingController> mapCm2,
      Map<String, TextEditingController> mapTotal,
    ) {
      if (dataJson == null) return;
      dataJson.forEach((k, v) {
        if (mapEstado.containsKey(k) && v is Map) {
          mapEstado[k]!["frente"] = v["frente"] ?? false;
          mapEstado[k]!["vuelta"] = v["vuelta"] ?? false;
          mapCm2[k]?.text = v["costoCm2"]?.toString() ?? "0.00";
          mapTotal[k]?.text = v["costoTotal"]?.toString() ?? "0.00";
        }
      });
    }

    // 1. Clientes y Configuración General
    if (edit.configClientes != null) {
      final cli = edit.configClientes!;
      proyectoController.text = cli["proyecto"] ?? "";
      razonSocialController.text = cli["razonSocial"] ?? "";
      medianilController.text = cli["medianil"] ?? "";
      anchoFinalController.text = cli["anchoFinal"] ?? "";
      altoFinalController.text = cli["altoFinal"] ?? "";
      paginasInternasTotalesController.text =
          cli["paginasInternasTotales"] ?? "";
      paginasInternasPorPiezaController.text =
          cli["paginasInternasPorPieza"] ?? "";

      if (cli["pruebaColorInternasDetalles"] != null) {
        final pcInt = cli["pruebaColorInternasDetalles"];
        if (pcInt["carta"] != null) {
          pruebaCarta = pcInt["carta"]["activo"] ?? false;
          cantidadCartaController.text = pcInt["carta"]["cantidad"] ?? "0";
          precioCartaController.text = pcInt["carta"]["precio"] ?? "0.00";
          totalCartaController.text = pcInt["carta"]["total"] ?? "0.00";
        }
        if (pcInt["tabloide"] != null) {
          pruebaTabloide = pcInt["tabloide"]["activo"] ?? false;
          cantidadTabloideController.text = pcInt["tabloide"]["cantidad"] ?? "0";
          precioTabloideController.text = pcInt["tabloide"]["precio"] ?? "0.00";
          totalTabloideController.text = pcInt["tabloide"]["total"] ?? "0.00";
        }
        if (pcInt["mediaCarta"] != null) {
          pruebaMediaCarta = pcInt["mediaCarta"]["activo"] ?? false;
          cantidadMediaCartaController.text =
              pcInt["mediaCarta"]["cantidad"] ?? "0";
          precioMediaCartaController.text =
              pcInt["mediaCarta"]["precio"] ?? "0.00";
          totalMediaCartaController.text = pcInt["mediaCarta"]["total"] ?? "0.00";
        }
      }

      if (cli["switches"] != null) {
        final sw = cli["switches"];
        offsetActivo = sw["offsetActivo"] ?? false;
        barnizUV = sw["barnizUV"] ?? false;
        laminadosActivo = sw["laminadosActivo"] ?? false;
        suaje = sw["suaje"] ?? false;
        serigrafia = sw["serigrafia"] ?? false;
        grabado = sw["grabado"] ?? false;
        embalaje = sw["embalaje"] ?? false;
        acabadosEspeciales = sw["acabadosEspeciales"] ?? false;
      }
    }

    // 2. Pliegos
    if (edit.configPliegos != null) {
      final pInt = edit.configPliegos!["interior"];
      if (pInt != null) {
        pliegoAnchoController.text = pInt["pliegoAncho"] ?? "";
        pliegoAltoController.text = pInt["pliegoAlto"] ?? "";
        posicionPiezasController.text = pInt["posicionPiezas"] ?? "";
        piezasPorPliegoController.text = pInt["piezasPorPliego"] ?? "";
        tamanoPorPliegoController.text = pInt["tamanoPorPliego"] ?? "";
        pliegosExtraController.text = pInt["pliegosExtra"] ?? "";
        cantidadPliegosController.text = pInt["cantidadPliegos"] ?? "";
        pliegosSobrantesController.text = pInt["pliegosSobrantes"] ?? "";
        millaresController.text = pInt["millares"] ?? "";
      }
    }

    // 3. Datos del Papel
    if (edit.configDatosPapel != null) {
      final dpInt = edit.configDatosPapel!["interior"];
      if (dpInt != null) {
        nombrePapelController.text = dpInt["nombre"] ?? "";
        tipoPapelController.text = dpInt["tipo"] ?? "";
        anchoPapelController.text = dpInt["ancho"] ?? "";
        largoPapelController.text = dpInt["largo"] ?? "";
        pesoPapelController.text = dpInt["peso"] ?? "";
        proveedorPapelController.text = dpInt["proveedor"] ?? "";
      }
    }

    // 4. Costo del Papel
    if (edit.configCostoPapel != null) {
      final cpInt = edit.configCostoPapel!["interior"];
      if (cpInt != null) {
        costoMillarController.text = cpInt["costoMillar"] ?? "";
        costoTotalPapelController.text = cpInt["costoTotalPapel"] ?? "";
        descuentoPapelController.text = cpInt["descuentoPapel"] ?? "";
        costoPapelConIvaController.text = cpInt["costoPapelConIva"] ?? "";
      }
    }

    // 5. Máquina
    if (edit.configMaquina != null) {
      final mqInt = edit.configMaquina!["interior"];
      if (mqInt != null) {
        nombreMaquinaController.text = mqInt["nombreMaquina"] ?? "";
        costoPlacaController.text = mqInt["costoPlaca"] ?? "";
        cantidadTotalTintasController.text = mqInt["cantidadTotalTintas"] ?? "";
        costoUnitFteController.text = mqInt["costoUnitFte"] ?? "";
        costoTotalFteController.text = mqInt["costoTotalFte"] ?? "";
        costoUnitRevController.text = mqInt["costoUnitRev"] ?? "";
        costoTotalRevController.text = mqInt["costoTotalRev"] ?? "";
        costoGranTotalTintasController.text =
            mqInt["costoGranTotalTintas"] ?? "";
        cantidadPlacasController.text = mqInt["cantidadPlacas"] ?? "";
        costoBarnizController.text = mqInt["costoBarniz"] ?? "";
        costoTotalPlacasController.text = mqInt["costoTotalPlacas"] ?? "";
        cantidadPlacas790Controller.text = mqInt["cantidadPlacas790"] ?? "";
        costoPlaca790Controller.text = mqInt["costoPlaca790"] ?? "";
        costoTotalPlacas790Controller.text = mqInt["costoTotalPlacas790"] ?? "";
        barnizFte = mqInt["barnizFte"] ?? false;
        barnizRev = mqInt["barnizRev"] ?? false;
        barnizFteController.text = mqInt["barnizFteValor"] ?? "";
        barnizRevController.text = mqInt["barnizRevValor"] ?? "";
        configuracionFrente = mqInt["configuracionFrente"];
        configuracionVuelta = mqInt["configuracionVuelta"];
        costoUnitBarnizFteController.text = mqInt["costoUnitBarnizFte"] ?? "";
        costoUnitBarnizRevController.text = mqInt["costoUnitBarnizRev"] ?? "";
        cambiarPrecioPlaca = mqInt["cambiarPrecioPlaca"] ?? false;
        cambiarPrecioTinta = mqInt["cambiarPrecioTinta"] ?? false;
        cambiarPrecioBarniz = mqInt["cambiarPrecioBarniz"] ?? false;
      }
    }

    // 6. Acabados y Laminado
    if (edit.configAcabados != null) {
      restaurarAcabados(
        edit.configAcabados!["interior"]?["detalles"],
        acabados,
        acabadosCostoCm2Controllers,
        acabadosCostoTotalControllers,
      );
    }

    if (edit.configLaminado != null) {
      restaurarAcabados(
        edit.configLaminado!["interior"]?["detalles"],
        laminados,
        laminadosCostoCm2Controllers,
        laminadosCostoTotalControllers,
      );
    }

    // 7. Suaje
    if (edit.configSuaje != null) {
      final ms = edit.configSuaje!;
      seCuentaConSuaje = ms["seCuentaConSuaje"] ?? false;
      duplicarCostoSuaje = ms["duplicarCostoSuaje"] ?? false;
      tamanoSuajeController.text = ms["tamanoSuaje"] ?? "";
      anchoSuajeController.text = ms["anchoSuaje"] ?? "";
      largoSuajeController.text = ms["largoSuaje"] ?? "";
      costoSuajeCmController.text = ms["costoSuajeCm"] ?? "";
      costoTotalSuajeController.text = ms["costoTotalSuaje"] ?? "";
      costoArregloSuajeController.text = ms["costoArregloSuaje"] ?? "";
      costoTotalSuajadoController.text = ms["costoTotalSuajado"] ?? "";
      pliegosSuajeController.text = ms["pliegosSuaje"] ?? "";
      costoMillarSuajeController.text = ms["costoMillarSuaje"] ?? "";
    }

    // 8. Grabado
    if (edit.configGrabado != null) {
      final mg = edit.configGrabado!;
      cantidadPlacasGrabadoController.text = mg["cantidadPlacas"] ?? "";
      costoPlacaGrabadoController.text = mg["costoPlaca"] ?? "";
      costoTotalPlacasGrabadoController.text = mg["costoTotalPlacas"] ?? "";
      costoEntradaGrabadoController.text = mg["costoEntrada"] ?? "";
      costoTotalEntradaGrabadoController.text = mg["costoTotalEntrada"] ?? "";
      costoTotalGrabadoController.text = mg["costoTotalGrabado"] ?? "";
    }

    // 9. Serigrafía
    if (edit.configSerigrafia != null) {
      final ms = edit.configSerigrafia!;
      cantidadMarcosController.text = ms["cantidadMarcos"] ?? "";
      totalMarcosController.text = ms["totalMarcos"] ?? "";
      cantidadNegativosController.text = ms["cantidadNegativos"] ?? "";
      precioNegativoController.text = ms["precioNegativo"] ?? "";
      totalNegativosController.text = ms["totalNegativos"] ?? "";
      cantidadTintasController.text = ms["cantidadTintas"] ?? "";
      costoTintasController.text = ms["costoTintas"] ?? "";
      totalTintasController.text = ms["totalTintas"] ?? "";
      numeroEntradasController.text = ms["numeroEntradas"] ?? "";
      costoMillarSerigrafiaController.text = ms["costoMillarSerigrafia"] ?? "";
      totalEntradaController.text = ms["totalEntrada"] ?? "";

      final marcosLista = ms["listaMarcos"] as List?;
      if (marcosLista != null) {
        anchoMarcos.clear();
        altoMarcos.clear();
        precioMarcos.clear();
        for (var m in marcosLista) {
          anchoMarcos.add(
            TextEditingController(text: m["ancho"]?.toString() ?? "0"),
          );
          altoMarcos.add(
            TextEditingController(text: m["alto"]?.toString() ?? "0"),
          );
          precioMarcos.add(
            TextEditingController(text: m["precio"]?.toString() ?? "0.00"),
          );
        }
      }
    }

    // 10. Embalaje (Con reseteo previo seguro)
    final itemsGuardados = edit.configEmbalaje?["items"] as List?;
    for (int i = 0; i < embalajeItems.length; i++) {
      dynamic itemDb;
      if (itemsGuardados != null) {
        for (var x in itemsGuardados) {
          if (x["item"] == embalajeItems[i]) {
            itemDb = x;
            break;
          }
        }
      }

      if (itemDb != null) {
        embalajeActivoItems[i] = true;
        embalajeCostoControllers[i].text = itemDb["costo"]?.toString() ?? "";
        embalajeCantidadControllers[i].text =
            itemDb["cantidad"]?.toString() ?? "";
        embalajeTotalControllers[i].text = itemDb["total"]?.toString() ?? "";
      } else {
        embalajeActivoItems[i] = false;
        embalajeCostoControllers[i].clear();
        embalajeCantidadControllers[i].clear();
        embalajeTotalControllers[i].clear();
      }
    }

    // 11. Costo Total
    if (edit.configCostoTotal != null) {
      final mc = edit.configCostoTotal!;
      costoTotalController.text = mc["costoTotal"] ?? "";
      margenController.text = mc["margen"] ?? "";
      descuentoController.text = mc["descuento"] ?? "";
      diasEntregaController.text = mc["diasEntrega"] ?? "";
      precioUtilidadController.text = mc["precioUtilidad"] ?? "";
      precioDescuentoController.text = mc["precioDescuento"] ?? "";
      precioUnitarioController.text = mc["precioUnitario"] ?? "";
      ivaController.text = mc["iva"] ?? "";
      precioConIvaController.text = mc["precioConIva"] ?? "";
      gastosEntrega = mc["gastosEntregaActivo"] ?? false;
    }

    // 12. Acabados Especiales (Con reseteo de los 5 slots)
    final detallesGuardados =
        edit.configAcabadosEspeciales?["detalles"] as List?;
    for (int i = 0; i < 5; i++) {
      if (detallesGuardados != null && i < detallesGuardados.length) {
        acabadosEspecialesActivos[i] = true;
        acabadosEspecialesDescControllers[i].text =
            detallesGuardados[i]["descripcion"]?.toString() ?? "";
        acabadosEspecialesCostoMillarControllers[i].text =
            detallesGuardados[i]["costoMillar"]?.toString() ?? "";
        acabadosEspecialesCostoTotalControllers[i].text =
            detallesGuardados[i]["costoTotal"]?.toString() ?? "0.00";
      } else {
        acabadosEspecialesActivos[i] = false;
        acabadosEspecialesDescControllers[i].clear();
        acabadosEspecialesCostoMillarControllers[i].clear();
        acabadosEspecialesCostoTotalControllers[i].text = "0.00";
      }
    }

    setState(() {});
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

  void calcularTotalEmbalaje(int index) {
    final costo = double.tryParse(embalajeCostoControllers[index].text) ?? 0.0;

    final cantidad =
        double.tryParse(embalajeCantidadControllers[index].text) ?? 0.0;

    final total = costo * cantidad;

    embalajeTotalControllers[index].text = total.toStringAsFixed(2);
  }

  void calcularPliegosSuaje() {
    if (!suaje) return;

    int pliegosBase;

    if (offsetActivo) {
      // Espejo directo: el # de Pliegos del suaje siempre es
      // el total de pliegos a utilizar (sin fórmula aparte).
      pliegosBase = int.tryParse(totalPliegosController.text) ?? 0;
    } else {
      // CORRECCIÓN AQUÍ:
      // Asigna el total de pliegos calculados, en vez de la cantidad de impresiones/piezas.
      pliegosBase = int.tryParse(totalPliegosController.text) ??
          int.tryParse(cantidadImpresionController.text) ??
          0;
    }

    final int pliegosFinal =
        duplicarCostoSuaje ? pliegosBase * 2 : pliegosBase;

    pliegosSuajeController.text = pliegosFinal.toString();
  }

  double _limpiar(String texto) {
    return double.tryParse(texto.replaceAll(',', '')) ?? 0.0;
  }

  void calcularCostoTotalGeneral() {
    double total = 0.0;

    // PRUEBAS COLOR
    if (pruebaCarta) total += _limpiar(totalCartaController.text);
    if (pruebaTabloide) total += _limpiar(totalTabloideController.text);
    if (pruebaMediaCarta) total += _limpiar(totalMediaCartaController.text);

    // OFFSET INTERNAS Y
    if (offsetActivo) {
      total += _limpiar(costoPapelConIvaController.text);
      total += _limpiar(costoGranTotalTintasController.text);
      total += _limpiar(costoTotalPlacasController.text);
      total += _limpiar(costoTotalPlacas790Controller.text);

      if (barnizFte) total += _limpiar(costoBarnizController.text);
      if (barnizRev) total += _limpiar(costoBarnizController.text);

    }

    // ACABADOS UV Y LAMINADOS
    if (barnizUV) {
      for (var c in acabadosCostoTotalControllers.values)
        total += _limpiar(c.text);
    }
    if (laminadosActivo) {
      for (var c in laminadosCostoTotalControllers.values)
        total += _limpiar(c.text);
    }

    // OTROS MÓDULOS
    if (suaje) total += _limpiar(costoTotalSuajadoController.text);
    if (grabado) total += _limpiar(costoTotalGrabadoController.text);
    if (serigrafia) {
      total += _limpiar(totalMarcosController.text);
      total += _limpiar(totalNegativosController.text);
      total += _limpiar(totalTintasController.text);
      total += _limpiar(totalEntradaController.text);
    }
    if (embalaje) {
      for (int i = 0; i < embalajeTotalControllers.length; i++) {
        if (embalajeActivoItems[i])
          total += _limpiar(embalajeTotalControllers[i].text);
      }
    }
    if (acabadosEspeciales) {
      for (var c in acabadosEspecialesCostoTotalControllers)
        total += _limpiar(c.text);
    }

    // SETEAR COSTO TOTAL CON COMAS
    costoTotalController.text = _f.format(total);
  }

  void _calcularUtilidadYFinal(double costoBase) {
    double margen = _limpiar(margenController.text) / 100;
    double descuento = _limpiar(descuentoController.text) / 100;
    double cantidad = _limpiar(cantidadImpresionController.text);

    double precioConUtilidad = costoBase * (1 + margen);
    double precioConDescuento = precioConUtilidad * (1 - descuento);
    double unitario = cantidad > 0 ? precioConDescuento / cantidad : 0;
    double iva = precioConDescuento * 0.16;
    double precioConIva = precioConDescuento + iva;

    // ASIGNAR A CONTROLADORES CON COMAS
    precioUtilidadController.text = _f.format(precioConUtilidad);
    precioDescuentoController.text = _f.format(precioConDescuento);
    precioUnitarioController.text = _f.format(unitario);
    ivaController.text = _f.format(iva);
    precioConIvaController.text = _f.format(precioConIva);

    setState(() {});
  }

  void _actualizarPrecioTotalAutomatico() {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      calcularCostoTotalGeneral();
      _calcularUtilidadYFinal(_limpiar(costoTotalController.text));
    });
  }

  Future<void> _guardarCotizacion({String? nuevoStatus}) async {
    // 1. Le da un respiro a la UI para que no se congele el hilo principal
    await Future.delayed(Duration.zero);

    calcularMedidasFinales();
    calcularCostoTotalGeneral();

    double costoBaseLimpio = _limpiar(costoTotalController.text);
    _calcularUtilidadYFinal(costoBaseLimpio);

    if (clienteIdSeleccionado == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un Cliente primero')),
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

    final mapClientes = {
      "clienteIdSeleccionado": clienteIdSeleccionado,
      "descripcion": descripcionController.text,
      "cantidadImpresiones": cantidadImpresionController.text,
      "proyecto": proyectoController.text,
      "razonSocial": razonSocialController.text,
      "ancho": anchoController.text,
      "alto": altoController.text,
      "medianil": medianilController.text,
      "anchoFinal": anchoFinalController.text,
      "altoFinal": altoFinalController.text,
      "medidasFinalesCalculadas":
          "${anchoFinalController.text} x ${altoFinalController.text} cm",
      "paginasInternasTotales": paginasInternasTotalesController.text,
      "paginasInternasPorPieza": paginasInternasPorPiezaController.text,
      "pruebaColorInternasDetalles": {
        "carta": {
          "activo": pruebaCarta,
          "cantidad": cantidadCartaController.text,
          "precio": precioCartaController.text,
          "total": totalCartaController.text,
        },
        "tabloide": {
          "activo": pruebaTabloide,
          "cantidad": cantidadTabloideController.text,
          "precio": precioTabloideController.text,
          "total": totalTabloideController.text,
        },
        "mediaCarta": {
          "activo": pruebaMediaCarta,
          "cantidad": cantidadMediaCartaController.text,
          "precio": precioMediaCartaController.text,
          "total": totalMediaCartaController.text,
        },
      },
      "switches": {
        "offsetActivo": offsetActivo,
        "barnizUV": barnizUV,
        "laminadosActivo": laminadosActivo,
        "suaje": suaje,
        "serigrafia": serigrafia,
        "grabado": grabado,
        "embalaje": embalaje,
        "acabadosEspeciales": acabadosEspeciales,
      },
    };

    final mapPliegos = {
      "interior": {
        "pliegoAncho": pliegoAnchoController.text,
        "pliegoAlto": pliegoAltoController.text,
        "posicionPiezas": posicionPiezasController.text,
        "piezasPorPliego": piezasPorPliegoController.text,
        "tamanoPorPliego": tamanoPorPliegoController.text,
        "pliegosExtra": pliegosExtraController.text,
        "cantidadPliegos": cantidadPliegosController.text,
        "pliegosSobrantes": pliegosSobrantesController.text,
        "totalPliegos": totalPliegosController.text,
        "millares": millaresController.text,
      },
    };

    final mapDatosPapel = {
      "interior": {
        "nombre": nombrePapelController.text,
        "tipo": tipoPapelController.text,
        "ancho": anchoPapelController.text,
        "largo": largoPapelController.text,
        "peso": pesoPapelController.text,
        "proveedor": proveedorPapelController.text,
      },
    };

    final mapCostoPapel = {
      "interior": {
        "costoMillar": costoMillarController.text,
        "costoTotalPapel": costoTotalPapelController.text,
        "descuentoPapel": descuentoPapelController.text,
        "costoPapelConIva": costoPapelConIvaController.text,
      },
    };

    final mapMaquina = {
      "offsetActivo": offsetActivo,
      "interior": {
        "nombreMaquina": nombreMaquinaController.text,
        "costoPlaca": costoPlacaController.text,
        "tintasFte": tintasFteController.text,
        "tintasRev": tintasRevController.text,
        "cantidadTotalTintas": cantidadTotalTintasController.text,
        "costoUnitFte": costoUnitFteController.text,
        "costoTotalFte": costoTotalFteController.text,
        "costoUnitRev": costoUnitRevController.text,
        "costoTotalRev": costoTotalRevController.text,
        "costoGranTotalTintas": costoGranTotalTintasController.text,
        "cantidadPlacas": cantidadPlacasController.text,
        "costoBarniz": costoBarnizController.text,
        "costoTotalPlacas": costoTotalPlacasController.text,
        "cantidadPlacas790": cantidadPlacas790Controller.text,
        "costoPlaca790": costoPlaca790Controller.text,
        "costoTotalPlacas790": costoTotalPlacas790Controller.text,
        "barnizFte": barnizFte,
        "barnizRev": barnizRev,
        "barnizFteValor": barnizFteController.text,
        "barnizRevValor": barnizRevController.text,
        "configuracionFrente": configuracionFrente,
        "configuracionVuelta": configuracionVuelta,
        "costoUnitBarnizFte": costoUnitBarnizFteController.text,
        "costoUnitBarnizRev": costoUnitBarnizRevController.text,
        "cambiarPrecioPlaca": cambiarPrecioPlaca,
        "cambiarPrecioTinta": cambiarPrecioTinta,
        "cambiarPrecioBarniz": cambiarPrecioBarniz,
      },
    };

    Map<String, dynamic> extraerEstado(
      Map<String, Map<String, bool>> estado,
      Map<String, TextEditingController> costoCm2,
      Map<String, TextEditingController> costoTotal,
    ) {
      return estado.map(
        (key, value) => MapEntry(key, {
          "frente": value["frente"],
          "vuelta": value["vuelta"],
          "costoCm2": costoCm2[key]?.text ?? "0.00",
          "costoTotal": costoTotal[key]?.text ?? "0.00",
        }),
      );
    }

    final mapAcabados = {
      "interior": {
        "barnizUV": barnizUV,
        "detalles": barnizUV
            ? extraerEstado(
                acabados,
                acabadosCostoCm2Controllers,
                acabadosCostoTotalControllers,
              )
            : {},
      },
    };

    final mapLaminado = {
      "interior": {
        "laminadosActivo": laminadosActivo,
        "detalles": laminadosActivo
            ? extraerEstado(
                laminados,
                laminadosCostoCm2Controllers,
                laminadosCostoTotalControllers,
              )
            : {},
      },
    };

    final mapSuaje = {
      "suajeActivo": suaje,
      "seCuentaConSuaje": seCuentaConSuaje,
      "duplicarCostoSuaje": duplicarCostoSuaje,
      "tamanoSuaje": tamanoSuajeController.text,
      "anchoSuaje": anchoSuajeController.text,
      "largoSuaje": largoSuajeController.text,
      "costoSuajeCm": costoSuajeCmController.text,
      "costoTotalSuaje": costoTotalSuajeController.text,
      "costoArregloSuaje": costoArregloSuajeController.text,
      "costoTotalSuajado": costoTotalSuajadoController.text,
      "pliegosSuaje": pliegosSuajeController.text,
      "costoMillarSuaje": costoMillarSuajeController.text,
    };

    final mapGrabado = {
      "grabadoActivo": grabado,
      "cantidadPlacas": cantidadPlacasGrabadoController.text,
      "costoPlaca": costoPlacaGrabadoController.text,
      "costoTotalPlacas": costoTotalPlacasGrabadoController.text,
      "costoEntrada": costoEntradaGrabadoController.text,
      "costoTotalEntrada": costoTotalEntradaGrabadoController.text,
      "costoTotalGrabado": costoTotalGrabadoController.text,
    };

    List<Map<String, String>> listaMarcos = [];
    for (int i = 0; i < anchoMarcos.length; i++) {
      listaMarcos.add({
        "ancho": anchoMarcos[i].text,
        "alto": altoMarcos[i].text,
        "precio": precioMarcos[i].text,
      });
    }

    final mapSerigrafia = {
      "serigrafiaActivo": serigrafia,
      "cantidadMarcos": cantidadMarcosController.text,
      "totalMarcos": totalMarcosController.text,
      "listaMarcos": listaMarcos,
      "cantidadNegativos": cantidadNegativosController.text,
      "precioNegativo": precioNegativoController.text,
      "totalNegativos": totalNegativosController.text,
      "cantidadTintas": cantidadTintasController.text,
      "costoTintas": costoTintasController.text,
      "totalTintas": totalTintasController.text,
      "numeroEntradas": numeroEntradasController.text,
      "costoMillarSerigrafia": costoMillarSerigrafiaController.text,
      "totalEntrada": totalEntradaController.text,
    };

    List<Map<String, dynamic>> embalajeDetalles = [];
    for (int i = 0; i < embalajeItems.length; i++) {
      if (embalajeActivoItems[i]) {
        embalajeDetalles.add({
          "item": embalajeItems[i],
          "costo": embalajeCostoControllers[i].text,
          "cantidad": embalajeCantidadControllers[i].text,
          "total": embalajeTotalControllers[i].text,
        });
      }
    }

    final mapEmbalaje = {"embalajeActivo": embalaje, "items": embalajeDetalles};

    final mapCostoTotal = {
      "costoTotal": costoTotalController.text,
      "margen": margenController.text,
      "descuento": descuentoController.text,
      "diasEntrega": diasEntregaController.text,
      "precioUtilidad": precioUtilidadController.text,
      "precioDescuento": precioDescuentoController.text,
      "precioUnitario": precioUnitarioController.text,
      "iva": ivaController.text,
      "precioConIva": precioConIvaController.text,
      "gastosEntregaActivo": gastosEntrega,
    };

    List<Map<String, dynamic>> acabadosEspecialesDetalles = [];
    for (int i = 0; i < 5; i++) {
      if (acabadosEspecialesActivos[i]) {
        acabadosEspecialesDetalles.add({
          "descripcion": acabadosEspecialesDescControllers[i].text,
          "costoMillar": acabadosEspecialesCostoMillarControllers[i].text,
          "costoTotal": acabadosEspecialesCostoTotalControllers[i].text,
        });
      }
    }

    final mapAcabadosEspeciales = {
      "activo": acabadosEspeciales,
      "detalles": acabadosEspecialesDetalles,
    };

    final mapCorte = {"activo": false};

    final String statusFinal =
        nuevoStatus ??
        widget.cotizacionAEditar?.status ??
        'Esperando Aprobacion';

    final nuevaCotizacion = Cotizacion(
      id: widget.cotizacionAEditar?.id,
      folio: widget.cotizacionAEditar?.folio,
      fechaCreacion: widget.cotizacionAEditar?.fechaCreacion,
      clienteId: clienteIdSeleccionado!,
      usuarioId: usuarioIdActual,
      descripcion: descripcionController.text.trim(),
      anchoMedida: double.tryParse(anchoController.text) ?? 0.0,
      altoMedida: double.tryParse(altoController.text) ?? 0.0,
      tintaFrontal: int.tryParse(tintasFteController.text) ?? 0,
      tintaReverso: int.tryParse(tintasRevController.text) ?? 0,
      cantidadImpresiones: int.tryParse(cantidadImpresionController.text) ?? 0,
      totalPliegos: int.tryParse(totalPliegosController.text) ?? 0,
      precioSinIva:
          double.tryParse(precioDescuentoController.text.replaceAll(',', '')) ??
          0.0,
      precioUnitario:
          double.tryParse(precioUnitarioController.text.replaceAll(',', '')) ??
          0.0,
      precioConIva:
          double.tryParse(precioConIvaController.text.replaceAll(',', '')) ??
          0.0,
      status: statusFinal,
      tipoCotizacion: 'P',
      numPliegos: 1,
      configClientes: mapClientes,
      configPliegos: mapPliegos,
      configDatosPapel: mapDatosPapel,
      configCostoPapel: mapCostoPapel,
      configMaquina: mapMaquina,
      configAcabados: mapAcabados,
      configLaminado: mapLaminado,
      configSuaje: mapSuaje,
      configGrabado: mapGrabado,
      configSerigrafia: mapSerigrafia,
      configEmbalaje: mapEmbalaje,
      configCostoTotal: mapCostoTotal,
      configAcabadosEspeciales: mapAcabadosEspeciales,
      configCorte: mapCorte,
    );

    final bool exito;
    if (widget.cotizacionAEditar != null) {
      exito = await ref
          .read(cotizacionesProvider.notifier)
          .actualizarCotizacion(nuevaCotizacion);
    } else {
      exito = await ref
          .read(cotizacionesProvider.notifier)
          .crearCotizacion(nuevaCotizacion);
    }

    if (!mounted) return;

    if (exito) {
      final isOT = (nuevoStatus == 'Orden de Trabajo');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOT
                ? 'Orden de Trabajo generada exitosamente'
                : widget.cotizacionAEditar != null
                ? 'Cotización modificada exitosamente'
                : 'Cotización guardada exitosamente',
          ),
        ),
      );

      if (isOT) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrdenTrabajoScreen()),
        );
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
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
    barnizFteController.dispose();
    barnizRevController.dispose();
    costoUnitBarnizFteController.dispose();
    costoUnitBarnizRevController.dispose();

    for (var c in embalajeCostoControllers) {
      c.dispose();
    }
    for (var c in embalajeCantidadControllers) {
      c.dispose();
    }
    for (var c in embalajeTotalControllers) {
      c.dispose();
    }

    for (var c in acabadosEspecialesDescControllers) c.dispose();
    for (var c in acabadosEspecialesCostoMillarControllers) c.dispose();
    for (var c in acabadosEspecialesCostoTotalControllers) c.dispose();

    costoTotalController.dispose();
    margenController.dispose();
    descuentoController.dispose();
    diasEntregaController.dispose();
    precioUtilidadController.dispose();
    precioDescuentoController.dispose();
    precioUnitarioController.dispose();
    ivaController.dispose();
    precioConIvaController.dispose();
    pliegosExtraController.dispose();
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
              paginasInternasPorPiezaController:
                  paginasInternasPorPiezaController,
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
              paginasInternasTotalesController:
                  paginasInternasTotalesController,
              prePrensa: false,
              onPrePrensaChanged: (v) {
                setState(() {});
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
                pliegosSobrantesController: pliegosSobrantesController,
                totalPliegosController: totalPliegosController,
                millaresController: millaresController,
                cantidadPliegosController: cantidadPliegosController,
                pliegosExtraController: pliegosExtraController,
                cantidadImpresionesController: cantidadImpresionController,
                
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
                valorInicialFrente: configuracionFrente,
                valorInicialVuelta: configuracionVuelta,
                onConfiguracionFrenteChanged: (valor) {
                  setState(() {
                    // <--- Agrega setState
                    configuracionFrente = valor;
                  });
                },
                onConfiguracionVueltaChanged: (valor) {
                  setState(() {
                    // <--- Agrega setState
                    configuracionVuelta = valor;
                  });
                },
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
                duplicarCostoSuaje: duplicarCostoSuaje,
                onDuplicarCostoSuajeChanged: (value) {
                  setState(() {
                    duplicarCostoSuaje = value ?? false;
                  });
                  calcularPliegosSuaje();
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
                activos: acabadosEspecialesActivos,
                descripcionControllers: acabadosEspecialesDescControllers,
                costoMillarControllers:
                    acabadosEspecialesCostoMillarControllers,
                costoTotalControllers: acabadosEspecialesCostoTotalControllers,
                onChangedActivo: (index, value) {
                  setState(() {
                    acabadosEspecialesActivos[index] = value;
                  });
                  calcularCostoTotalGeneral();
                },
                onCalcularCosto: (index) {
                  calcularCostoTotalGeneral();
                },
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
                // 1. Recolecta todos los costos de los paneles
                calcularCostoTotalGeneral();

                // 2. Procesa la utilidad basada en el número limpio
                double costoBaseLimpio = _limpiar(costoTotalController.text);
                _calcularUtilidadYFinal(costoBaseLimpio);
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                botonAccion(
                  (widget.cotizacionAEditar != null && !widget.esRecotizacion)
                      ? "Actualizar Cotización"
                      : "Guardar Cotización",
                  onPressed: () => _guardarCotizacion(),
                ),
                botonAccion(
                  "Generar Orden de Trabajo",
                  onPressed: () =>
                      _guardarCotizacion(nuevoStatus: 'Orden de Trabajo'),
                ),
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