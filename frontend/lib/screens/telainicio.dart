//CÓDIGO FEITO PELA ALUNA: Ana Júlia Conceição da Silva
//RA: 25002592

import 'package:flutter/material.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio ({super.key});

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
                  Image.network(
                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aWcBwf6Kwt/s3ii9b48_expires_30_days.png",
                    width: 80,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  Image.network(
                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aWcBwf6Kwt/mc464upo_expires_30_days.png",
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF),
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
                    Navigator.pushNamed(context, '/cadastro');                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFD7DEE2),
                    side: const BorderSide(color: Color(0xFF1482C7)),
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
                Image.network(
                  "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aWcBwf6Kwt/8gz3bc2l_expires_30_days.png",
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  "2026 MesclaInvest",
                  style: TextStyle(color: Color(0xFF858788)),
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