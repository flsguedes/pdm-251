import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.open('alunos.db');

  // Criação da tabela TB_ALUNO se não existir
  db.execute('''
    CREATE TABLE IF NOT EXISTS TB_ALUNO(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome VARCHAR(50) NOT NULL
    );
  ''');

  print('Bem-vindo ao gerenciador de alunos SQLite!');

  while (true) {
    print('\nEscolha uma opção:');
    print('1 - Inserir novo aluno');
    print('2 - Listar alunos');
    print('3 - Deletar aluno');
    print('0 - Sair');

    stdout.write('Opção: ');
    final option = stdin.readLineSync();

    if (option == '1') {
      inserirAluno(db);
    } else if (option == '2') {
      listarAlunos(db);
    } else if (option == '3') {
      deletarAluno(db);
    } else if (option == '0') {
      print('Saindo do programa...');
      db.dispose();
      break;
    } else {
      print('Opção inválida. Tente novamente.');
    }
  }
}

void inserirAluno(Database db) {
  stdout.write('Digite o nome do aluno (máx 50 caracteres): ');
  String? nome = stdin.readLineSync();

  if (nome == null || nome.trim().isEmpty) {
    print('Nome inválido. Operação cancelada.');
    return;
  }

  nome = nome.trim();

  if (nome.length > 50) {
    print('Nome muito grande. Limite de 50 caracteres.');
    return;
  }

  final stmt = db.prepare('INSERT INTO TB_ALUNO (nome) VALUES (?)');
  stmt.execute([nome]);
  stmt.dispose();

  print('Aluno "$nome" inserido com sucesso!');
}

void listarAlunos(Database db) {
  final ResultSet resultSet =
      db.select('SELECT id, nome FROM TB_ALUNO ORDER BY id ASC');

  if (resultSet.isEmpty) {
    print('Nenhum aluno encontrado na tabela.');
    return;
  }

  print('\nLista de alunos:');
  for (final row in resultSet) {
    print('ID: ${row['id']} - Nome: ${row['nome']}');
  }
}

void deletarAluno(Database db) {
  stdout.write('Digite o ID do aluno que deseja deletar: ');
  String? inputId = stdin.readLineSync();

  if (inputId == null || inputId.trim().isEmpty) {
    print('ID inválido. Operação cancelada.');
    return;
  }

  int? id = int.tryParse(inputId.trim());
  if (id == null) {
    print('ID deve ser um número inteiro válido.');
    return;
  }

  final stmt = db.prepare('DELETE FROM TB_ALUNO WHERE id = ?');
  final changes = stmt.execute([id]);
  stmt.dispose();

  // A propriedade changes não é exposta direto, então verificamos se o aluno existia antes para mostrar mensagem
  // Vamos consultar antes para saber
  final rows = db.select('SELECT COUNT(*) as count FROM TB_ALUNO WHERE id = ?', [id]);
  if (rows.isEmpty || rows.first['count'] == 0) {
    print('Aluno com ID $id removido com sucesso.');
  } else {
    print('Aluno com ID $id não encontrado.');
  }
}
