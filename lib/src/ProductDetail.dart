import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String nome;
  final double preco;

  ProductDetailPage({required this.nome, required this.preco});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nome do Produto: $nome',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Preço: R\$ ${preco.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
