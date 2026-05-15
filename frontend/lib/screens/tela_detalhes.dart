import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tela_societario.dart';

class TelaDetalhesInformaEs extends StatefulWidget {
  final String startupId;

  const TelaDetalhesInformaEs({
    super.key,
    required this.startupId,
  });

  @override
  State<TelaDetalhesInformaEs> createState() =>
      _TelaDetalhesInformaEsState();
}

class _TelaDetalhesInformaEsState
    extends State<TelaDetalhesInformaEs> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('startups')
              .doc(widget.startupId)
              .snapshots(),

          builder: (context, snapshot) {

            if (snapshot.hasError) {
              return const Center(
                child: Text("Erro ao carregar"),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};

            String nome =
                data["name"] ?? "Sem nome";

            String descricaoCurta =
                data["shortDescription"] ??
                    "Sem descrição";

            String? logoUrl =
            data["coverImageUrl"];

            String stage =
                data["stage"] ?? "Desconhecido";

            String sumario =
                data["executiveSummary"] ??
                    descricaoCurta;

            return Column(
              children: [

                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),

                    child: Column(
                      children: [

                        const SizedBox(height: 10),

                        _buildStageBadge(stage),

                        const SizedBox(height: 20),

                        _buildLargeImage(logoUrl),

                        const SizedBox(height: 20),

                        Text(
                          nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          descricaoCurta,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 25),

                        _buildTokenCard(),

                        const SizedBox(height: 25),

                        _buildInfoCard(
                          sumario,
                          widget.startupId,
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                _buildBottomNav(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [

          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),

          const Expanded(
            child: Center(
              child: Text(
                "Detalhes da Startup",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStageBadge(String stage) {

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 30,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFDBD9D9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF1482C7),
          width: 1.5,
        ),
      ),

      child: Text(
        "Estágio: $stage",
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLargeImage(String? url) {

    return Container(
      width: double.infinity,
      height: 180,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1482C7),
          width: 1.5,
        ),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),

        child: (url != null && url.isNotEmpty)
            ? Image.network(
          url,
          fit: BoxFit.cover,
        )
            : const Icon(
          Icons.image,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTokenCard() {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1482C7),
          width: 1.5,
        ),
      ),

      child: Column(
        children: [

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              const Text(
                "Total de Tokens:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              _actionButton(
                "Comprar Tokens",
                const Color(0xFF1482C7),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              const Text(
                "0,00",
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _actionButton(
                "Vender Tokens",
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      String label,
      Color color,
      ) {

    return SizedBox(
      width: 140,
      height: 40,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        onPressed: () {},

        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String sumario,
      String id,
      ) {

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1482C7),
          width: 1.5,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          GestureDetector(
            onTap: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      TelaSocietario(
                        startupId: id,
                      ),
                ),
              );
            },

            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFBDD7EE),

                borderRadius:
                const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),

                border: Border.all(
                  color: const Color(0xFF1482C7),
                ),
              ),

              child: const Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    "Informações",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(
                  "Sumário Executivo:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  sumario,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,

        children: [

          _NavItem(
            icon: Icons.home,
            label: "Início",

            onTap: () {
              Navigator.pushNamed(
                context,
                '/geral',
              );
            },
          ),

          _NavItem(
            icon: Icons.emoji_events,
            label: "Startups",
            active: true,

            onTap: () {},
          ),

          _NavItem(
            icon: Icons.wallet,
            label: "Carteira",

            onTap: () {
              Navigator.pushNamed(
                context,
                '/carteira',
              );
            },
          ),

          _NavItem(
            icon: Icons.show_chart,
            label: "Valorização",

            onTap: () {},
          ),

          _NavItem(
            icon: Icons.store,
            label: "Negociar",

            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
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
        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(
            icon,
            color: active
                ? const Color(0xFF1482C7)
                : Colors.black,
          ),

          const SizedBox(height: 4),

          Text(
            label,

            style: TextStyle(
              fontSize: 10,

              color: active
                  ? const Color(0xFF1482C7)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}