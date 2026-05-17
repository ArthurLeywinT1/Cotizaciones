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
  final List<Map<String, String>> _usuariosPredefinidos = [
    {
      "nombre": "DANNIELA ADRIANA GONZÁLEZ MORÁN",
      "rfc": "GOMD9602012M3",
      "firma": "assets/firmaDaniela.jpg",
    },
    {
      "nombre": "ROBERTA MORAN SOTO",
      "rfc": "MOSR750510AN9",
      "firma": "assets/firmaRoberta.jpg",
    },
    {
      "nombre": "MARIA ISABEL VARELA BECERRA",
      "rfc": "VABI720416PC7",
      "firma": "assets/firmaIsabel.jpg",
    },
  ];

  Map<String, String>? _usuarioSeleccionado;

  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController rfcCtrl = TextEditingController();
  final TextEditingController atencionCtrl = TextEditingController();
  final TextEditingController impresoCtrl = TextEditingController();
  final TextEditingController acabadosCtrl = TextEditingController();
  final TextEditingController tiempoEntregaCtrl = TextEditingController(
    text: "DESPUÉS DEL PEDIDO 8 DÍAS HÁBILES",
  );

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _usuarioSeleccionado = _usuariosPredefinidos.first;
    nombreCtrl.text = _usuarioSeleccionado!["nombre"]!;
    rfcCtrl.text = _usuarioSeleccionado!["rfc"]!;
  }

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
        rutaFirma: _usuarioSeleccionado!["firma"]!,
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
            DropdownButtonFormField<Map<String, String>>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Emisor Rápido',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              value: _usuarioSeleccionado,
              items: _usuariosPredefinidos.map((user) {
                return DropdownMenuItem(
                  value: user,
                  child: Text(
                    user["nombre"]!,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _usuarioSeleccionado = val;
                    nombreCtrl.text = val["nombre"]!;
                    rfcCtrl.text = val["rfc"]!;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Usuario Emisor'),
              readOnly: true, // Bloqueado
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rfcCtrl,
              decoration: const InputDecoration(labelText: 'RFC Emisor'),
              readOnly: true, // Bloqueado
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
