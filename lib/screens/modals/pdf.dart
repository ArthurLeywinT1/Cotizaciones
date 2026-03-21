import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/cotizacion_model.dart';
import '../../utils/generadorPDF.dart';

class DialogoGenerarPdf extends StatefulWidget {
  final Cotizacion cotizacion;

  const DialogoGenerarPdf({super.key, required this.cotizacion});

  @override
  State<DialogoGenerarPdf> createState() => _DialogoGenerarPdfState();
}

class _DialogoGenerarPdfState extends State<DialogoGenerarPdf> {
  final TextEditingController nombreCtrl = TextEditingController(
    text: "DANNIELA ADRIANA GONZÁLEZ MORÁN",
  );
  final TextEditingController rfcCtrl = TextEditingController(
    text: "GOMD9602012M3",
  );
  final TextEditingController atencionCtrl = TextEditingController();
  final TextEditingController impresoCtrl = TextEditingController();
  final TextEditingController acabadosCtrl = TextEditingController();
  final TextEditingController tiempoEntregaCtrl = TextEditingController(
    text: "DESPUÉS DEL PEDIDO 8 DÍAS HÁBILES",
  );

  bool _isGenerating = false;

  Future<void> _generarYMostrarPdf() async {
    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await generarCotizacionPdf(
        cotizacion: widget.cotizacion,
        nombreEmisor: nombreCtrl.text,
        rfc: rfcCtrl.text,
        atencion: atencionCtrl.text,
        impreso: impresoCtrl.text,
        acabados: acabadosCtrl.text,
        tiempoEntrega: tiempoEntregaCtrl.text,
      );

      if (!mounted) return;

      Navigator.pop(context);

      final folio = widget.cotizacion.folio ?? 'SF';
      final fileName = 'COTIZACION$folio.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      } else {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar Cotización PDF',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsBytes(pdfBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF guardado exitosamente')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    rfcCtrl.dispose();
    atencionCtrl.dispose();
    impresoCtrl.dispose();
    acabadosCtrl.dispose();
    tiempoEntregaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detalles para PDF (Folio: ${widget.cotizacion.folio})'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rfcCtrl,
              decoration: const InputDecoration(labelText: 'RFC'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: atencionCtrl,
              decoration: const InputDecoration(labelText: 'Atención'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: impresoCtrl,
              decoration: const InputDecoration(labelText: 'Impreso'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: acabadosCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Acabados'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tiempoEntregaCtrl,
              decoration: const InputDecoration(labelText: 'Tiempo de Entrega'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isGenerating ? null : _generarYMostrarPdf,
          child: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Previsualizar PDF'),
        ),
      ],
    );
  }
}
