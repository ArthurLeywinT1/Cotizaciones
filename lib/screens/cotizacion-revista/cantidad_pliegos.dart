// cantidad_pliegos.dart
import 'package:flutter/material.dart';
import '../segmentacion.dart';
import 'datospapel_pliegos.dart'; 
import 'costoPapel_pliegos.dart';
import 'maquina_pliegos.dart';

class CantidadPliegos extends StatefulWidget {
  final int numeroDePliegos; 
  final int piezasTotales; 

  const CantidadPliegos({super.key, required this.numeroDePliegos, required this.piezasTotales});

  @override
  State<CantidadPliegos> createState() => _CantidadPliegosState();
}

class _CantidadPliegosState extends State<CantidadPliegos> {
  List<Map<String, dynamic>> datosPliegos = [];

  @override
  void initState() {
    super.initState();
    _inicializarDatos(); 
  }

  @override
  void didUpdateWidget(CantidadPliegos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numeroDePliegos != widget.numeroDePliegos || oldWidget.piezasTotales != widget.piezasTotales) {
      _limpiarControladores(); 
      _inicializarDatos();    
    }
  }

  void _limpiarControladores() {
    for (var pliego in datosPliegos) {
      pliego['anchoTrabajoCtrl']?.dispose();
      pliego['altoTrabajoCtrl']?.dispose();
      pliego['medianilCtrl']?.dispose();
      
      pliego['anchoPliegoCtrl']?.dispose();
      pliego['altoPliegoCtrl']?.dispose();
      pliego['orientacionCtrl']?.dispose();
      pliego['piezasController']?.dispose(); 
      
      pliego['cantidadOcuparCtrl']?.dispose();     
      pliego['cantidadTotalPliegoCtrl']?.dispose(); 
      pliego['pliegosExtraCtrl']?.dispose();
      pliego['cantidadPliegosCtrl']?.dispose();
      pliego['pliegosSobrantesCtrl']?.dispose();
      pliego['totalPliegosUtilizarCtrl']?.dispose();
      pliego['millaresImprimirCtrl']?.dispose();

      // 🧹 LIMPIEZA DE MEMORIA: Eliminamos los controladores de papel de este pliego
      pliego['nombrePapelCtrl']?.dispose();
      pliego['tipoPapelCtrl']?.dispose();
      pliego['anchoPapelCtrl']?.dispose();
      pliego['largoPapelCtrl']?.dispose();
      pliego['pesoPapelCtrl']?.dispose();
      pliego['proveedorPapelCtrl']?.dispose();
      pliego['costoMillarCtrl']?.dispose();
      pliego['totalPliegosCtrl']?.dispose();

      pliego['descuentoPapelCtrl']?.dispose();
      pliego['costoTotalPapelSinIvaCtrl']?.dispose();
      pliego['costoTotalPapelConIvaCtrl']?.dispose();

      pliego['nombreMaquinaCtrl']?.dispose();
      pliego['costoPlacaCtrl']?.dispose();
      pliego['tintasFteCtrl']?.dispose();
      pliego['tintasRevCtrl']?.dispose();
      pliego['costoUnitFteCtrl']?.dispose();
      pliego['costoTotalFteCtrl']?.dispose();
      pliego['costoUnitRevCtrl']?.dispose();
      pliego['costoTotalRevCtrl']?.dispose();
      pliego['costoGranTotalTintasCtrl']?.dispose();
      pliego['cantidadPlacasCtrl']?.dispose();
      pliego['costoBarnizCtrl']?.dispose();
      pliego['costoTotalPlacasCtrl']?.dispose();
      pliego['cantidadPlacas790Ctrl']?.dispose();
      pliego['costoPlaca790Ctrl']?.dispose();
      pliego['costoTotalPlacas790Ctrl']?.dispose();
      pliego['barnizFteCtrl']?.dispose();
      pliego['barnizRevCtrl']?.dispose();
      pliego['costoUnitBarnizFteCtrl']?.dispose();
      pliego['costoUnitBarnizRevCtrl']?.dispose();
      pliego['millaresCtrl']?.dispose();

      if (pliego['pruebasColor'] is Map) {
        (pliego['pruebasColor'] as Map).forEach((_, value) {
          value['cantidadController']?.dispose();
          value['precioController']?.dispose();
          value['totalController']?.dispose();
        });
      }
    }
  }

  @override
  void dispose() {
    _limpiarControladores(); 
    super.dispose();
  }

  void _inicializarDatos() {
    datosPliegos = List.generate(widget.numeroDePliegos, (index) {
      return {
        'titulo': 'Pliego ${index + 1}',
        'anchoTrabajoCtrl': TextEditingController(),
        'altoTrabajoCtrl': TextEditingController(),
        'medianilCtrl': TextEditingController(),
        
        'anchoPliegoCtrl': TextEditingController(),
        'altoPliegoCtrl': TextEditingController(),
        'orientacionCtrl': TextEditingController(),
        'piezasController': TextEditingController(), 
        
        'cantidadOcuparCtrl': TextEditingController(text: '1'), 
        'cantidadTotalPliegoCtrl': TextEditingController(text: '0.00'),
        'pliegosExtraCtrl': TextEditingController(text: '150'),
        'cantidadPliegosCtrl': TextEditingController(text: '0'),
        'pliegosSobrantesCtrl': TextEditingController(text: '0'),
        'totalPliegosUtilizarCtrl': TextEditingController(text: '0'),
        'millaresImprimirCtrl': TextEditingController(text: '0.00'),

        // 🧠 ALTA DE ESTADO: El mapa del pliego ahora es dueño de sus datos de papel
        'nombrePapelCtrl': TextEditingController(),
        'tipoPapelCtrl': TextEditingController(),
        'anchoPapelCtrl': TextEditingController(),
        'largoPapelCtrl': TextEditingController(),
        'pesoPapelCtrl': TextEditingController(),
        'proveedorPapelCtrl': TextEditingController(),
        'costoMillarCtrl': TextEditingController(),
        'totalPliegosCtrl': TextEditingController(),

        'descuentoPapelCtrl': TextEditingController(text: '0'),
        'costoTotalPapelSinIvaCtrl': TextEditingController(text: '0.00'),
        'costoTotalPapelConIvaCtrl': TextEditingController(text: '0.00'),
        
        // 🖨️ CONTROLADORES Y ESTADO DE LA MÁQUINA DE IMPRESIÓN
        'nombreMaquinaCtrl': TextEditingController(),
        'costoPlacaCtrl': TextEditingController(text: '0.00'),
        'tintasFteCtrl': TextEditingController(text: '0'),
        'tintasRevCtrl': TextEditingController(text: '0'),
        'costoUnitFteCtrl': TextEditingController(text: '0.00'),
        'costoTotalFteCtrl': TextEditingController(text: '0.00'),
        'costoUnitRevCtrl': TextEditingController(text: '0.00'),
        'costoTotalRevCtrl': TextEditingController(text: '0.00'),
        'costoGranTotalTintasCtrl': TextEditingController(text: '0.00'),
        'cantidadPlacasCtrl': TextEditingController(text: '0'),
        'costoBarnizCtrl': TextEditingController(text: '0.00'),
        'costoTotalPlacasCtrl': TextEditingController(text: '0.00'),
        'cantidadPlacas790Ctrl': TextEditingController(text: '0'),
        'costoPlaca790Ctrl': TextEditingController(text: '0.00'),
        'costoTotalPlacas790Ctrl': TextEditingController(text: '0.00'),
        'barnizFteCtrl': TextEditingController(),
        'barnizRevCtrl': TextEditingController(),
        'costoUnitBarnizFteCtrl': TextEditingController(text: '0.00'),
        'costoUnitBarnizRevCtrl': TextEditingController(text: '0.00'),
        'millaresCtrl': TextEditingController(text: '1'),

        // Booleanos y opciones de la máquina (estado local de cada pliego)
        'barnizMaquina': false,
        'cambiarPrecioPlaca': false,
        'cambiarPrecioTinta': false,
        'cambiarPrecioBarniz': false,
        'barnizFte': false,
        'barnizRev': false,
        'opcionesFrente': <String>[],
        'opcionesVuelta': <String>[],
        'configuracionFrente': null,
        'configuracionVuelta': null,

        'procesos': {
          'Offset': false,
          'Barniz UV': false,
          'Acabados Especiales': false,
          'Suaje': false,
          'Plastificado/Laminado': false,
          'Serigrafia': false,
          'Grabado': false,
        },
        
        'pruebasColor': {
          'Prueba de color carta': {
            'activo': false,
            'cantidadController': TextEditingController(),
            'precioController': TextEditingController(),
            'totalController': TextEditingController(text: '0.00'),
          },
          'Tabloide': {
            'activo': false,
            'cantidadController': TextEditingController(),
            'precioController': TextEditingController(),
            'totalController': TextEditingController(text: '0.00'),
          },
          'Media carta': {
            'activo': false,
            'cantidadController': TextEditingController(),
            'precioController': TextEditingController(),
            'totalController': TextEditingController(text: '0.00'),
          },
        }
      };
    });
  }

