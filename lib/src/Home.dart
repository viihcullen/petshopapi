import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  final CollectionReference _racao =
      FirebaseFirestore.instance.collection('ração');

  XFile? _imageFile; // Variável para armazenar a imagem selecionada

  Future<void> _pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery, // Ou ImageSource.camera para tirar uma foto
    );
    setState(() {
      _imageFile = pickedFile; // Armazena a imagem selecionada
    });
  }

  Future<String> _uploadImageToFirebaseStorage(XFile imageFile) async {
    final storage = FirebaseStorage.instance;
    final imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    final reference = storage.ref().child('images/$imageFileName.jpg');

    final uploadTask = reference.putFile(File(imageFile.path));
    final snapshot = await uploadTask.whenComplete(() {});

    if (snapshot.state == TaskState.success) {
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } else {
      throw Exception("Failed to upload image");
    }
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';

      _nomeController.text = documentSnapshot['nome'];
      _marcaController.text = documentSnapshot['marca'];
      _precoController.text = documentSnapshot['preco'].toString();
      _saborController.text = documentSnapshot['sabor'];
      _caracteristicasController.text = documentSnapshot['caracteristicas'];
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
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
                decoration: const InputDecoration(labelText: 'Carcteristicas'),
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  final String? nome = _nomeController.text;
                  final String? marca = _marcaController.text;
                  final String? preco = _precoController.text;
                  final String? sabor = _saborController.text;
                  final String? caracteristicas =
                      _caracteristicasController.text;

                  if (nome != null &&
                      marca != null &&
                      preco != null &&
                      sabor != null &&
                      caracteristicas != null) {
                    final XFile? imageFile = await _pickImage(context);
                    if (imageFile != null) {
                      final imageUrl =
                          await _uploadImageToFirebaseStorage(imageFile);

                      if (action == 'create') {
                        await _racao.add({
                          "nome": nome,
                          "marca": marca,
                          "preco": preco,
                          "sabor": sabor,
                          "caracteristicas": caracteristicas,
                          "image_url": imageUrl,
                        });
                      }

                      if (action == 'update') {
                        await _racao.doc(documentSnapshot!.id).update({
                          "nome": nome,
                          "marca": marca,
                          "preco": preco,
                          "sabor": sabor,
                          "caracteristicas": caracteristicas,
                          "image_url": imageUrl,
                        });
                      }

                      _nomeController.text = '';
                      _marcaController.text = '';
                      _precoController.text = '';
                      _saborController.text = '';
                      _caracteristicasController.text = '';

                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
              ElevatedButton(
                child: Text(
                    'Pick Image'), // Adicione um botão para selecionar uma imagem
                onPressed: () async {
                  await _pickImage(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    await _racao.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully deleted a product'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PetShop Purple"),
        backgroundColor: Color.fromARGB(255, 156, 144, 230),
      ),
      body: StreamBuilder(
        stream: _racao.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return _buildProductList(streamSnapshot.data!.docs);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 156, 144, 230),
      ),
    );
  }

  Widget _buildProductList(List<QueryDocumentSnapshot> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final DocumentSnapshot documentSnapshot = products[index];
        return _buildProductCard(documentSnapshot);
      },
    );
  }

  Widget _buildProductCard(DocumentSnapshot documentSnapshot) {
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
                icon: Icon(Icons.edit),
                onPressed: () => _createOrUpdate(documentSnapshot),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteProduct(documentSnapshot.id),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                nome: documentSnapshot['nome'],
                preco: documentSnapshot['preco'],
                imageUrl: documentSnapshot['image_url'],
              ),
            ),
          );
        },
      ),
    );
  }
}
