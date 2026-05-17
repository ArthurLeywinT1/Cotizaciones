import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/orden_trabajo_provider.dart';
import 'sections/adquisiciones_section.dart';
import 'sections/corte_section.dart';
import 'sections/serigrafia_section.dart';
import 'sections/diseno_section.dart';
import 'sections/offset_section.dart';
import 'sections/laminados_section.dart';
import 'sections/suaje_section.dart';
import 'sections/grabado_section.dart';
import 'sections/acabado_section.dart';
import 'sections/embalaje_section.dart';
import 'sections/logistica_section.dart';
import 'sections/barnizuvsection.dart';

class ProduccionScreen extends ConsumerStatefulWidget {
  final String cotizacionId;
  final String area;

  const ProduccionScreen({
    super.key,
    required this.cotizacionId,
    required this.area,
  });

  @override
  ConsumerState<ProduccionScreen> createState() => _ProduccionScreenState();
}

class _ProduccionScreenState extends ConsumerState<ProduccionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ordenTrabajoProvider.notifier)
          .cargarDatosPorId(widget.cotizacionId, ref);
    });
  }

  List<Widget> _obtenerTarjetasPorRol() {
    final String rol = widget.area.toLowerCase().trim();
    List<Widget> tarjetas = [];

    if (rol == 'admin') {
      tarjetas.add(const AdquisicionesSection(modoProduccion: true));
      tarjetas.add(const BarnizUVSection(modoProduccion: true));
    }

    if (rol == 'diseño' || rol == 'diseno' || rol == 'pre-prensa') {
      tarjetas.add(const DisenoSection(modoProduccion: true));
    }

    if (rol == 'offset') {
      tarjetas.add(const OffsetSection(modoProduccion: true));
    }

    if (rol == 'corte') {
      tarjetas.add(const CorteSection(modoProduccion: true));
    }

    if (rol == 'laminado' || rol == 'laminados') {
      tarjetas.add(const LaminadosSection(modoProduccion: true));
    }

    if (rol == 'suaje') {
      tarjetas.add(const SuajeSection(modoProduccion: true));
    }

    if (rol == 'serigrafia' || rol == 'serigrafía') {
      tarjetas.add(const SerigrafiaSection(modoProduccion: true));
    }

    if (rol == 'grabado') {
      tarjetas.add(const GrabadoSection(modoProduccion: true));
    }

    if (rol == 'acabado') {
      tarjetas.add(const AcabadoSection(modoProduccion: true));
      tarjetas.add(const EmbalajeSection(modoProduccion: true));
    }

    if (rol == 'barniz' || rol == 'otro') {
      tarjetas.add(const BarnizUVSection(modoProduccion: true));
    }

    if (rol == 'logistica' || rol == 'logística') {
      tarjetas.add(const LogisticaSection(modoProduccion: true));
    }

    if (tarjetas.isEmpty) {
      tarjetas.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "No hay secciones de producción asignadas para tu rol actual.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return tarjetas;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(ordenTrabajoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Proceso: ${widget.area.toUpperCase()} - Folio: ${controller.orderId}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: 16.0)),

                  ..._obtenerTarjetasPorRol(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
