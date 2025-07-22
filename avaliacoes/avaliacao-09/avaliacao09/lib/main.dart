import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// MODELO DE DADOS
class Usuario {
  final int id;
  final String nome;
  final String email;
  final String avatar;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.avatar,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: '${json['first_name']} ${json['last_name']}',
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}

// SERVIÇO DE API
class ApiService {
  static const _url = 'https://reqres.in/api/users?page=1';

  static Future<List<Usuario>> fetchUsuarios() async {
    final response =
        await http.get(Uri.parse(_url)).timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      List<dynamic> jsonData = jsonBody['data'];
      return jsonData.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar dados: ${response.statusCode}');
    }
  }
}

void main() => runApp(ApiListViewApp());

// APP
class ApiListViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API ListView Flutter',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: UsuariosPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// TELA PRINCIPAL
class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List<Usuario>> _futureUsuarios;
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  final _controllerPesquisa = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _futureUsuarios = ApiService.fetchUsuarios();
    });
    final usuarios = await _futureUsuarios;
    setState(() {
      _usuarios = usuarios;
      _usuariosFiltrados = usuarios;
    });
  }

  void _pesquisar(String texto) {
    final query = texto.toLowerCase();
    final filtrados = _usuarios.where((user) {
      return user.nome.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _usuariosFiltrados = filtrados;
    });
  }

  @override
  void dispose() {
    _controllerPesquisa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuários'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _carregarUsuarios();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lista atualizada')),
              );
            },
            tooltip: 'Recarregar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controllerPesquisa,
              decoration: InputDecoration(
                labelText: 'Buscar usuário',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _pesquisar,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              future: _futureUsuarios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Erro ao carregar usuários.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: _carregarUsuarios,
                    child: _usuariosFiltrados.isEmpty
                        ? Center(child: Text('Nenhum usuário encontrado.'))
                        : ListView.builder(
                            itemCount: _usuariosFiltrados.length,
                            itemBuilder: (context, index) {
                              final user = _usuariosFiltrados[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                elevation: 3,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(user.avatar),
                                  ),
                                  title: Text(user.nome),
                                  subtitle: Text(user.email),
                                ),
                              );
                            },
                          ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
