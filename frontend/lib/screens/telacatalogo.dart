// CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
// RA:25002592

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/services/startup_service.dart';
import 'tela_detalhes.dart';

class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {

  final StartupService startupService = const StartupService();
  String filtroStage = "todos";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Catálogo de Startups",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const Icon(Icons.person, size: 30),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () async {

                  final selecionado = await showModalBottomSheet<String>(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _opcaoFiltro("todos", "Todos"),
                          _opcaoFiltro("nova", "Nova"),
                          _opcaoFiltro("em_operacao", "Em operação"),
                          _opcaoFiltro("em_expansao", "Em expansão"),
                        ],
                      );
                    },
                  );

                  if (selecionado != null) {
                    setState(() {
                      filtroStage = selecionado;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBD9D9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          filtroStage == "todos"
                              ? "Filtrar por estágio"
                              : filtroStage.replaceAll("_", " "),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: startupService.listStartups(stage: filtroStage),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Erro: ${snapshot.error}"),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final startups = snapshot.data!;

                  if (startups.isEmpty) {
                    return const Center(
                      child: Text("Nenhuma startup encontrada"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: startups.length,
                    itemBuilder: (context, index) {
                      final data = startups[index];

                      return _StartupCard(
                        nome: data["name"] ?? "Sem nome",
                        descricao: data["shortDescription"] ?? "Sem descrição",
                        logoUrl: data["coverImageUrl"],
                        stage: data["stage"] ?? "desconhecido",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaDetalhesInformaEs(
                                startupId: data["id"],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              ),
            ),
            const _BottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _opcaoFiltro(String value, String label) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context, value);
      },
    );
  }
}

class _StartupCard extends StatelessWidget {
  final String nome;
  final String descricao;
  final String? logoUrl;
  final String stage;
  final VoidCallback onPressed;

  const _StartupCard({
    required this.nome,
    required this.descricao,
    this.logoUrl,
    required this.stage,
    required this.onPressed,
  });

  String getStageLabel() {
    switch (stage) {
      case "nova":
        return "Nova";
      case "em_operacao":
        return "Em operação";
      case "em_expansao":
        return "Em expansão";
      default:
        return "Desconhecido";
    }
  }

  Color getStageColor() {
    switch (stage) {
      case "nova":
        return Colors.blue;
      case "em_operacao":
        return Colors.green;
      case "em_expansao":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1482C7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          logoUrl != null && logoUrl!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              logoUrl!,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 70);
              },
            ),
          )
              : const Icon(Icons.image, size: 70),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  descricao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStageColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStageLabel(),
                    style: TextStyle(
                      color: getStageColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1482C7),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onPressed,
                    child: const Text("Conhecer"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Nav(
            icon: Icons.home,
            label: "Início",
            onTap: () {
              Navigator.pushNamed(context, '/geral');
            },
          ),
          const _Nav(
            icon: Icons.emoji_events,
            label: "Startups",
            active: true,
          ),
          const _Nav(icon: Icons.attach_money, label: "Carteira"),
          const _Nav(icon: Icons.show_chart, label: "Valorização"),
          const _Nav(icon: Icons.store, label: "Negociar"),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _Nav({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF1482C7) : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF1482C7) : Colors.black,
            ),
          )
        ],
      ),
    );
  }
}