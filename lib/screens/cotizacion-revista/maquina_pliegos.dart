// maquina_pliegos.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/maquina_model.dart';
import '../../providers/maquina_provider.dart';
import '../modals/modal_maquina.dart';
import '../cotizacion-plana/buscador_maquina.dart';
import '../../providers/extra_provider.dart';

class PanelMaquinaPliego extends ConsumerStatefulWidget {
  final TextEditingController nombreMaquinaController;
  final TextEditingController costoPlacaController;
  final TextEditingController tintasFteController;
  final TextEditingController tintasRevController;
  final TextEditingController costoUnitFteController;
  final TextEditingController costoTotalFteController;
  final TextEditingController costoUnitRevController;
  final TextEditingController costoTotalRevController;
  final TextEditingController costoGranTotalTintasController;
  final TextEditingController cantidadPlacasController;
  final TextEditingController costoBarnizController;
  final TextEditingController costoTotalPlacasController;
  final ValueChanged<bool?> onBarnizMaquinaChanged;
  final bool cambiarPrecioPlaca;
  final ValueChanged<bool?> onCambiarPrecioPlacaChanged;
  final bool cambiarPrecioTinta;
  final ValueChanged<bool?> onCambiarPrecioTintaChanged;
  final bool cambiarPrecioBarniz;
  final ValueChanged<bool?> onCambiarPrecioBarnizChanged;
  final TextEditingController cantidadPlacas790Controller;
  final TextEditingController costoPlaca790Controller;
  final TextEditingController costoTotalPlacas790Controller;
  final TextEditingController millaresController;
  final List<String> opcionesFrente;
  final List<String> opcionesVuelta;

  final bool barnizFte;
  final bool barnizRev;

  final TextEditingController barnizFteController;
  final TextEditingController barnizRevController;

  final TextEditingController costoUnitBarnizFteController;
  final TextEditingController costoUnitBarnizRevController;

  final Function(bool) onBarnizFteChanged;
  final Function(bool) onBarnizRevChanged;
  final ValueChanged<String?> onConfiguracionFrenteChanged;
  final ValueChanged<String?> onConfiguracionVueltaChanged;
  final String? valorInicialFrente;
  final String? valorInicialVuelta;
  final TextEditingController totalHojasController;

  // Datos de segmentación del pliego
  final TextEditingController? pliegoAnchoController;
  final TextEditingController? pliegoAltoController;
  final String? tipoSegmentacion;

  const PanelMaquinaPliego({
    super.key,
    required this.nombreMaquinaController,
    required this.costoPlacaController,
    required this.tintasFteController,
    required this.tintasRevController,
    required this.costoUnitFteController,
    required this.costoTotalFteController,
    required this.costoUnitRevController,
    required this.costoTotalRevController,
    required this.costoGranTotalTintasController,
    required this.cantidadPlacasController,
    required this.costoBarnizController,
    required this.costoTotalPlacasController,
    required this.onBarnizMaquinaChanged,
    required this.cambiarPrecioPlaca,
    required this.onCambiarPrecioPlacaChanged,
    required this.cambiarPrecioTinta,
    required this.onCambiarPrecioTintaChanged,
    required this.cambiarPrecioBarniz,
    required this.onCambiarPrecioBarnizChanged,
    required this.cantidadPlacas790Controller,
    required this.costoPlaca790Controller,
    required this.costoTotalPlacas790Controller,
    required this.millaresController,
    required this.opcionesFrente,
    required this.opcionesVuelta,
    required this.barnizFte,
    required this.barnizRev,
    required this.onBarnizFteChanged,
    required this.onBarnizRevChanged,
    required this.barnizFteController,
    required this.barnizRevController,
    required this.costoUnitBarnizFteController,
    required this.costoUnitBarnizRevController,
    required this.onConfiguracionFrenteChanged,
    required this.onConfiguracionVueltaChanged,
    required this.valorInicialFrente,
    required this.valorInicialVuelta,
    required this.totalHojasController,
    this.pliegoAnchoController,
    this.pliegoAltoController,
    this.tipoSegmentacion,
  });

