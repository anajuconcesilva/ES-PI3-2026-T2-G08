import 'package:flutter/material.dart';
import 'package:mescla_invest_app/services/startup_service.dart';
import 'tela_societario.dart';

class TelaDetalhesInformaEs extends StatefulWidget {
  final String startupId;

  const TelaDetalhesInformaEs({super.key, required this.startupId});

  @override
  State<TelaDetalhesInformaEs> createState() => _TelaDetalhesInformaEsState();
}

class _TelaDetalhesInformaEsState extends State<TelaDetalhesInformaEs> {
  final StartupService startupService = const StartupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: startupService.getStartupDetails(widget.startupId),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Erro: ${snapshot.error}"));
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;

            String nome = data["name"] ?? "Sem nome";
            String descricaoCurta = data["shortDescription"] ?? "Sem descrição";
            String? logoUrl = data["coverImageUrl"];
            String stage = data["stage"] ?? "desconhecido";
            String sumario = data["executiveSummary"] ?? descricaoCurta;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildStageBadge(stage),
                        const SizedBox(height: 20),
                        _buildLargeImage(logoUrl),
                        const SizedBox(height: 20),
                        Text(nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(descricaoCurta, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 25),

                        _buildTokenCard(),

                        const SizedBox(height: 25),

                        _buildInfoCard(sumario, widget.startupId),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const _BottomNav(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          const Text("Detalhes da Startup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Icon(Icons.person, size: 35),
        ],
      ),
    );
  }

  Widget _buildStageBadge(String stage) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFDBD9D9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1482C7), width: 1.5),
      ),
      child: Text("Estágio: $stage", style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildLargeImage(String? url) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1482C7), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: (url != null && url.isNotEmpty)
            ? Image.network(url, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget _buildTokenCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1482C7), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total de Tokens:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _actionButton("Comprar Tokens", const Color(0xFF1482C7)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("0,00", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
              _actionButton("Vender Tokens", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color) {
    return SizedBox(
      width: 140,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {},
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInfoCard(String sumario, String id) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1482C7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaSocietario(startupId: id),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFBDD7EE), // 🔵 AGORA PADRÃO
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                border: Border.all(color: const Color(0xFF1482C7)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Informações", style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Sumário Executivo:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(sumario, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(icon: Icons.home, label: "Início"),
          _NavIcon(icon: Icons.emoji_events, label: "Startups", active: true),
          _NavIcon(icon: Icons.wallet, label: "Carteira"),
          _NavIcon(icon: Icons.show_chart, label: "Valorização"),
          _NavIcon(icon: Icons.store, label: "Negociar"),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavIcon({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFF1482C7) : Colors.black),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? const Color(0xFF1482C7) : Colors.black,
          ),
        ),
      ],
    );
  }
}