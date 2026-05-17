// CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
//RA: 25002592

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  bool obscureSenha = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmController = TextEditingController();

  Future<void> cadastrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    if (senhaController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final functions = FirebaseFunctions.instance;

      final result = await functions
          .httpsCallable('registerUser')
          .call({
        "nome": nomeController.text.trim(),
        "email": emailController.text.trim(),
        "cpf": cpfController.text.trim(),
        "telefone": telefoneController.text.trim(),
        "senha": senhaController.text.trim(),
      });

      final data = Map<String, dynamic>.from(result.data);

      print(data);

      final message = data['data']?['message'] ?? 'Cadastro realizado';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      nomeController.clear();
      emailController.clear();
      cpfController.clear();
      telefoneController.clear();
      senhaController.clear();
      confirmController.clear();

      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pushReplacementNamed(context, '/login');

    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Erro ao cadastrar")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro inesperado: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBD9D9),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        _campo("Nome Completo", "Nome Sobrenome", nomeController, (v) {
                          if (v == null || v.isEmpty) return "Digite seu nome";
                          return null;
                        }),

                        _campo("Email", "exemplo@email.com", emailController, (v) {
                          if (v == null || !v.contains('@')) return "E-mail inválido";
                          return null;
                        }),

                        _campo("CPF", "000.000.000-00", cpfController, (v) {
                          if (v == null || v.isEmpty) return "Digite seu CPF";
                          return null;
                        }),

                        _campo("Telefone", "(19)999999999", telefoneController, null),

                        _campoSenha(
                          "Senha",
                          obscureSenha,
                          senhaController,
                              () => setState(() => obscureSenha = !obscureSenha),
                              (v) {
                            if (v == null || v.length < 6) return "Mínimo 6 caracteres";
                            return null;
                          },
                        ),

                        _campoSenha(
                          "Confirmar Senha",
                          obscureConfirm,
                          confirmController,
                              () => setState(() => obscureConfirm = !obscureConfirm),
                              (v) {
                            if (v != senhaController.text) return "As senhas não coincidem";
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : cadastrarUsuario,
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
                              "Cadastre-se",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Já possui uma conta? "),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Color(0xFF1482C7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "© 2026 MesclaInvest",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          const Text(
            "Crie sua conta",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _campo(String label, String hint, TextEditingController controller, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFD6D5D5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoSenha(String label, bool obscure, TextEditingController controller, VoidCallback toggle, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFD6D5D5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: toggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}