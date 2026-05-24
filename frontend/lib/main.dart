//CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
//RA:25002592

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mescla_invest_app/screens/tela_carteira.dart';
import 'package:mescla_invest_app/screens/tela_perfil.dart';
import 'package:mescla_invest_app/screens/tela_balcao_detalhes.dart';
import 'package:mescla_invest_app/screens/tela_balcao_lista.dart';
import 'package:mescla_invest_app/screens/tela_perguntas.dart';
import 'package:mescla_invest_app/screens/telaesqueci.dart';
import 'package:mescla_invest_app/screens/telarecuperacao.dart';
import 'package:mescla_invest_app/screens/telaredefinir.dart';
import 'package:mescla_invest_app/screens/telageral.dart';
import 'package:mescla_invest_app/screens/telacatalogo.dart';
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
        '/catalogo': (_) => const TelaCatalogo(),
        '/geral': (_) => const TelaGeral(),
        '/carteira': (_) => const TelaCarteira(),
        '/perfil': (_) => const TelaPerfil(),
        '/balcao': (_) => const TelaBalcaoLista(),
        '/perguntas': (_) => const TelaPerguntas(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/balcao_detalhes') {
          final args = settings.arguments as Map<String, String>;

          return MaterialPageRoute(
            builder: (_) => TelaBalcaoDetalhes(
              startupId: args['startupId'] ?? '',
              nome: args['nome'] ?? '',
              preco: args['preco'] ?? '0,00',
              imageUrl: args['imageUrl'] ?? '',
            ),
          );
        }

        return null;
      },
    );
  }
}