  @override
  ConsumerState<PanelMaquinaPliego> createState() => _PanelMaquinaPliegoState();
}

class _PanelMaquinaPliegoState extends ConsumerState<PanelMaquinaPliego> {
  String? _opcionFrente;
  String? _opcionVuelta;

  bool _usar615EnEspecial = true;
  bool _usar790EnEspecial = false;

  @override
  void initState() {
    super.initState();

    _opcionFrente = widget.valorInicialFrente;
    _opcionVuelta = widget.valorInicialVuelta;

    final int cant615 = int.tryParse(widget.cantidadPlacasController.text) ?? 0;
    final int cant790 =
        int.tryParse(widget.cantidadPlacas790Controller.text) ?? 0;
    if (cant790 > 0 && cant615 == 0) {
      _usar615EnEspecial = false;
      _usar790EnEspecial = true;
    } else if (cant615 > 0 && cant790 > 0) {
      _usar615EnEspecial = true;
      _usar790EnEspecial = true;
    }

    widget.tintasFteController.addListener(_calcularCostosTintas);
    widget.tintasRevController.addListener(_calcularCostosTintas);
    widget.totalHojasController.addListener(_calcularCostosTintas);

    widget.pliegoAnchoController?.addListener(_onSegmentacionChanged);
    widget.pliegoAltoController?.addListener(_onSegmentacionChanged);

    widget.cantidadPlacasController.addListener(_calcularTotalPlacas);
    widget.costoPlacaController.addListener(_calcularTotalPlacas);
    widget.cantidadPlacas790Controller.addListener(_calcularTotalPlacas790);
    widget.costoPlaca790Controller.addListener(_calcularTotalPlacas790);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actualizarListasOpciones();
      _calcularCostosTintas();
      _cargarCostoPlacaDefault();
    });
  }

  @override
  void didUpdateWidget(covariant PanelMaquinaPliego oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tipoSegmentacion != widget.tipoSegmentacion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _calcularCostosTintas();
      });
    }
  }

  @override
  void dispose() {
    widget.tintasFteController.removeListener(_calcularCostosTintas);
    widget.tintasRevController.removeListener(_calcularCostosTintas);
    widget.totalHojasController.removeListener(_calcularCostosTintas);
    widget.pliegoAnchoController?.removeListener(_onSegmentacionChanged);
    widget.pliegoAltoController?.removeListener(_onSegmentacionChanged);
    widget.cantidadPlacasController.removeListener(_calcularTotalPlacas);
    widget.costoPlacaController.removeListener(_calcularTotalPlacas);
    widget.cantidadPlacas790Controller.removeListener(_calcularTotalPlacas790);
    widget.costoPlaca790Controller.removeListener(_calcularTotalPlacas790);
    super.dispose();
  }

  void _onSegmentacionChanged() {
    if (mounted) {
      setState(() {});
      _calcularCostosTintas();
    }
  }

  bool _esPar(double a, double b, double refA, double refB) {
    return ((a - refA).abs() < 0.05 && (b - refB).abs() < 0.05) ||
        ((a - refB).abs() < 0.05 && (b - refA).abs() < 0.05);
  }

  String get _modoSegmentacion {
    final String titulo = (widget.tipoSegmentacion ?? '').toLowerCase();
    if (titulo.contains('especial')) return 'especial';
    if (titulo.contains('mitad')) return 'mitad';
    if (titulo.contains('extendido')) return 'extendido';

    final double ancho =
        double.tryParse(widget.pliegoAnchoController?.text ?? '') ?? 0.0;
    final double alto =
        double.tryParse(widget.pliegoAltoController?.text ?? '') ?? 0.0;

    if (ancho <= 0 || alto <= 0) return 'especial';

    if (_esPar(ancho, alto, 57.0, 43.5) ||
        _esPar(ancho, alto, 70.0, 47.5) ||
        _esPar(ancho, alto, 61.0, 45.0) ||
        _esPar(ancho, alto, 72.0, 51.0)) {
      return 'mitad';
    }

    if (_esPar(ancho, alto, 57.0, 87.0) ||
        _esPar(ancho, alto, 70.0, 95.0) ||
        _esPar(ancho, alto, 61.0, 90.0) ||
        _esPar(ancho, alto, 72.0, 102.0) ||
        _esPar(ancho, alto, 58.0, 88.0)) {
      return 'extendido';
    }

    return 'especial';
  }

  void _actualizarListasOpciones() {
    final int cantFteInt = int.tryParse(widget.tintasFteController.text) ?? 0;
    final int cantRevInt = int.tryParse(widget.tintasRevController.text) ?? 0;

    setState(() {
      widget.opcionesFrente.clear();
      widget.opcionesFrente.addAll(_generarOpciones(cantFteInt));

      widget.opcionesVuelta.clear();
      widget.opcionesVuelta.addAll(_generarOpciones(cantRevInt));

      if (!widget.opcionesFrente.contains(_opcionFrente)) {
        _opcionFrente = null;
      }
      if (!widget.opcionesVuelta.contains(_opcionVuelta)) {
        _opcionVuelta = null;
      }
    });
  }

  List<String> _generarOpciones(int cantidad) {
    if (cantidad <= 0) return [];
    if (cantidad == 1) {
      return [
        "8 OFICIOS TINTA CMYK",
        "8 OFICIOS PLASTA PANTONE UNA CABEZA CMYK",
        "8 OFICIOS PLASTA PANTONE DOS CABEZAS CMYK",
        "4 CARTAS POR SELECCIÓN",
        "4 CARTAS PANTONE LINEA",
        "4 CARTAS PANTONE PLASTA",
        "8 OFICIOS DE 20 pts PANTONE LINEA",
        "OTRO",
      ];
    }
    if (cantidad == 2) {
      return [
        "8 OFICIO 2 COLORES",
        "8 OFICIO 1 COLOR 1 PLASTA UNA CABEZA CMYK",
        "8 OFICIO 1 COLOR 1 PLASTA DOS CABEZAS CMYK",
        "4 CARTA 2 COLORES",
        "OTRO",
      ];
    }
    if (cantidad == 3) {
      return [
        "8 OFICIO 3 COLORES",
        "8 OFICIO 2 COLORES 1 PLASTA UNA CABEZA CMYK",
        "8 OFICIO 2 COLORES 1 PLASTA DOS CABEZAS CMYK",
        "4 CARTA 3 COLORES",
        "OTRO",
      ];
    }
    if (cantidad == 4) {
      return [
        "8 OFICIO 4 COLORES",
        "4 CARTA 4 COLORES",
        "8 OFICIO 20 PTS 4 COLORES",
        "OTRO",
      ];
    }
    return ["OTRO"];
  }

  void _calcularCostosTintas() {
    final extrasState = ref.read(extrasProvider);
    double costoFijoTinta = 0.0;

    try {
      final extraTintas = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'tintas',
      );
      costoFijoTinta = extraTintas.costoFijo ?? 0.0;
    } catch (e) {
      costoFijoTinta = 0.0;
    }

    final int cantFteInt = int.tryParse(widget.tintasFteController.text) ?? 0;
    final int cantRevInt = int.tryParse(widget.tintasRevController.text) ?? 0;
    final double totalHojas =
        double.tryParse(widget.totalHojasController.text) ?? 0;
    final double millaresDouble = totalHojas / 1000;

    int millares = (millaresDouble - millaresDouble.floor() <= 0.5)
        ? millaresDouble.floor()
        : millaresDouble.ceil();

    if (millares <= 0 && totalHojas > 0) millares = 1;

    final int totalPlacasCalculadas = cantFteInt + cantRevInt;
    final String stringTotalPlacas =
        totalPlacasCalculadas > 0 ? totalPlacasCalculadas.toString() : "0";

    final String modo = _modoSegmentacion;

    if (modo == 'mitad') {
      if (widget.cantidadPlacasController.text != stringTotalPlacas) {
        widget.cantidadPlacasController.text = stringTotalPlacas;
      }
      if (widget.cantidadPlacas790Controller.text != "0") {
        widget.cantidadPlacas790Controller.text = "0";
      }
    } else if (modo == 'extendido') {
      if (widget.cantidadPlacasController.text != "0") {
        widget.cantidadPlacasController.text = "0";
      }
      if (widget.cantidadPlacas790Controller.text != stringTotalPlacas) {
        widget.cantidadPlacas790Controller.text = stringTotalPlacas;
      }
    } else {
      final String str615 = _usar615EnEspecial ? stringTotalPlacas : "0";
      final String str790 = _usar790EnEspecial ? stringTotalPlacas : "0";

      if (widget.cantidadPlacasController.text != str615) {
        widget.cantidadPlacasController.text = str615;
      }
      if (widget.cantidadPlacas790Controller.text != str790) {
        widget.cantidadPlacas790Controller.text = str790;
      }
    }

    _calcularTotalPlacas();
    _calcularTotalPlacas790();

    _actualizarListasOpciones();

    double precioFte = 0.0;
    double precioRev = 0.0;

    if (cantFteInt > 0 && _opcionFrente != null && millares > 0) {
      precioFte = _calcularPrecioPorOpcion(_opcionFrente!, millares);
    } else {
      precioFte = cantFteInt > 0 ? costoFijoTinta : 0.0;
    }

    if (cantRevInt > 0 && _opcionVuelta != null && millares > 0) {
      precioRev = _calcularPrecioPorOpcion(_opcionVuelta!, millares);
    } else {
      precioRev = cantRevInt > 0 ? costoFijoTinta : 0.0;
    }

    widget.costoUnitFteController.text = precioFte.toStringAsFixed(2);
    widget.costoUnitRevController.text = precioRev.toStringAsFixed(2);

    double costoTotalFte = precioFte * millares;
    double costoTotalRev = precioRev * millares;

    widget.costoTotalFteController.text = costoTotalFte.toStringAsFixed(2);
    widget.costoTotalRevController.text = costoTotalRev.toStringAsFixed(2);

    widget.costoGranTotalTintasController.text =
        (costoTotalFte + costoTotalRev).toStringAsFixed(2);

    double precioBarnizFte = 0;
    double precioBarnizRev = 0;

    if (widget.barnizFte && millares > 0 && _opcionFrente != null) {
      bool es20Pts = _opcionFrente!.toUpperCase().contains("20");
      precioBarnizFte = _calcularPrecioBarniz(es20Pts, millares);
    }

    if (widget.barnizRev && millares > 0 && _opcionVuelta != null) {
      bool es20Pts = _opcionVuelta!.toUpperCase().contains("20");
      precioBarnizRev = _calcularPrecioBarniz(es20Pts, millares);
    }

    double totalBarniz = (widget.barnizFte || widget.barnizRev)
        ? (precioBarnizFte + precioBarnizRev)
        : 0;
    widget.costoBarnizController.text = totalBarniz.toStringAsFixed(2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onConfiguracionFrenteChanged(_opcionFrente);
      widget.onConfiguracionVueltaChanged(_opcionVuelta);
    });
  }

  double _calcularPrecioPorOpcion(String opcion, int millares) {
    switch (opcion) {
      case "8 OFICIOS TINTA CMYK":
        if (millares <= 1) return 700;
        if (millares == 2) return 600;
        if (millares >= 3 && millares <= 4) return 525;
        if (millares >= 5 && millares <= 6) return 500;
        if (millares >= 7 && millares <= 10) return 460;
        if (millares >= 11 && millares <= 15) return 425;
        if (millares >= 16 && millares <= 20) return 390;
        if (millares >= 21 && millares <= 30) return 380;
        if (millares >= 31 && millares <= 50) return 350;
        return 330;
      case "8 OFICIOS PLASTA PANTONE UNA CABEZA CMYK":
        if (millares <= 1) return 1800;
        if (millares <= 4) return 1400;
        if (millares <= 30) return 1100;
        return 1000;
      case "8 OFICIOS PLASTA PANTONE DOS CABEZAS CMYK":
        if (millares <= 1) return 2300;
        if (millares >= 2 && millares <= 4) return 1900;
        if (millares >= 5 && millares <= 6) return 1400;
        if (millares >= 7 && millares <= 10) return 1300;
        if (millares >= 11 && millares <= 31) return 1200;
        return 1200;
      case "4 CARTAS POR SELECCIÓN":
        return 450;
      case "4 CARTAS PANTONE LINEA":
        return 600;
      case "4 CARTAS PANTONE PLASTA":
        return 800;
      case "8 OFICIOS DE 20 pts PANTONE LINEA":
        if (millares == 1) return 3000;
        if (millares == 2) return 2000;
        return 1800;
      case "8 OFICIO 2 COLORES":
        if (millares <= 1) return 1100;
        if (millares == 2) return 900;
        if (millares >= 3 && millares <= 4) return 780;
        if (millares >= 5 && millares <= 6) return 750;
        if (millares >= 7 && millares <= 10) return 690;
        if (millares >= 11 && millares <= 15) return 640;
        if (millares >= 16 && millares <= 20) return 585;
        if (millares >= 21 && millares <= 30) return 570;
        if (millares >= 31 && millares <= 50) return 525;
        return 495;
      case "8 OFICIO 1 COLOR 1 PLASTA UNA CABEZA CMYK":
        if (millares <= 1) return 2500;
        if (millares == 2) return 2000;
        if (millares >= 3 && millares <= 4) return 1925;
        if (millares >= 5 && millares <= 6) return 1600;
        if (millares >= 7 && millares <= 10) return 1560;
        if (millares >= 11 && millares <= 15) return 1525;
        if (millares >= 16 && millares <= 20) return 1490;
        if (millares >= 21 && millares <= 30) return 1380;
        if (millares >= 31 && millares <= 50) return 1350;
        return 1330;
      case "8 OFICIO 1 COLOR 1 PLASTA DOS CABEZAS CMYK":
        if (millares <= 1) return 3000;
        if (millares == 2) return 2500;
        if (millares >= 3 && millares <= 4) return 2425;
        if (millares >= 5 && millares <= 6) return 1900;
        if (millares >= 7 && millares <= 10) return 1760;
        if (millares >= 11 && millares <= 15) return 1625;
        if (millares >= 16 && millares <= 20) return 1590;
        if (millares >= 21 && millares <= 30) return 1580;
        if (millares >= 31 && millares <= 50) return 1550;
        return 1530;
      case "4 CARTA 2 COLORES":
        return 700;
      case "8 OFICIO 3 COLORES":
        if (millares <= 1) return 1200;
        if (millares == 2) return 1035;
        if (millares >= 3 && millares <= 4) return 910;
        if (millares >= 5 && millares <= 6) return 860;
        if (millares >= 7 && millares <= 10) return 795;
        if (millares >= 11 && millares <= 15) return 735;
        if (millares >= 16 && millares <= 20) return 675;
        if (millares >= 21 && millares <= 30) return 660;
        if (millares >= 31 && millares <= 50) return 610;
        return 570;
      case "8 OFICIO 2 COLORES 1 PLASTA UNA CABEZA CMYK":
        if (millares <= 1) return 2850;
        if (millares == 2) return 2300;
        if (millares >= 3 && millares <= 4) return 2180;
        if (millares >= 5 && millares <= 6) return 1850;
        if (millares >= 7 && millares <= 10) return 1790;
        if (millares >= 11 && millares <= 15) return 1740;
        if (millares >= 16 && millares <= 20) return 1685;
        if (millares >= 21 && millares <= 30) return 1670;
        if (millares >= 31 && millares <= 50) return 1525;
        return 1495;
      case "8 OFICIO 2 COLORES 1 PLASTA DOS CABEZAS CMYK":
        if (millares <= 1) return 3350;
        if (millares == 2) return 2800;
        if (millares >= 3 && millares <= 4) return 2680;
        if (millares >= 5 && millares <= 6) return 2150;
        if (millares >= 7 && millares <= 10) return 1990;
        if (millares >= 11 && millares <= 15) return 1840;
        if (millares >= 16 && millares <= 20) return 1758;
        if (millares >= 21 && millares <= 30) return 1770;
        if (millares >= 31 && millares <= 50) return 1725;
        return 1695;
      case "4 CARTA 3 COLORES":
        return 800;
      case "8 OFICIO 4 COLORES":
        if (millares <= 1) return 1400;
        if (millares == 2) return 1200;
        if (millares >= 3 && millares <= 4) return 1050;
        if (millares >= 5 && millares <= 6) return 1000;
        if (millares >= 7 && millares <= 10) return 920;
        if (millares >= 11 && millares <= 15) return 850;
        if (millares >= 16 && millares <= 20) return 780;
        if (millares >= 21 && millares <= 30) return 760;
        if (millares >= 31 && millares <= 50) return 700;
        return 660;
      case "4 CARTA 4 COLORES":
        return 900;
      case "8 OFICIO 20 PTS 4 COLORES":
        if (millares == 1) return 4800;
        if (millares == 2) return 4400;
        return 3800;
      default:
        return 0;
    }
  }

  double _calcularPrecioBarniz(bool es20Pts, int millares) {
    if (es20Pts) {
      if (millares <= 1) return 2000;
      if (millares <= 2) return 1500;
      return 1300;
    }
    if (millares <= 1) return 1000;
    if (millares == 2) return 750;
    if (millares >= 3 && millares <= 4) return 750;
    if (millares >= 5 && millares <= 31) return 700;
    return 650;
  }

  void _cargarCostoPlacaDefault() {
    if (widget.costoPlacaController.text.isNotEmpty &&
        widget.costoPlacaController.text != "0" &&
        widget.costoPlacaController.text != "0.0") {
      return;
    }
    final extrasState = ref.read(extrasProvider);
    try {
      final extraPlacas = extrasState.extras.firstWhere(
        (e) => e.nombre.trim().toLowerCase() == 'placas',
      );
      double costoFijoPlaca = extraPlacas.costoFijo ?? 0.0;
      if (costoFijoPlaca > 0) {
        widget.costoPlacaController.text = costoFijoPlaca.toStringAsFixed(2);
        _calcularTotalPlacas();
      }
    } catch (e) {}
  }

  void _calcularTotalPlacas() {
    final String modo = _modoSegmentacion;
    final bool activa =
        modo == 'mitad' || (modo == 'especial' && _usar615EnEspecial);

    if (!activa) {
      if (widget.costoTotalPlacasController.text != "0.00") {
        widget.costoTotalPlacasController.text = "0.00";
      }
      return;
    }

    final double cantidad =
        double.tryParse(widget.cantidadPlacasController.text) ?? 0.0;
    final double costoUnitario =
        double.tryParse(widget.costoPlacaController.text) ?? 0.0;
    final String nuevoTotal = (cantidad * costoUnitario).toStringAsFixed(2);
    if (widget.costoTotalPlacasController.text != nuevoTotal) {
      widget.costoTotalPlacasController.text = nuevoTotal;
    }
  }

  void _calcularTotalPlacas790() {
    final String modo = _modoSegmentacion;
    final bool activa =
        modo == 'extendido' || (modo == 'especial' && _usar790EnEspecial);

    if (!activa) {
      if (widget.costoTotalPlacas790Controller.text != "0.00") {
        widget.costoTotalPlacas790Controller.text = "0.00";
      }
      return;
    }

    final double cantidad =
        double.tryParse(widget.cantidadPlacas790Controller.text) ?? 0.0;
    final double costoUnitario =
        double.tryParse(widget.costoPlaca790Controller.text) ?? 0.0;
    final String nuevoTotal = (cantidad * costoUnitario).toStringAsFixed(2);
    if (widget.costoTotalPlacas790Controller.text != nuevoTotal) {
      widget.costoTotalPlacas790Controller.text = nuevoTotal;
    }
  }

  void _buscarMaquina() {
    showDialog(
      context: context,
      builder: (_) => DialogoSelectorMaquina(
        onSeleccionado: (maquina) {
          widget.nombreMaquinaController.text = maquina.nombre;
          widget.costoPlacaController.text = maquina.costoPlaca615x724
              .toStringAsFixed(2);
          widget.costoPlaca790Controller.text = maquina.costoPlaca790x1030
              .toStringAsFixed(2);
          _calcularTotalPlacas();
          _calcularTotalPlacas790();
        },
      ),
    );
  }

  void _agregarMaquina(BuildContext context, WidgetRef ref, Maquina? maquina) {
    showDialog(
      context: context,
      builder: (context) => ModalMaquina(
        titulo: maquina == null ? 'Nueva Máquina' : 'Modificar Máquina',
        maquinaInicial: maquina,
        onGuardar: (nuevaMaquina) async {
          bool success = maquina == null
              ? await ref
                    .read(maquinasProvider.notifier)
                    .crearMaquina(nuevaMaquina)
              : await ref
                    .read(maquinasProvider.notifier)
                    .actualizarMaquina(nuevaMaquina);

          if (success && context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  maquina == null ? 'Máquina creada' : 'Máquina actualizada',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(extrasProvider, (prev, next) {
      _calcularCostosTintas();
      _cargarCostoPlacaDefault();
    });

    final String modo = _modoSegmentacion;
    final bool esEspecial = modo == 'especial';
    final bool habilitarSeccion615 = modo == 'mitad' || esEspecial;
    final bool habilitarSeccion790 = modo == 'extendido' || esEspecial;

    final bool usar615 =
        modo == 'mitad' || (esEspecial && _usar615EnEspecial);
    final bool usar790 =
        modo == 'extendido' || (esEspecial && _usar790EnEspecial);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Datos Máquina de Impresión a Usar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: widget.nombreMaquinaController,
                    decoration: const InputDecoration(
                      labelText: "Nombre de la Máquina",
                      border: OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _buscarMaquina,
                  icon: const Icon(Icons.search),
                  tooltip: "Buscar máquina",
                ),
                IconButton(
                  onPressed: () => _agregarMaquina(context, ref, null),
                  icon: const Icon(Icons.add),
                  tooltip: "Agregar máquina",
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Tintas a Utilizar en la Impresión:"),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 55,
                      child: TextField(
                        controller: widget.tintasFteController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("X"),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 55,
                      child: TextField(
                        controller: widget.tintasRevController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.barnizFte,
                      onChanged: (value) {
                        widget.onBarnizFteChanged(value ?? false);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _calcularCostosTintas(),
                        );
                      },
                    ),
                    const Text("Barniz Frente"),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.barnizRev,
                      onChanged: (value) {
                        widget.onBarnizRevChanged(value ?? false);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _calcularCostosTintas(),
                        );
                      },
                    ),
                    const Text("Barniz Vuelta"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.opcionesFrente.isNotEmpty) ...[
              const Text("Configuración Frente:"),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _opcionFrente,
                items: widget.opcionesFrente
                    .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _opcionFrente = value);
                  widget.onConfiguracionFrenteChanged(value);
                  _calcularCostosTintas();
                },
              ),
            ],
            const SizedBox(height: 16),
            if (widget.opcionesVuelta.isNotEmpty) ...[
              const Text("Configuración Vuelta:"),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _opcionVuelta,
                items: widget.opcionesVuelta
                    .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _opcionVuelta = value);
                  widget.onConfiguracionVueltaChanged(value);
                  _calcularCostosTintas();
                },
              ),
            ],
            Row(
              children: [
                Checkbox(
                  value: widget.cambiarPrecioTinta,
                  onChanged: widget.onCambiarPrecioTintaChanged,
                ),
                const Text("Cambiar precio por tinta"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Costo Tinta Frontal (Millar):"),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoUnitFteController,
                        readOnly: !widget.cambiarPrecioTinta,
                      ),
                      const SizedBox(height: 8),
                      const Text("Subtotal Frente:"),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoTotalFteController,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Costo Tinta Reverso (Millar):"),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoUnitRevController,
                        readOnly: !widget.cambiarPrecioTinta,
                      ),
                      const SizedBox(height: 8),
                      const Text("Subtotal Reverso:"),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoTotalRevController,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Costo Total Tintas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _MonedaInput(
              controller: widget.costoGranTotalTintasController,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            // =========================================================
            // SECCIÓN PLACAS 615 X 724 (MITAD DEL PLIEGO O ESPECIAL)
            // =========================================================
            Opacity(
              opacity: habilitarSeccion615 ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !habilitarSeccion615,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: usar615 ? Colors.white : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: usar615 ? Colors.orange.shade700 : Colors.grey,
                      width: usar615 ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (esEspecial)
                            Checkbox(
                              value: _usar615EnEspecial,
                              onChanged: (val) {
                                setState(() {
                                  _usar615EnEspecial = val ?? false;
                                });
                                _calcularCostosTintas();
                              },
                            ),
                          Expanded(
                            child: Text(
                              "Placas 615 X 724 (Mitad del Pliego)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: usar615
                                    ? Colors.orange.shade900
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text("Cantidad Placas 615 X 724:"),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: widget.cantidadPlacasController,
                          enabled: usar615,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text("Costo por Placa 615 X 724:"),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoPlacaController,
                        readOnly: !widget.cambiarPrecioPlaca || !usar615,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Costo Total Placas 615 X 724:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoTotalPlacasController,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // SECCIÓN PLACAS 790 X 1030 (PLIEGO EXTENDIDO O ESPECIAL)
            // =========================================================
            Opacity(
              opacity: habilitarSeccion790 ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !habilitarSeccion790,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: usar790 ? Colors.white : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: usar790 ? Colors.orange.shade700 : Colors.grey,
                      width: usar790 ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (esEspecial)
                            Checkbox(
                              value: _usar790EnEspecial,
                              onChanged: (val) {
                                setState(() {
                                  _usar790EnEspecial = val ?? false;
                                });
                                _calcularCostosTintas();
                              },
                            ),
                          Expanded(
                            child: Text(
                              "Placas 790 X 1030 (Pliego Extendido)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: usar790
                                    ? Colors.orange.shade900
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text("Cantidad Placas 790 X 1030:"),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: widget.cantidadPlacas790Controller,
                          enabled: usar790,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text("Costo por Placa 790 X 1030:"),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoPlaca790Controller,
                        readOnly: !widget.cambiarPrecioPlaca || !usar790,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Costo Total Placas 790 X 1030:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _MonedaInput(
                        controller: widget.costoTotalPlacas790Controller,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: widget.cambiarPrecioPlaca,
                  onChanged: widget.onCambiarPrecioPlacaChanged,
                ),
                const Text("Cambiar Precio Por Placa:"),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: widget.cambiarPrecioBarniz,
                  onChanged: widget.onCambiarPrecioBarnizChanged,
                ),
                const Text("Cambiar precio barniz"),
              ],
            ),
            const Text(
              "Costo Barniz de Máquina:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _MonedaInput(
              controller: widget.costoBarnizController,
              readOnly: !widget.cambiarPrecioBarniz,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MonedaInput extends StatelessWidget {
  final TextEditingController? controller;
  final bool readOnly;
  const _MonedaInput({this.controller, this.readOnly = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixText: "\$ ",
        border: const OutlineInputBorder(),
        isDense: true,
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFEEEEEE) : null,
      ),
    );
  }
}