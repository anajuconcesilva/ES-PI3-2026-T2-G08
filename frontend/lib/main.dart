import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:mescla_invest_app/screens/telaesqueci.dart';
import 'package:mescla_invest_app/screens/telarecuperacao.dart';
import 'package:mescla_invest_app/screens/telaredefinir.dart';
import 'screens/telainicio.dart';
import 'screens/telalogin.dart';
import 'screens/telacadastro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      initialRoute: '/inicio',
      routes: {
        '/inicio': (_) => const TelaInicio(),
        '/login': (_) => const TelaLogin(),
        '/cadastro': (_) => const TelaCadastro(),
        '/esqueci': (_) => const TelaEsqueci(),
        '/recuperacao': (_) => const TelaRecuperacao(),
        '/redefinir': (_) => const TelaRedefinir(),
      },
    );
  }
}