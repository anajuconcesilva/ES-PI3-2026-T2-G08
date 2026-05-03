//CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
//RA:25002592

import 'package:flutter/material.dart';

class TelaCatalogo extends StatelessWidget {
  const TelaCatalogo({super.key});

  final List<Map<String, String>> startups = const [
   //STARTUPS
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Catálogo de Startups",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.person, size: 30),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Pesquise",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFDBD9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: startups.length,
                itemBuilder: (context, index) {
                  final s = startups[index];
                  return _StartupCard(
                    nome: s["nome"]!,
                    descricao: s["descricao"]!,
                    logo: s["logo"]!,
                  );
                },
              ),
            ),

            const _BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  final String nome;
  final String descricao;
  final String logo;

  const _StartupCard({
    required this.nome,
    required this.descricao,
    required this.logo,
  });

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
          Image.asset(logo, width: 70, height: 70),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  descricao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1482C7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Nav(icon: Icons.home, label: "Início"),
          _Nav(icon: Icons.emoji_events, label: "Startups", active: true),
          _Nav(icon: Icons.attach_money, label: "Carteira"),
          _Nav(icon: Icons.show_chart, label: "Valorização"),
          _Nav(icon: Icons.store, label: "Negociar"),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _Nav({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}