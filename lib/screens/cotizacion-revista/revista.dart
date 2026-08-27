// revista.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'revista_cliente.dart';
import 'cantidad_pliegos.dart';
import '../../models/cotizacion_model.dart';
import '../../providers/cotizacion_provider.dart';
import '../../providers/auth_provider.dart';



class RevistaPage extends ConsumerStatefulWidget {
  final Cotizacion? cotizacionAEditar;
  final int? piezasOverride;
  final bool esRecotizacion;

  const RevistaPage({
    super.key,
    this.cotizacionAEditar,
    this.piezasOverride,
    this.esRecotizacion = false,
  });

  @override
  ConsumerState<RevistaPage> createState() => _RevistaPageState();
}


class _RevistaPageState extends ConsumerState<RevistaPage> {
  final GlobalKey<RevistaClienteState> _clienteKey = GlobalKey<RevistaClienteState>();
  final GlobalKey<CantidadPliegosState> _pliegosKey = GlobalKey<CantidadPliegosState>();

  int cantidadDePliegos = 0;
  int piezasTotales = 0; // 🔥 Nueva variable para los cálculos matemáticos

  List<Map<String, dynamic>>? _pliegosDatosIniciales;

  String? clienteIdInicial;
  String? clienteNombreInicial;
  String? proyectoInicial;
  String? descripcionInicial;
  double? anchoMedidaInicial;
  double? altoMedidaInicial;
  int? cantidadPliegosInicial;
  int? piezasTotalesInicial;

  @override
  void initState() {
    super.initState();

    final cotizacion = widget.cotizacionAEditar;
    if (cotizacion != null) {
      clienteIdInicial = cotizacion.clienteId;
      clienteNombreInicial = cotizacion.clienteNombre;
      descripcionInicial = cotizacion.descripcion;
      anchoMedidaInicial = cotizacion.anchoMedida;
      altoMedidaInicial = cotizacion.altoMedida;
      cantidadPliegosInicial = cotizacion.totalPliegos;
      // Recotización: si viene un piezasOverride, manda sobre el valor guardado.
      piezasTotalesInicial = widget.piezasOverride ?? cotizacion.cantidadImpresiones;

      // FIX: CantidadPliegos calcula todo con estas dos variables del padre,
      // no con lo que se ve en pantalla en RevistaCliente. Y RevistaCliente
      // solo las reporta hacia arriba vía onChanged, que NO se dispara al
      // asignar .text por código dentro de su propio initState (eso solo
      // actualiza lo que se ve, no el estado de esta pantalla).
      cantidadDePliegos = cantidadPliegosInicial ?? 0;
      piezasTotales = piezasTotalesInicial ?? 0;

      final configPliegos = cotizacion.configPliegos;
      if (configPliegos != null) {
        final pliegosGuardados = configPliegos['detalle_pliegos'];
        if (pliegosGuardados is List) {
          _pliegosDatosIniciales = pliegosGuardados.map((e) => e as Map<String, dynamic>).toList();
        } else {
          _pliegosDatosIniciales = [];
        }
      }
    }
  }

  Future<void> _guardarCotizacion() async {
    final authState = ref.read(authProvider);
    final String? usuarioIdActual = authState.usuario?.id;

    if (usuarioIdActual == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay una sesión activa')),
      );
      return;
    }

    final clienteState = _clienteKey.currentState;
    final pliegosState = _pliegosKey.currentState;

