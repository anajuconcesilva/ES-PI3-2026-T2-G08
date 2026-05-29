// tela feita pela aluna marilia santos RA 25014905

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../usuario_model.dart';
import '../usuario_server.dart';
import 'dart:async';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  late Future<Usuario?> futureUsuario;
  bool mfaAtivo = false;
  bool mfaLoading = false;

  @override
  void initState() {
    super.initState();
    futureUsuario = UsuarioService.fetchUsuario();
    _carregarStatusMfa();
  }

  Future<void> _reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      throw Exception("Usuário não autenticado");
    }

    final senhaController = TextEditingController();

    final senha = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirme sua senha"),
          content: TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Senha",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, senhaController.text);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (senha == null || senha.isEmpty) {
      throw Exception("Senha não informada");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: senha,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _reauthenticateUserWithMfa() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      throw Exception("Usuário não autenticado");
    }

    final senhaController = TextEditingController();

    final senha = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirme sua senha"),
          content: TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Senha",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, senhaController.text);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (senha == null || senha.isEmpty) {
      throw Exception("Senha não informada");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: senha,
    );

    try {

      await user.reauthenticateWithCredential(
        credential,
      );

    } on FirebaseAuthMultiFactorException catch (e) {

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

      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: codigo,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(
        phoneCredential,
      );

      await resolver.resolveSignIn(assertion);
    }
  }

  Future<void> _ativarMfa() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    // =========================
    // 1. REAUTENTICAR
    // =========================
    await _reauthenticateUser();

    // =========================
    // 2. PEDIR TELEFONE
    // =========================
    final telefoneController = TextEditingController();

    final telefone = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Número de telefone"),
          content: TextField(
            controller: telefoneController,
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, telefoneController.text);
              },
              child: const Text("Continuar"),
            ),
          ],
        );
      },
    );

    if (telefone == null || telefone.isEmpty) {
      throw Exception("Telefone não informado");
    }

    String telefoneFormatado = telefone;

    if (!telefone.startsWith("+")) {
      telefoneFormatado = "+$telefone";
    }

    // =========================
    // 3. MFA SESSION
    // =========================
    final multiFactorSession = await user.multiFactor.getSession();

    // =========================
    // 4. ENVIAR SMS
    // =========================
    String? verificationId;

    final completer = Completer<void>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: telefoneFormatado,
      multiFactorSession: multiFactorSession,

      verificationCompleted: (PhoneAuthCredential credential) {},

      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message),
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
      throw Exception("Não foi possível enviar o SMS");
    }

    // =========================
    // 5. PEDIR CÓDIGO SMS
    // =========================
    final codigoController = TextEditingController();

    final codigo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Código SMS"),
          content: TextField(
            controller: codigoController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, codigoController.text);
              },
              child: const Text("Verificar"),
            ),
          ],
        );
      },
    );

    if (codigo == null || codigo.isEmpty) {
      throw Exception("Código não informado");
    }

    // =========================
    // 6. CRIAR CREDENTIAL
    // =========================
    final phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: codigo,
    );

    // =========================
    // 7. MFA ASSERTION
    // =========================
    final assertion = PhoneMultiFactorGenerator.getAssertion(
      phoneAuthCredential,
    );

    // =========================
    // 8. FINALIZAR MFA
    // =========================
    await user.multiFactor.enroll(
      assertion,
      displayName: telefone,
    );

    // =========================
    // 9. ATUALIZAR UI
    // =========================
    setState(() {
      mfaAtivo = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("MFA ativado com sucesso"),
      ),
    );
  }

  Future<void> _desativarMfa() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    // =========================
    // REAUTENTICAR
    // =========================
    await _reauthenticateUserWithMfa();

    // =========================
    // PEGAR FATORES
    // =========================
    final fatores = await user.multiFactor.getEnrolledFactors();

    if (fatores.isEmpty) {
      throw Exception("Nenhum MFA cadastrado");
    }

    // =========================
    // REMOVER TODOS OS FATORES
    // =========================
    for (final fator in fatores) {
      await user.multiFactor.unenroll(
        multiFactorInfo: fator,
      );
    }

    // =========================
    // ATUALIZAR UI
    // =========================
    setState(() {
      mfaAtivo = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("MFA desativado com sucesso"),
      ),
    );
  }

  Future<void> _carregarStatusMfa() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final fatores = await user.multiFactor.getEnrolledFactors();

    setState(() {
      mfaAtivo = fatores.isNotEmpty;
    });
  }

  void _mostrarLoading(String texto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _fecharLoading() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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
                                onChanged: mfaLoading
                                    ? null
                                    : (value) async {
                                  setState(() => mfaLoading = true);

                                  try {
                                    _mostrarLoading(
                                      value
                                          ? "Ativando MFA..."
                                          : "Desativando MFA...",
                                    );

                                    if (value) {
                                      await _ativarMfa();
                                    } else {
                                      await _desativarMfa();
                                    }

                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Erro: $e"),
                                      ),
                                    );

                                  } finally {
                                    _fecharLoading();
                                    setState(() => mfaLoading = false);
                                  }
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