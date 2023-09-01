import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProductDetail.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nomeController = TextEditingController();

  final TextEditingController _marcaController = TextEditingController();

  final TextEditingController _precoController = TextEditingController();

  final TextEditingController _saborController = TextEditingController();

  final TextEditingController _caracteristicasController =
      TextEditingController();

  //final TextEditingController _imageController = TextEditingController();

  final CollectionReference _racao =
      FirebaseFirestore.instance.collection('ração');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';

      _nomeController.text = documentSnapshot['nome'];

      _marcaController.text = documentSnapshot['marca'];

      _precoController.text = documentSnapshot['preco'].toString();

      _saborController.text = documentSnapshot['sabor'];

      _caracteristicasController.text = documentSnapshot['caracteristicas'];

      //_imageController.text = documentSnapshot['image'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Produto'),
                ),
                TextField(
                  controller: _marcaController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                ),
                TextField(
                  // keyboardType:
                  //    const TextInputType.numberWithOptions(decimal: true),
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                  ),
                ),
                TextField(
                  controller: _saborController,
                  decoration: const InputDecoration(labelText: 'Sabor'),
                ),
                TextField(
                  controller: _caracteristicasController,
                  decoration:
                      const InputDecoration(labelText: 'Carcteristicas'),
                ),
                //TextField(
                //controller: _imageController,
                //decoration: const InputDecoration(labelText: 'Imagem'),
                //),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? nome = _nomeController.text;

                    final String? marca = _marcaController.text;

                    // final double? preco =
                    // double.tryParse(_precoController.text);
                    final String? preco = _precoController.text;
                    final String? sabor = _saborController.text;

                    final String? caracteristicas =
                        _caracteristicasController.text;

                    // final String? image = _imageController.text;

                    if (nome != null &&
                        marca != null &&
                        preco != null &&
                        sabor != null &&
                        caracteristicas != null) {
                      if (action == 'create') {
// Persist a new product to Firestore

                        await _racao.add({
                          "nome": nome,
                          "marca": marca,
                          "preco": preco,
                          "sabor": sabor,
                          "caracteristicas": caracteristicas,
                        });
                      }

                      if (action == 'update') {
// Update the product

                        await _racao.doc(documentSnapshot!.id).update({
                          "nome": nome,
                          "marca": marca,
                          "preco": preco,
                          "sabor": sabor,
                          "caracteristicas": caracteristicas,
                        });
                      }

// Clear the text fields

                      _nomeController.text = '';

                      _marcaController.text = '';

                      _precoController.text = '';

                      _saborController.text = '';

                      _caracteristicasController.text = '';

                      // _imageController.text = '';

// Hide the bottom sheet

                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

// Deleteing a product by id

  Future<void> _deleteProduct(String productId) async {
    await _racao.doc(productId).delete();

// Show a snackbar

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// Using StreamBuilder to display all racao from Firestore in real-time

      body: StreamBuilder(
        stream: _racao.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['nome']),
                    subtitle: Text(documentSnapshot['preco'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            nome: documentSnapshot['nome'],
                            preco: documentSnapshot['preco'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

// Add new product

      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class pressed {}