    if (clienteState == null || pliegosState == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron leer los datos de la pantalla')),
      );
      return;
    }

    final datosCliente = clienteState.obtenerDatos();
    final datosProduccion = pliegosState.obtenerResumenParaGuardar();

    final int piezas = datosCliente['piezas_totales'] ?? 0;
    final int totalPliegosCapturados = datosCliente['cantidad_pliegos'] ?? 0;
    final double ancho = datosCliente['ancho_medida'] ?? 0.0;
    final double alto = datosCliente['alto_medida'] ?? 0.0;
    final double precioSinIva = datosProduccion['precio_descuento'] ?? 0.0;
    final double precioUnitario = datosProduccion['precio_unitario'] ?? 0.0;
    final double precioConIva = datosProduccion['precio_con_iva'] ?? 0.0;
    final String? clienteIdReal = datosCliente['cliente_id'] as String?;

    // Recotización: aunque cargamos datos desde cotizacionAEditar, se guarda
    // como una cotización NUEVA (no se pisa la original).
    final bool esNuevo = widget.cotizacionAEditar == null || widget.esRecotizacion;

    final nuevaCotizacion = Cotizacion(
      id: esNuevo ? null : widget.cotizacionAEditar?.id,
      folio: esNuevo ? null : widget.cotizacionAEditar?.folio,
      fechaCreacion: esNuevo ? null : widget.cotizacionAEditar?.fechaCreacion,
      clienteId: clienteIdReal!,
      usuarioId: usuarioIdActual,
      descripcion: datosCliente['descripcion'] ?? '',
      anchoMedida: ancho,
      altoMedida: alto,
      tintaFrontal: 0,
      tintaReverso: 0,
      cantidadImpresiones: piezas,
      totalPliegos: totalPliegosCapturados,
      precioSinIva: precioSinIva,
      precioUnitario: precioUnitario,
      precioConIva: precioConIva,
      status: esNuevo
          ? 'Esperando Aprobacion'
          : (widget.cotizacionAEditar?.status ?? 'Esperando Aprobacion'),
      tipoCotizacion: 'R',

      configClientes: {
        'cliente_nombre': datosCliente['cliente_nombre'],
        'proyecto': datosCliente['proyecto'],
        'descripcion': datosCliente['descripcion'],
      },

      configPliegos: {
        'cantidad_pliegos': totalPliegosCapturados,
        'detalle_pliegos': datosProduccion['pliegos'],
      },

      configCostoTotal: {
        'costo_total_produccion': datosProduccion['costo_total_produccion'],
        'margen': datosProduccion['margen'],
        'descuento': datosProduccion['descuento'],
        'dias_entrega': datosProduccion['dias_entrega'],
        'precio_utilidad': datosProduccion['precio_utilidad'],
        'precio_descuento': datosProduccion['precio_descuento'],
        'precio_unitario': datosProduccion['precio_unitario'],
        'iva': datosProduccion['iva'],
        'precio_con_iva': datosProduccion['precio_con_iva'],
      },
    );

    final bool exito = esNuevo
        ? await ref.read(cotizacionesProvider.notifier).crearCotizacion(nuevaCotizacion)
        : await ref.read(cotizacionesProvider.notifier).actualizarCotizacion(nuevaCotizacion);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito
              ? !esNuevo
                  ? 'Cotización revista actualizada'
                  : 'Cotización revista guardada'
              : 'No se pudo guardar la cotización revista',
        ),
      ),
    );

    if (exito && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cotización Revista")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          
          // HOJA 1: Datos Cliente (Escucha cambios de pliegos y piezas)
          RevistaCliente(
            key: _clienteKey,
            onPliegosChanged: (value) {
              setState(() {
                cantidadDePliegos = int.tryParse(value) ?? 0;
              });
            },
            onPiezasChanged: (value) {
              setState(() {
                piezasTotales = int.tryParse(value) ?? 0;
              });
            },

            clienteIdInicial: clienteIdInicial,
            clienteNombreInicial: clienteNombreInicial,
            proyectoInicial: proyectoInicial,
            descripcionInicial: descripcionInicial,
            anchoMedidaInicial: anchoMedidaInicial,
            altoMedidaInicial: altoMedidaInicial,
            cantidadPliegosInicial: cantidadPliegosInicial,
            piezasTotalesInicial: piezasTotalesInicial,
          ),

          const SizedBox(height: 20),

          // HOJA 2: Procesos por Pliego (Recibe ambos datos obligatorios)
          CantidadPliegos(
            key: _pliegosKey,
            numeroDePliegos: cantidadDePliegos,
            piezasTotales: piezasTotales,
            datosIniciales: _pliegosDatosIniciales,
          ),
          
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: _guardarCotizacion,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cotización Completa'),
          ),
        ],
      ),
    );
  }
}