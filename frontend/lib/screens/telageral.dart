//CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
//RA:25002592
/*TELA INICIAL APÓS LOGIN*/

import 'package:flutter/material.dart';

class TelaGeral extends StatelessWidget {
  const TelaGeral({super.key});

  static const List<String> imagens = [
    "assets/images/company1.png",
    "assets/images/company2.png",
    "assets/images/company3.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E7E7),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 80),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1482C7), Color(0xFFB9DCE6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.person, size: 45),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Total de Tokens:",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "0,00",
                        style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -35,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Acesse seus tokens",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.grey),
                        const SizedBox(width: 15),
                        const Icon(Icons.stacked_line_chart),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _Action(icon: Icons.attach_money, label: "Comprar"),
                  _Action(icon: Icons.credit_card, label: "Vender"),
                  _Action(icon: Icons.chat_bubble, label: "Perguntas"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Conheça nossas Startups !",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Ver mais",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1482C7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.8),
                itemCount: imagens.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _CardStartup(imagePath: imagens[index]),
                  );
                },
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFE7E7E7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Nav(icon: Icons.home, label: "Início", active: true),
                  _Nav(icon: Icons.emoji_events, label: "Startups"),
                  _Nav(icon: Icons.attach_money, label: "Carteira"),
                  _Nav(icon: Icons.show_chart, label: "Valorização"),
                  _Nav(icon: Icons.store, label: "Negociar"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Action({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFD6EEF7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _CardStartup extends StatelessWidget {
  final String imagePath;

  const _CardStartup({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
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
          size: 26,
          color: active ? const Color(0xFF1482C7) : Colors.black,
        ),
        const SizedBox(height: 4),
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