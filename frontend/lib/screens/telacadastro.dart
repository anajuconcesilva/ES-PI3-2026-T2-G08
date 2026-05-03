// CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
// RA: 25002592
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
    // 1. Validação local no Flutter
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Chamada da função 'registerUser' que o Lucas exportou no backend
      final callable = FirebaseFunctions.instance.httpsCallable('registerUser');

      final response = await callable.call({
        "nome": nomeController.text.trim(),
        "email": emailController.text.trim(),
        "cpf": cpfController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''), // Limpa o CPF
        "telefone": telefoneController.text.trim(),
        "senha": senhaController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? "Sucesso!")),
        );
        Navigator.pushNamed(context, '/login');
      }
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no servidor: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro inesperado: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                        _campo("Nome Completo", "Ana Júlia", nomeController, (v) {
                          if (v == null || v.isEmpty) return "Digite seu nome";
                          return null;
                        }),
                        _campo("Email", "exemplo@mesclainvest.com", emailController, (v) {
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
                          "Confirme sua senha",
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Cadastre-se", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Já possui uma conta? "),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: const Text("Login", style: TextStyle(color: Color(0xFF1482C7), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text("© 2026 MesclaInvest", style: TextStyle(color: Colors.grey)),
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
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          const Spacer(),
          const Text("Crie sua conta", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              errorStyle: const TextStyle(color: Colors.red),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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