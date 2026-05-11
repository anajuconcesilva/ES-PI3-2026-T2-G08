import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool obscureSenha = true;

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBD9D9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5CA9D6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/aWcBwf6Kwt/s3ii9b48_expires_30_days.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Text(
                    "Mescla Invest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF373737),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),

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
                        hintText: "exemplo@mesclainvest.com",
                        filled: true,
                        fillColor: const Color(0xFFD6D5D5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
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
                            color: const Color(0xFF858788),
                          ),
                          onPressed: () {
                            setState(() {
                              obscureSenha = !obscureSenha;
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
                        onPressed: () {
                          print("Email: ${emailController.text}");
                          print("Senha: ${senhaController.text}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1482C7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Entrar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ESQUECEU SENHA
                    Center(
                      child: TextButton(
                        onPressed: () {},
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Não possui uma conta? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/cadastro');
                          },
                          child: const Text(
                            "Cadastre-se",
                            style: TextStyle(
                              color: Color(0xFF1482C7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // RODAPÉ
                    const Center(
                      child: Text(
                        "© 2026 MesclaInvest",
                        style: TextStyle(color: Color(0xFF858788)),
                      ),
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