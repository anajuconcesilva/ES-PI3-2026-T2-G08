//CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
//RA:25002592

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
        child: SingleChildScrollView(
          child: Column(
            children: [

              // 🔵 HEADER
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
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
                        const SizedBox(height: 50),
                        const Text(
                          "Total de Tokens:",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "0,00",
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔥 CARD FLUTUANTE
                  Positioned(
                    bottom: -40,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

              const SizedBox(height: 70),

              // 🔹 AÇÕES
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

              // 🔹 TÍTULO + VER MAIS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Conheça nossas Startups !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/catalogo');
                      },
                      child: const Text(
                        "Ver mais",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1482C7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 CARROSSEL
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: 0.75,
                  ),
                  itemCount: imagens.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/catalogo');
                        },
                        child: _CardStartup(imagePath: imagens[index]),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 NAVBAR
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFE7E7E7),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Nav(
                      icon: Icons.home,
                      label: "Início",
                      active: true,
                    ),
                    _Nav(
                      icon: Icons.emoji_events,
                      label: "Startups",
                      onTap: () {
                        Navigator.pushNamed(context, '/catalogo');
                      },
                    ),
                    _Nav(
                      icon: Icons.attach_money,
                      label: "Carteira",
                    ),
                    _Nav(
                      icon: Icons.show_chart,
                      label: "Valorização",
                    ),
                    _Nav(
                      icon: Icons.store,
                      label: "Negociar",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 BOTÕES
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

// 🔹 CARD
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

// 🔹 NAVBAR ITEM
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
      ),
    );
  }
}