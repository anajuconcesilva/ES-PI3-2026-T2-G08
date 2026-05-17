import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaEsqueci extends StatefulWidget {
  const TelaEsqueci({super.key});

  @override
  State<TelaEsqueci> createState() => _TelaEsqueciState();
}

class _TelaEsqueciState extends State<TelaEsqueci> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> enviarEmail() async {
    final email = emailController.text.trim();

    // Validação mais robusta de email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Digite um email válido."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      // Mensagem mais profissional (mais segura também)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Se o email estiver cadastrado, você receberá instruções para redefinir sua senha.",
          ),
        ),
      );

      // Melhor controle de fluxo (evita bugs de navegação)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }

    } on FirebaseAuthException catch (e) {
      String msg;

      switch (e.code) {
        case 'invalid-email':
          msg = "Email inválido.";
          break;
        case 'user-not-found':
        // versão mais segura (evita enumeração de usuários)
          msg = "Se o email estiver cadastrado, você receberá instruções.";
          break;
        case 'too-many-requests':
          msg = "Muitas tentativas. Tente novamente mais tarde.";
          break;
        default:
          msg = "Erro ao enviar email. Tente novamente.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro inesperado. Tente novamente."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBD9D9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const Spacer(),
                        const Text(
                          "Recuperação de Senha",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 40),

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
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset("assets/images/wallet.png"),
                      ),
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      "Digite seu email e enviaremos um link\npara redefinir sua senha.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "exemplo@mesclainvest.com",
                        filled: true,
                        fillColor: const Color(0xFFD6D5D5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : enviarEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1482C7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Enviar Instruções",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      "© 2026 MesclaInvest",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}