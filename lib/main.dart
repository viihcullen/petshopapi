import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshopapi/src/Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyB1MNNbIG_0TzonbHHTFfa7_pW234Ro78M",
        authDomain: "petshop-api-69dbb.firebaseapp.com",
        projectId: "petshop-api-69dbb",
        storageBucket: "petshop-api-69dbb.appspot.com",
        messagingSenderId: "810263902241",
        appId: "1:810263902241:web:2666dd1f6a58cdd9a60b60"),
  );

  runApp(PetShopApp());
}

class PetShopApp extends StatelessWidget {
  const PetShopApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetShop Purple',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 156, 144, 230),
      ),
      home: HomeScreen(),
    );
  }
}
