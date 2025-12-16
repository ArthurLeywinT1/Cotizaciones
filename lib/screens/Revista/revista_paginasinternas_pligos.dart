import 'package:flutter/material.dart';
import 'package:cotizador/screens/cotizacion-plana/cotizacion_plana_pliegos.dart';

class RevistaPaginasInternasPliegos extends StatelessWidget {
  final TextEditingController anchoFinalController;
  final TextEditingController altoFinalController;
  final TextEditingController pliegoAnchoController;
  final TextEditingController pliegoAltoController;
  final TextEditingController posicionPiezasController;
  final TextEditingController piezasPorPliegoController;
  final TextEditingController tamanoPorPliegoController;
  final TextEditingController cantidadImpresionesController;
  final TextEditingController cantidadPliegosController;
  final TextEditingController pliegosSobrantesController;
  final TextEditingController totalPliegosController;
  final TextEditingController millaresController;

  const RevistaPaginasInternasPliegos({
    super.key,
    required this.anchoFinalController,
    required this.altoFinalController,
    required this.pliegoAnchoController,
    required this.pliegoAltoController,
    required this.posicionPiezasController,
    required this.piezasPorPliegoController,
    required this.tamanoPorPliegoController,
    required this.cantidadImpresionesController,
    required this.cantidadPliegosController,
    required this.pliegosSobrantesController,
    required this.totalPliegosController,
    required this.millaresController,
  });

  @override
  Widget build(BuildContext context) {
    return PanelPliegos(
      anchoFinalController: anchoFinalController,
      altoFinalController: altoFinalController,
      pliegoAnchoController: pliegoAnchoController,
      pliegoAltoController: pliegoAltoController,
      posicionPiezasController: posicionPiezasController,
      piezasPorPliegoController: piezasPorPliegoController,
      tamanoPorPliegoController: tamanoPorPliegoController,
      cantidadImpresionesController: cantidadImpresionesController,
      cantidadPliegosController: cantidadPliegosController,
      pliegosSobrantesController: pliegosSobrantesController,
      totalPliegosController: totalPliegosController,
      millaresController: millaresController,
    );
  }
}
