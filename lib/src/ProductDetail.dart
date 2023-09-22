import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String nome;
  final double preco;
  final String imageUrl;
  final String marca;
  final String sabor;
  final String caracteristica;

  ProductDetailPage(
      {required this.nome,
      required this.preco,
      required this.imageUrl,
      required this.marca,
      required this.sabor,
      required this.caracteristica});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
        backgroundColor: Color.fromARGB(255, 156, 144, 230),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Image.network(imageUrl),
                ),
                Text(
                  'Nome do Produto: $nome',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Preço: R\$ ${preco.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Sabor: $sabor',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Marca: $marca',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Caracteristica: $caracteristica',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
