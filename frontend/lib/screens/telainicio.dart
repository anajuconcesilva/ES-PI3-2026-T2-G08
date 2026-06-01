//CÓDIGO FEITO PELA ALUNA: Ana Júlia Conceição da Silva
//RA: 25002592

import 'package:flutter/material.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFB9DCE6),
        ),
        child: Column(
          children: [
            // TOPO COM GRADIENTE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 60),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF203D74),
                    Color(0xFFB9DCE6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // LOGO
                  Image.asset(
                    "assets/images/wallet.png",
                    width: 80,
                    height: 100,
                  ),

                  const SizedBox(height: 20),

                  // NOME
                  Image.asset(
                    "assets/images/Mescla-logo.png",
                    width: 200,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BOTÃO LOGIN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1482C7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÃO CADASTRO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cadastro');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFD7DEE2),
                    side: const BorderSide(
                      color: Color(0xFF1482C7),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Cadastre-se",
                    style: TextStyle(
                      color: Color(0xFF1482C7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // RODAPÉ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/copy-icon.png",
                  width: 18,
                  height: 18,
                ),

                const SizedBox(width: 6),

                const Text(
                  "2026 MesclaInvest",
                  style: TextStyle(
                    color: Color(0xFF858788),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}