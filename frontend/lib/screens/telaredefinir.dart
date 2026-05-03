//CÓDIGO FEITO PELA ALUNA: Ana Júlia Conceição da Silva
//RA: 25002592

import 'package:flutter/material.dart';

class TelaRedefinir extends StatefulWidget {
  const TelaRedefinir({super.key});

  @override
  State<TelaRedefinir> createState() => _TelaNovaSenhaState();
}

class _TelaNovaSenhaState extends State<TelaRedefinir> {
  bool obscureSenha = true;
  bool obscureConfirm = true;

  final senhaController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBD9D9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [

                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.fromLTRB(25, 180, 25, 25),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔐 NOVA SENHA
                        const Text(
                          "Nova Senha",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF373737),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: senhaController,
                          obscureText: obscureSenha,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD6D5D5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureSenha
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureSenha = !obscureSenha;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Confirmar Senha",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF373737),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: confirmController,
                          obscureText: obscureConfirm,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD6D5D5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirm = !obscureConfirm;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // validação simples (sem backend)
                              if (senhaController.text ==
                                  confirmController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Senha redefinida com sucesso!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("As senhas não coincidem"),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1482C7),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Redefinir Senha",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Center(
                          child: Text(
                            "© 2026 MesclaInvest",
                            style: TextStyle(color: Color(0xFF858788)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: -5,
                    left: 45,
                    right: 25,
                    child: Row(
                      children: [
                        Container(
                          width: 90,
                          height: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF203D74),
                                Color(0xFFB9DCE6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              "assets/images/wallet.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(width: 30),

                        const Text(
                          "Redefinir Senha",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF373737),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}