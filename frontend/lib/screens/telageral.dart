import 'package:flutter/material.dart';
import 'package:mescla_invest_app/screens/tela_perguntas.dart';

class TelaGeral extends StatelessWidget {
  const TelaGeral({super.key});

  static const List<String> imagens = [
    "assets/images/company1.webp",
    "assets/images/company2.webp",
    "assets/images/company3.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E7E7),

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    Stack(
                      clipBehavior: Clip.none,

                      children: [

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.fromLTRB(
                            24,
                            40,
                            24,
                            120,
                          ),

                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1482C7),
                                Color(0xFFB9DCE6),
                              ],

                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),

                            borderRadius:
                            BorderRadius.vertical(
                              bottom:
                              Radius.circular(40),
                            ),
                          ),

                          child: Column(
                            children: [

                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,

                                children: [

                                  Container(
                                    padding:
                                    const EdgeInsets.all(8),

                                    child: GestureDetector(
                                      onTap: () {

                                        Navigator.pushNamed(
                                          context,
                                          '/perfil',
                                        );
                                      },

                                      child: const Icon(
                                        Icons.person,

                                        color: Colors.black,

                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Total de Tokens:",

                                style: TextStyle(
                                  fontSize: 22,

                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "0,00",

                                style: TextStyle(
                                  fontSize: 56,

                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          bottom: -40,
                          left: 24,
                          right: 24,

                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),

                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFEDEDED),

                              borderRadius:
                              BorderRadius.circular(18),

                              boxShadow: [

                                BoxShadow(
                                  color:
                                  Colors.black.withOpacity(
                                    0.2,
                                  ),

                                  blurRadius: 8,

                                  offset:
                                  const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [

                                const Expanded(
                                  child: Text(
                                    "Acesse seus tokens",

                                    style: TextStyle(
                                      fontSize: 16,

                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 15),

                                const Icon(
                                  Icons.stacked_line_chart,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 70),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          _Action(
                            icon:
                            Icons.attach_money,

                            label: "Comprar",

                            onTap: () {

                              Navigator.pushNamed(
                                context,
                                '/balcao',
                              );
                            },
                          ),

                          _Action(
                            icon:
                            Icons.credit_card,

                            label: "Vender",

                            onTap: () {

                              Navigator.pushNamed(
                                context,
                                '/balcao',
                              );
                            },
                          ),

                          _Action(
                            icon:
                            Icons.chat_bubble,

                            label: "Perguntas",

                            onTap: () {

                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                  const TelaPerguntas(
                                    startupId: '1',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Conheça nossas Startups !",

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {

                              Navigator.pushNamed(
                                context,
                                '/catalogo',
                              );
                            },

                            child: const Text(
                              "Ver mais",

                              style: TextStyle(
                                fontSize: 14,

                                color:
                                Color(0xFF1482C7),

                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    SizedBox(
                      height: 185,

                      child: PageView.builder(
                        padEnds: false,

                        controller:
                        PageController(
                          viewportFraction:
                          0.82,
                        ),

                        itemCount:
                        imagens.length,

                        itemBuilder:
                            (
                            context,
                            index,
                            ) {

                          return Padding(
                            padding:
                            EdgeInsets.only(
                              left:
                              index == 0
                                  ? 24
                                  : 10,

                              right: 10,
                            ),

                            child:
                            GestureDetector(
                              onTap: () {

                                Navigator.pushNamed(
                                  context,
                                  '/catalogo',
                                );
                              },

                              child:
                              _CardStartup(
                                imagePath:
                                imagens[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            const _BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _Action({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [

          Container(
            padding:
            const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color:
              const Color(0xFFD6EEF7),

              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              size: 22,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,

            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStartup extends StatelessWidget {

  final String imagePath;

  const _CardStartup({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(22),

        image: DecorationImage(
          image:
          AssetImage(imagePath),

          fit: BoxFit.cover,
        ),

        border: Border.all(
          color:
          const Color(0xFF1482C7),

          width: 1.2,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {

    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration:
      const BoxDecoration(
        color:
        Color(0xFFE8E8E8),

        borderRadius:
        BorderRadius.vertical(
          top:
          Radius.circular(25),
        ),
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,

        children: [

          _NavIcon(
            icon: Icons.home,
            label: "Início",

            active: true,

            onTap: () {},
          ),

          _NavIcon(
            icon:
            Icons.emoji_events,

            label: "Startups",

            onTap: () {

              Navigator.pushNamed(
                context,
                '/catalogo',
              );
            },
          ),

          _NavIcon(
            icon: Icons.wallet,
            label: "Carteira",

            onTap: () {

              Navigator.pushNamed(
                context,
                '/carteira',
              );
            },
          ),

          const _NavIcon(
            icon:
            Icons.show_chart,

            label:
            "Valorização",
          ),

          _NavIcon(
            icon: Icons.store,
            label: "Negociar",

            onTap: () {

              Navigator.pushNamed(
                context,
                '/balcao',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavIcon({
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
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Icon(
            icon,

            color: active
                ? const Color(
              0xFF1482C7,
            )
                : Colors.black,
          ),

          const SizedBox(height: 2),

          Text(
            label,

            style: TextStyle(
              fontSize: 10,

              color: active
                  ? const Color(
                0xFF1482C7,
              )
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}