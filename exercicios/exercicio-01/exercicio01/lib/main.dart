import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..carregarCarrinho(),
      child: MyApp(),
    ),
  );
}

// Classe única que contém:
// - modelo de item
// - carrinho com provider
// - lógica de persistência
// - telas
class AppState with ChangeNotifier {
  // Modelo de item
  static Item fromJson(Map<String, dynamic> json) =>
      Item(nome: json['nome'], valor: json['valor']);

  static Map<String, dynamic> toJson(Item item) =>
      {'nome': item.nome, 'valor': item.valor};

  final List<Item> _itens = [];

  List<Item> get itens => _itens;

  double get total => _itens.fold(0, (sum, item) => sum + item.valor);

  void adicionar(Item item) {
    _itens.add(item);
    notifyListeners();
    salvarCarrinho();
  }

  void remover(Item item) {
    _itens.remove(item);
    notifyListeners();
    salvarCarrinho();
  }

  Future<void> salvarCarrinho() async {
    final prefs = await SharedPreferences.getInstance();
    final itensJson = jsonEncode(_itens.map((e) => toJson(e)).toList());
    await prefs.setString('carrinho', itensJson);
  }

  Future<void> carregarCarrinho() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itensJson = prefs.getString('carrinho');
      if (itensJson != null) {
        final List decoded = jsonDecode(itensJson);
        _itens.clear();
        _itens.addAll(decoded.map((e) => fromJson(e)).toList());
        notifyListeners();
      }
    } catch (e) {
      // Se der erro (ex: corrompido), apenas ignora e começa vazio
    }
  }
}

// Modelo simples do item (como classe auxiliar)
class Item {
  final String nome;
  final double valor;

  Item({required this.nome, required this.valor});
}

// App principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinho com Provider',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TelaPrincipal(),
    );
  }
}

// Tela principal
class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final total = context.watch<AppState>().total;

    return Scaffold(
      appBar: AppBar(title: Text('Carrinho')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total: R\$ ${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaItens()),
                );
              },
              child: Text('Adicionar Itens'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de lista de itens disponíveis
class ListaItens extends StatelessWidget {
  final List<Item> itensDisponiveis = [
    Item(nome: 'Item 1', valor: 10.0),
    Item(nome: 'Item 2', valor: 20.0),
    Item(nome: 'Item 3', valor: 30.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Itens')),
      body: ListView.builder(
        itemCount: itensDisponiveis.length,
        itemBuilder: (context, index) {
          final item = itensDisponiveis[index];
          return ListTile(
            title: Text(item.nome),
            subtitle: Text('R\$ ${item.valor.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                context.read<AppState>().adicionar(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.nome} adicionado ao carrinho')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