void _ejecutarCalculosProduccion(Map<String, dynamic> pliego) {
    int piezasTotalesSolicitadas = widget.piezasTotales;
    int cantidadOcupar = int.tryParse(pliego['cantidadOcuparCtrl'].text) ?? 0;
    int piezasPorPliego = int.tryParse(pliego['piezasController'].text) ?? 0;
    int pliegosExtra = int.tryParse(pliego['pliegosExtraCtrl'].text) ?? 0;

    if (piezasPorPliego > 0 && piezasTotalesSolicitadas > 0 && cantidadOcupar > 0) {
      double cantidadTotalPliego = (cantidadOcupar * piezasTotalesSolicitadas) / piezasPorPliego;
      pliego['cantidadTotalPliegoCtrl'].text = cantidadTotalPliego.toStringAsFixed(2);
      int cantidadPliegos = cantidadTotalPliego.ceil();
      pliego['cantidadPliegosCtrl'].text = cantidadPliegos.toString();
      int sobrantes = ((cantidadOcupar * piezasTotalesSolicitadas) % piezasPorPliego == 0) ? 0 : 1;
      pliego['pliegosSobrantesCtrl'].text = sobrantes.toString();
      
      int totalUtilizar = cantidadPliegos + pliegosExtra;
      pliego['totalPliegosUtilizarCtrl'].text = totalUtilizar.toString();
      
      // 🔥 ASIGNACIÓN CORREGIDA: Sincroniza la cantidad de pliegos de papel con el total a utilizar
      pliego['totalPliegosCtrl'].text = totalUtilizar.toString();

      double millares = totalUtilizar / 1000.0;
      pliego['millaresImprimirCtrl'].text = millares.toStringAsFixed(2);
    } else {
      pliego['cantidadTotalPliegoCtrl'].text = '0.00';
      pliego['cantidadPliegosCtrl'].text = '0';
      pliego['pliegosSobrantesCtrl'].text = '0';
      pliego['totalPliegosUtilizarCtrl'].text = '0';
      
      // 🚨 Limpieza en caso de que los valores de entrada sean vacíos o 0
      pliego['totalPliegosCtrl'].text = '0';
      
      pliego['millaresImprimirCtrl'].text = '0.00';
    }
  }

  void _calcularTotalPrueba(Map<String, dynamic> pruebaData) {
    double cantidad = double.tryParse(pruebaData['cantidadController'].text) ?? 0.0;
    double precio = double.tryParse(pruebaData['precioController'].text) ?? 0.0;
    double total = cantidad * precio;
    pruebaData['totalController'].text = total.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> prepararDatosParaBackend() {
    return datosPliegos.map((pliego) {
      final bool tieneOffset = pliego['procesos']['Offset'] ?? false;
      return {
        'titulo': pliego['titulo'],
        'piezas_por_pliego': int.tryParse(pliego['piezasController'].text) ?? 0,
        'procesos': pliego['procesos'], 
        'offset_data': tieneOffset ? {
          'ancho_trabajo': pliego['anchoTrabajoCtrl'].text,
          'alto_trabajo': pliego['altoTrabajoCtrl'].text,
          'medianil': pliego['medianilCtrl'].text,
          'ancho_pliego': pliego['anchoPliegoCtrl'].text,
          'alto_pliego': pliego['altoPliegoCtrl'].text,
          'orientacion_piezas': pliego['orientacionCtrl'].text,
          'pliegos_extra': pliego['pliegosExtraCtrl'].text,
          'cantidad_ocupar_de_este_pliego': pliego['cantidadOcuparCtrl'].text,
          'cantidad_total_del_pliego': pliego['cantidadTotalPliegoCtrl'].text,
          'cantidad_pliegos_calculados': pliego['cantidadPliegosCtrl'].text,
          'pliegos_sobrantes': pliego['pliegosSobrantesCtrl'].text,
          'total_pliegos_utilizar': pliego['totalPliegosUtilizarCtrl'].text,
          'millares_imprimir': pliego['millaresImprimirCtrl'].text,
          
          'papel_datos': {
            'nombre': pliego['nombrePapelCtrl'].text,
            'tipo': pliego['tipoPapelCtrl'].text,
            'ancho': pliego['anchoPapelCtrl'].text,
            'largo': pliego['largoPapelCtrl'].text,
            'peso': pliego['pesoPapelCtrl'].text,
            'proveedor': pliego['proveedorPapelCtrl'].text,
            'costo_millar': pliego['costoMillarCtrl'].text,
            'total_pliegos_asignados': pliego['totalPliegosCtrl'].text,

            'descuento_aplicado': pliego['descuentoPapelCtrl'].text,
            'costo_total_sin_iva': pliego['costoTotalPapelSinIvaCtrl'].text,
            'costo_total_con_iva': pliego['costoTotalPapelConIvaCtrl'].text,
          },

          'maquina_datos': {
            'nombre_maquina': pliego['nombreMaquinaCtrl'].text,
            'tintas_frente': pliego['tintasFteCtrl'].text,
            'tintas_reverso': pliego['tintasRevCtrl'].text,
            'costo_total_tintas': pliego['costoGranTotalTintasCtrl'].text,
            'costo_total_placas': pliego['costoTotalPlacasCtrl'].text,
            'costo_total_placas_790': pliego['costoTotalPlacas790Ctrl'].text,
            'costo_barniz': pliego['costoBarnizCtrl'].text,
            'configuracion_frente': pliego['configuracionFrente'],
            'configuracion_vuelta': pliego['configuracionVuelta'],
          },

          'pruebas_color': (pliego['pruebasColor'] as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, {
              'activo': value['activo'],
              'cantidad': int.tryParse(value['cantidadController'].text) ?? 0,
              'precio': double.tryParse(value['precioController'].text) ?? 0.0,
              'total': double.tryParse(value['totalController'].text) ?? 0.0,
            });
          }),
        } : null
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.numeroDePliegos <= 0) return const SizedBox.shrink();
    return Column(children: datosPliegos.map((pliego) => _buildCardPliego(pliego)).toList());
  }

  Widget _buildCardPliego(Map<String, dynamic> pliego) {
    bool esOffsetActivo = pliego['procesos']['Offset'] == true;

    double anchoTrabajo = double.tryParse(pliego['anchoTrabajoCtrl'].text) ?? 0.0;
    double altoTrabajo = double.tryParse(pliego['altoTrabajoCtrl'].text) ?? 0.0;
    double medianil = double.tryParse(pliego['medianilCtrl'].text) ?? 0.0;

    double anchoFinal = anchoTrabajo + medianil;
    double altoFinal = altoTrabajo + medianil;

    _ejecutarCalculosProduccion(pliego);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pliego['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            
            const Text('Procesos de trabajo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              children: (pliego['procesos'] as Map<String, bool>).keys.map((nombreProceso) {
                return SizedBox(
                  width: 200,
                  child: CheckboxListTile(
                    title: Text(nombreProceso, style: const TextStyle(fontSize: 14)),
                    value: pliego['procesos'][nombreProceso],
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? valor) {
                      setState(() { pliego['procesos'][nombreProceso] = valor!; });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (esOffsetActivo) ...[
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              const Text('Medidas del Trabajo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _buildInput('Ancho Trabajo (cm)', pliego['anchoTrabajoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Alto Trabajo (cm)', pliego['altoTrabajoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Medianil (cm)', pliego['medianilCtrl'], esNumerico: true)),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Medida Final (Trabajo + Medianil):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text('Ancho Final: ${anchoFinal.toStringAsFixed(2)} cm   |   Alto Final: ${altoFinal.toStringAsFixed(2)} cm',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.search),
                      style: IconButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        final Map<String, dynamic>? resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SegmentacionPliegosScreen(
                              anchoTrabajo: anchoFinal,
                              altoTrabajo: altoFinal,
                            ),
                          ),
                        );

                        if (resultado != null) {
                          setState(() {
                            pliego['anchoPliegoCtrl'].text = resultado['ancho']?.toString() ?? '0';
                            pliego['altoPliegoCtrl'].text = resultado['alto']?.toString() ?? '0';
                            pliego['orientacionCtrl'].text = resultado['posicion']?.toString() ?? 'Normal';
                            pliego['piezasController'].text = resultado['piezasPorPliego']?.toString() ?? '0';
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Opciones de Prueba de Color:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 10),
              Column(
                children: (pliego['pruebasColor'] as Map<String, dynamic>).keys.map((nombrePrueba) {
                  var pruebaData = pliego['pruebasColor'][nombrePrueba];
                  bool estaActivo = pruebaData['activo'] == true;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(nombrePrueba, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          value: estaActivo,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (bool? valor) {
                            setState(() {
                              pruebaData['activo'] = valor!;
                              if (!valor) {
                                pruebaData['cantidadController']?.clear();
                                pruebaData['precioController'].clear();
                                pruebaData['totalController'].text = '0.00';
                              }
                            });
                          },
                        ),
                        if (estaActivo)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0, top: 4, bottom: 12),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: pruebaData['cantidadController'],
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() => _calcularTotalPrueba(pruebaData)),
                                    decoration: const InputDecoration(labelText: 'Cantidad', floatingLabelBehavior: FloatingLabelBehavior.always, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: TextFormField(
                                    controller: pruebaData['precioController'],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (_) => setState(() => _calcularTotalPrueba(pruebaData)),
                                    decoration: const InputDecoration(labelText: 'Precio \$', floatingLabelBehavior: FloatingLabelBehavior.always, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: TextFormField(
                                    controller: pruebaData['totalController'],
                                    readOnly: true, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    decoration: InputDecoration(labelText: 'Total \$', floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, fillColor: Theme.of(context).disabledColor.withOpacity(0.06), border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 15),

              const Text('Datos Técnicos del Pliego Seleccionado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildInput('Ancho Pliego', pliego['anchoPliegoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Alto Pliego', pliego['altoPliegoCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Orientación', pliego['orientacionCtrl'])),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildInput('Piezas x Pliego plano', pliego['piezasController'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput('Cantidad pliegos extra (Merma)', pliego['pliegosExtraCtrl'], esNumerico: true)),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Resultados de Operación e Impresión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildInput('Cantidad a ocupar de este pliego', pliego['cantidadOcuparCtrl'], esNumerico: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputResultado('Cantidad Total del Pliego', pliego['cantidadTotalPliegoCtrl'])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInputResultado('Cantidad de Pliegos a Imprimir', pliego['cantidadPliegosCtrl'])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputResultado('Piezas Sobrantes', pliego['pliegosSobrantesCtrl'])),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputResultado('Total de Pliegos a Utilizar (Con Merma)', pliego['totalPliegosUtilizarCtrl']),
              const SizedBox(height: 12),
              _buildInputResultado('Millares a Imprimir', pliego['millaresImprimirCtrl']),
              
              // =======================================================================
              // 📦 COMPONENTE DE PAPEL REUBICADO AL FINAL DEL TODO
              // =======================================================================
              const SizedBox(height: 20),
              const Divider(color: Colors.blueGrey, thickness: 1),
              const SizedBox(height: 10),
              PanelDatosPapelPliego(
                nombrePapelController: pliego['nombrePapelCtrl'],
                tipoPapelController: pliego['tipoPapelCtrl'],
                anchoPapelController: pliego['anchoPapelCtrl'],
                largoPapelController: pliego['largoPapelCtrl'],
                pesoPapelController: pliego['pesoPapelCtrl'],
                proveedorPapelController: pliego['proveedorPapelCtrl'],
                costoMillarController: pliego['costoMillarCtrl'],
                totalPliegosController: pliego['totalPliegosCtrl'],
                minAnchoRequerido: anchoFinal,
                minAltoRequerido: altoFinal,
              ),
              PanelCostoPapelPliego(
                costoMillarController: pliego['costoMillarCtrl'],
                totalPliegosController: pliego['totalPliegosCtrl'],
                descuentoController: pliego['descuentoPapelCtrl'],
                costoTotalPapelController: pliego['costoTotalPapelSinIvaCtrl'],
                costoConIvaController: pliego['costoTotalPapelConIvaCtrl'],
              ),

              // =======================================================================
              // 🖨️ NUEVO COMPONENTE: PANEL DE LA MÁQUINA DE IMPRESIÓN
              // =======================================================================
              PanelMaquinaPliego(
                nombreMaquinaController: pliego['nombreMaquinaCtrl'],
                costoPlacaController: pliego['costoPlacaCtrl'],
                tintasFteController: pliego['tintasFteCtrl'],
                tintasRevController: pliego['tintasRevCtrl'],
                costoUnitFteController: pliego['costoUnitFteCtrl'],
                costoTotalFteController: pliego['costoTotalFteCtrl'],
                costoUnitRevController: pliego['costoUnitRevCtrl'],
                costoTotalRevController: pliego['costoTotalRevCtrl'],
                costoGranTotalTintasController: pliego['costoGranTotalTintasCtrl'],
                cantidadPlacasController: pliego['cantidadPlacasCtrl'],
                costoBarnizController: pliego['costoBarnizCtrl'],
                costoTotalPlacasController: pliego['costoTotalPlacasCtrl'],
                cantidadPlacas790Controller: pliego['cantidadPlacas790Ctrl'],
                costoPlaca790Controller: pliego['costoPlaca790Ctrl'],
                costoTotalPlacas790Controller: pliego['costoTotalPlacas790Ctrl'],
                barnizFteController: pliego['barnizFteCtrl'],
                barnizRevController: pliego['barnizRevCtrl'],
                costoUnitBarnizFteController: pliego['costoUnitBarnizFteCtrl'],
                costoUnitBarnizRevController: pliego['costoUnitBarnizRevCtrl'],
                millaresController: pliego['millaresCtrl'],
                totalHojasController: pliego['totalPliegosUtilizarCtrl'],
                opcionesFrente: pliego['opcionesFrente'],
                opcionesVuelta: pliego['opcionesVuelta'],
                valorInicialFrente: pliego['configuracionFrente'],
                valorInicialVuelta: pliego['configuracionVuelta'],
                
                // --- BOOLEANOS (Estado actual del pliego) ---
                barnizFte: pliego['barnizFte'],
                barnizRev: pliego['barnizRev'],
                cambiarPrecioPlaca: pliego['cambiarPrecioPlaca'],
                cambiarPrecioTinta: pliego['cambiarPrecioTinta'],
                cambiarPrecioBarniz: pliego['cambiarPrecioBarniz'],

                // --- CALLBACKS PARA ACTUALIZAR EL ESTADO DEL PLIEGO ---
                onBarnizMaquinaChanged: (v) {
                  setState(() => pliego['barnizMaquina'] = v ?? false);
                },
                onBarnizFteChanged: (v) {
                  setState(() => pliego['barnizFte'] = v);
                },
                onBarnizRevChanged: (v) {
                  setState(() => pliego['barnizRev'] = v);
                },
                onCambiarPrecioPlacaChanged: (v) {
                  setState(() => pliego['cambiarPrecioPlaca'] = v ?? false);
                },
                onCambiarPrecioTintaChanged: (v) {
                  setState(() => pliego['cambiarPrecioTinta'] = v ?? false);
                },
                onCambiarPrecioBarnizChanged: (v) {
                  setState(() => pliego['cambiarPrecioBarniz'] = v ?? false);
                },
                onConfiguracionFrenteChanged: (v) {
                  setState(() => pliego['configuracionFrente'] = v);
                },
                onConfiguracionVueltaChanged: (v) {
                  setState(() => pliego['configuracionVuelta'] = v);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool esNumerico = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: esNumerico ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      onChanged: (_) => setState(() {}), 
      style: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F)),
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.always, 
        filled: true,
        fillColor: const Color(0xFFF4F2F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.5), borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E), width: 1), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildInputResultado(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true, 
      style: const TextStyle(fontSize: 14, color: Color(0xFF1C1B1F), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF49454F), fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: const Color(0xFFE6E1E5).withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E)), borderRadius: BorderRadius.circular(4)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF79747E)), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}