//CÓDIGO FEITO PELA ALUNA: Ana Júlia Conceição da Silva
//RA: 25002592

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool obscureSenha = true;
  bool isLoading = false;

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> fazerLogin() async {
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      await user?.reload();

      if (!(user?.emailVerified ?? false)) {
        await FirebaseAuth.instance.signOut();

        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Verifique seu email antes de entrar.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login realizado com sucesso"),
        ),
      );

      Navigator.pushReplacementNamed(context, '/geral');
    } on FirebaseAuthMultiFactorException catch (e) {
      try {
        await _resolverMfaLogin(e);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login MFA realizado com sucesso"),
          ),
        );

        Navigator.pushReplacementNamed(context, '/geral');
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro MFA: $err"),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Erro ao fazer login";

      if (e.code == 'user-not-found') {
        msg = "Usuário não encontrado";
      } else if (e.code == 'wrong-password') {
        msg = "Senha incorreta";
      } else if (e.code == 'invalid-email') {
        msg = "Email inválido";
      } else if (e.code == 'email-not-verified') {
        msg = "Verifique seu email antes de entrar";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resolverMfaLogin(
      FirebaseAuthMultiFactorException e,
      ) async {
    final resolver = e.resolver;

    final hints = resolver.hints;

    if (hints.isEmpty) {
      throw Exception("Nenhum fator MFA encontrado");
    }

    final phoneHint = hints.first as PhoneMultiFactorInfo;

    String? verificationId;

    final completer = Completer<void>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorSession: resolver.session,
      multiFactorInfo: phoneHint,
      verificationCompleted: (credential) {},
      verificationFailed: (FirebaseAuthException error) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(error.message),
          );
        }
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (String verId) {},
    );

    await completer.future;

    if (verificationId == null) {
      throw Exception("Erro ao enviar código MFA");
    }

    final codigoController = TextEditingController();

    final codigo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Código MFA"),
          content: TextField(
            controller: codigoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "123456",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  codigoController.text,
                );
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (codigo == null || codigo.isEmpty) {
      throw Exception("Código não informado");
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: codigo,
    );

    final assertion = PhoneMultiFactorGenerator.getAssertion(
      credential,
    );

    await resolver.resolveSignIn(assertion);
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBD9D9),

      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),

            child: Column(
              children: [
                const SizedBox(height: 40),

                SizedBox(
                  height: MediaQuery.of(context).size.height,

                  child: Stack(
                    clipBehavior: Clip.none,

                    children: [
                      Container(
                        margin: EdgeInsets.zero,

                        padding: const EdgeInsets.fromLTRB(
                          25,
                          180,
                          25,
                          25,
                        ),

                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E8E8),

                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            // EMAIL
                            const Text(
                              "Email",

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF373737),
                              ),
                            ),

                            const SizedBox(height: 5),

                            TextField(
                              controller: emailController,

                              decoration: InputDecoration(
                                hintText:
                                "exemplo@mesclainvest.com",

                                filled: true,

                                fillColor:
                                const Color(0xFFD6D5D5),

                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),

                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // SENHA
                            const Text(
                              "Senha",

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

                                fillColor:
                                const Color(0xFFD6D5D5),

                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(15),

                                  borderSide: BorderSide.none,
                                ),

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureSenha
                                        ? Icons.visibility_off
                                        : Icons.visibility,

                                    color:
                                    const Color(0xFF858788),
                                  ),

                                  onPressed: () {
                                    setState(() {
                                      obscureSenha =
                                      !obscureSenha;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // BOTÃO ENTRAR
                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton(
                                onPressed:
                                isLoading
                                    ? null
                                    : fazerLogin,

                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(
                                    0xFF1482C7,
                                  ),

                                  padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      25,
                                    ),
                                  ),
                                ),

                                child:
                                isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,

                                  child:
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  "Entrar",

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // ESQUECEU SENHA
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/esqueci',
                                  );
                                },

                                child: const Text(
                                  "Esqueceu a Senha?",

                                  style: TextStyle(
                                    color: Color(0xFF1482C7),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // CADASTRO
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [
                                const Text(
                                  "Não possui uma conta? ",
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/cadastro',
                                    );
                                  },

                                  child: const Text(
                                    "Cadastre-se",

                                    style: TextStyle(
                                      color:
                                      Color(0xFF1482C7),

                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            const Center(
                              child: Text(
                                "© 2026 MesclaInvest",

                                style: TextStyle(
                                  color: Color(0xFF858788),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        top: 50,
                        left: 45,
                        right: 25,

                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,

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
                                padding: const EdgeInsets.all(18),

                                child: Image.asset(
                                  "assets/images/wallet.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            const Expanded(
                              child: Text(
                                "Mescla Invest",

                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF373737),
                                ),
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
        ),
      ),
    );
  }
}