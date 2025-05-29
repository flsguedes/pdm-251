import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  String username = 'digiteseuemail@exemplo.com.br';
  String password = 'suasenhasmtp';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'digite seu nome')
    ..recipients.add('email@exemplo.com.br')
    ..subject = 'Avaliacao_05'
    ..text = 'Realizando avaliacao'
    ..html = "<h1>Corpo do e-mail em HTML</h1>";

  try {
    final sendReport = await send(message, smtpServer);
    print('Mensagem enviada: ' + sendReport.toString());
  } catch (e) {
    print('Erro ao enviar mensagem: $e');
  }
}
