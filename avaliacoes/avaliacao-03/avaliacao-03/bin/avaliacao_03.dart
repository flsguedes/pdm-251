//import 'package:avaliacao_03/avaliacao_03.dart' as avaliacao_03;
import 'dart:io';
import 'dart:async';
import 'dart:isolate';


void main() async {
  String meuNome = "Lucas Guedes";
  print(meuNome);


  // Criando um isolate para executar uma operação assíncrona
  final receivePort = ReceivePort();
  await Isolate.spawn(doAsyncOperation, [receivePort.sendPort, meuNome]);


  // Executando outras tarefas enquanto aguarda a conclusão da operação assíncrona
  print('Iniciando outras tarefas...');
  await Future.delayed(Duration(seconds: 1));
  print('Continuando outras tarefas...');


  // Recebendo o resultado da operação assíncrona
  final result = await receivePort.first;
  print('Resultado: $result');
}


void doAsyncOperation(List<dynamic> message) {
  // Executando uma operação assíncrona em um isolate separado
  SendPort sendPort = message[0];
  String nomeRecebido = message[1];
  
  print('Nome recebido do isolate: $nomeRecebido');

  Future.delayed(Duration(seconds:2),() {
    sendPort.send('Operaão concluída com sucesso para $nomeRecebido');
  });

}
