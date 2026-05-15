import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../usuario_model.dart';
import '../usuario_server.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  late Future<Usuario?> futureUsuario;
  bool mfaAtivo = false;

  @override
  void initState() {
    super.initState();
    futureUsuario = UsuarioService.fetchUsuario();
  }

  Future<void> _sairDaConta() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1482C7);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF58A8D4),
              Color(0xFFD8D9DA),
              Color(0xFFDBD9D9),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Usuario?>(
            future: futureUsuario,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Erro: ${snapshot.error}"));
              }

              if (snapshot.data == null) {
                return const Center(
                  child: Text(
                    "Usuário não encontrado.\nFaça login novamente.",
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final usuario = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    _header(context),
                    const SizedBox(height: 24),

                    // ── Avatar ──
                    const Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 150,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Meus Dados ──
                    const Text(
                      "MEUS DADOS",
                      style: TextStyle(
                        color: azul,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _InfoCard(
                      icon: Icons.person_outline,
                      title: "Nome Completo",
                      value: usuario.nome,
                    ),

                    const SizedBox(height: 12),

                    _InfoCard(
                      icon: Icons.email,
                      title: "Email",
                      value: usuario.email,
                    ),

                    const SizedBox(height: 12),

                    _InfoCard(
                      icon: Icons.info_outline,
                      title: "CPF",
                      value: usuario.cpf,
                    ),

                    const SizedBox(height: 12),

                    _InfoCard(
                      icon: Icons.phone_outlined,
                      title: "Celular",
                      value: usuario.telefone,
                    ),

                    const SizedBox(height: 24),

                    // ── Configurações ──
                    const Text(
                      "CONFIGURAÇÕES",
                      style: TextStyle(
                        color: azul,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Card MFA ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Autenticação MFA",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch(
                                value: mfaAtivo,
                                activeColor: azul,
                                onChanged: (value) {
                                  setState(() => mfaAtivo = value);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Adicione uma camada extra de segurança à sua conta",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Botão Sair ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sairDaConta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC71414),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Sair da Conta",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Meu Perfil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 34, color: Colors.black54),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF373737),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF373737),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}