import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/cotizacion_model.dart';

Future<Uint8List> generarCotizacionPdf({
  required Cotizacion cotizacion,
  required String nombreEmisor,
  required String rfc,
  required String atencion,
  required String impreso,
  required String acabados,
  required String tiempoEntrega,
  required String rutaFirma,
}) async {
  final pdf = pw.Document();

  pw.MemoryImage? bgImage;
  pw.MemoryImage? firmaImage;

  try {
    final bgBytes = await rootBundle.load('assets/fondo.png');
    bgImage = pw.MemoryImage(bgBytes.buffer.asUint8List());
  } catch (e) {
    print("Fondo no encontrado, se usará fondo blanco");
  }

  try {
    final firmaBytes = await rootBundle.load(rutaFirma);
    firmaImage = pw.MemoryImage(firmaBytes.buffer.asUint8List());
  } catch (e) {
    print("Firma no encontrada en la ruta: $rutaFirma");
  }

  final configCliente = cotizacion.configClientes ?? {};
  final configPapel = cotizacion.configDatosPapel ?? {};

  final String folio = cotizacion.folio ?? 'S/F';
  final String cliente =
      configCliente['razonSocial'] ?? cotizacion.clienteNombre ?? '';
  final String fechaStr = cotizacion.fechaCreacion != null
      ? DateFormat('dd-MMM-yy', 'es').format(cotizacion.fechaCreacion!)
      : '';

  final String proyecto = configCliente['proyecto'] ?? '';
  final String medida =
      '${cotizacion.anchoMedida} X ${cotizacion.altoMedida} CM';

  String material = '';
  if (configPapel['interior']?['nombre'] != null &&
      configPapel['interior']?['nombre'].toString().isNotEmpty == true) {
    material = configPapel['interior']['nombre'];
  } else if (configPapel['portada']?['nombre'] != null) {
    material = configPapel['portada']['nombre'];
  }

  final String cantidadStr = NumberFormat(
    '#,##0',
  ).format(cotizacion.cantidadImpresiones);
  final String unitarioStr =
      '\$ ${cotizacion.precioUnitario.toStringAsFixed(2)}';
  final String totalStr =
      '\$ ${NumberFormat('#,##0.00').format(cotizacion.precioSinIva)}';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            if (bgImage != null)
              pw.Positioned.fill(
                child: pw.Image(bgImage, fit: pw.BoxFit.cover),
              ),

            pw.Padding(
              padding: const pw.EdgeInsets.only(
                left: 105,
                top: 50,
                right: 40,
                bottom: 40,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          nombreEmisor.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'RFC: $rfc',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          'DIRECCIÓN: MIXTECAS 499 BIS, AJUSCO, COYOACÁN, 04300 CIUDAD DE MÉXICO, CDMX',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  pw.Center(
                    child: pw.Container(
                      color: const PdfColor.fromInt(0xFFE8EBF2),
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 5,
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'COTIZACIÓN ',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              folio,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFFDE291D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'CLIENTE: ${cliente.toUpperCase()}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            'FECHA: ${fechaStr.toUpperCase()}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            'ATENCIÓN:  ${atencion.toUpperCase()}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3.5),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.2),
                      3: const pw.FlexColumnWidth(1.2),
                      4: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFE8EBF2),
                        ),
                        children: [
                          _buildHeaderCell('DESCRIPCIÓN'),
                          _buildHeaderCell('UNIDAD'),
                          _buildHeaderCell('CANTIDAD'),
                          _buildHeaderCell('UNITARIO'),
                          _buildHeaderCell('COSTO TOTAL'),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 5,
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'PRODUCTO: ',
                                      style: const pw.TextStyle(fontSize: 9),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        proyecto.toUpperCase(),
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 10),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'MEDIDA: ',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        medida,
                                        style: const pw.TextStyle(fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'MATERIAL: ',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        material.toUpperCase(),
                                        style: const pw.TextStyle(fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'IMPRESO: ',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        impreso.toUpperCase(),
                                        style: const pw.TextStyle(fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      'ACABADOS: ',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        acabados.toUpperCase(),
                                        style: const pw.TextStyle(fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildDataCell('PIEZAS'),
                          _buildDataCell(cantidadStr),
                          _buildDataCell(unitarioStr),
                          _buildDataCell(totalStr),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  pw.Container(
                    width: double.infinity,
                    color: const PdfColor.fromInt(0xFFE8EBF2),
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'CONDICIONES COMERCIALES',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'ESTOS COSTOS, NO INCLUYEN EL 16% DE IVA.',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'TIEMPO DE ENTREGA :  ${tiempoEntrega.toUpperCase()}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'FORMA DE PAGO:  50% ANTICIPO Y 50% CONTRAENTREGA',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  pw.Text(
                    'AGRADECIENDO LA ATENCIÓN A LA PRESENTE, QUEDO ATENTA A SUS COMENTARIOS.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Column(
                      children: [
                        if (firmaImage != null)
                          pw.Image(firmaImage, height: 60),
                        if (firmaImage == null) pw.SizedBox(height: 60),
                        pw.Text(
                          nombreEmisor.toUpperCase(),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeaderCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(0xFF0A1C40),
      ),
    ),
  );
}

pw.Widget _buildDataCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 2),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 10),
    ),
  );
}
