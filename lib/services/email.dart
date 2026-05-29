import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static Future<void> enviarCorreo({
    required List<String> destinatarios,
    required String asunto,
    required String contenidoHtml,
  }) async {
    final String username = dotenv.env['SMTP_EMAIL'] ?? '';
    final String password = dotenv.env['SMTP_PASSWORD'] ?? '';

    if (username.isEmpty || password.isEmpty) {
      print('Error: Credenciales SMTP no configuradas en el archivo .env');
      return;
    }

    final smtpServer = gmail(username, password);

    final destinatariosLimpios = destinatarios
        .map((correo) => correo.trim())
        .where((correo) => correo.isNotEmpty)
        .toList();

    if (destinatariosLimpios.isEmpty) {
      print('Error: No hay destinatarios válidos para enviar el correo.');
      return;
    }

    final message = Message()
      ..from = Address(username, 'Sistema de Incidentes')
      ..recipients.addAll(destinatariosLimpios)
      ..subject = asunto
      ..html = contenidoHtml;

    try {
      final sendReport = await send(message, smtpServer);
      print('Mensaje enviado exitosamente: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Mensaje no enviado. \n${e.toString()}');
      for (var p in e.problems) {
        print('Problema: ${p.code}: ${p.msg}');
      }
    }
  }
}
