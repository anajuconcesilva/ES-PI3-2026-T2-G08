import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa o núcleo do Firebase
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:projeto/tela_detalhes.dart';

void main() async {
  // 1. Garante que os plugins do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase antes de rodar o App
  try {
    await Firebase.initializeApp();
    print("Firebase conectado com sucesso!");
  } catch (e) {
    print("Erro ao conectar no Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mescla Invest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1482C7)),
        useMaterial3: true,
      ),
      // 3. Define a sua tela de detalhes como a tela inicial
      home: const TelaDetalhesInformaEs(),
    );
  }
}