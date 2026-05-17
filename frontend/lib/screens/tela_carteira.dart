//CÓDIGO FEITO PELA ALUNA: Ana Júlia Conceição da Silva
//RA: 25002592

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class TelaCarteira extends StatefulWidget {
  const TelaCarteira({super.key});

  @override
  State<TelaCarteira> createState() => _TelaCarteiraState();
}

class _TelaCarteiraState extends State<TelaCarteira> {
  bool mostrarSaldo = true;

  double saldo = 0.0;

  List<dynamic> historico = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    carregarCarteira();
  }

  Future<void> carregarCarteira() async {

    try {

      final functions =
          FirebaseFunctions.instance;

      // =====================
      // WALLET
      // =====================

      final walletCallable =
      functions.httpsCallable(
        'getWallet',
      );

      final walletResponse =
      await walletCallable.call();

      final walletData =
          walletResponse.data;

      // =====================
      // TRANSACTIONS
      // =====================

      final transactionsCallable =
      functions.httpsCallable(
        'getTransactions',
      );

      final transactionsResponse =
      await transactionsCallable.call();

      final transactionsData =
          transactionsResponse.data;

      setState(() {

        saldo =
            (walletData["wallet"]?["balance"] ?? 0)
                .toDouble();

        historico =
            transactionsData["data"] ?? [];

        carregando = false;
      });

    } catch (e) {

      print(
        "Erro ao carregar carteira: $e",
      );

      setState(() {
        carregando = false;
      });
    }
  }

  void abrirModalSaldo() {
    final TextEditingController saldoController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE8E8E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Adicionar saldo",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: saldoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Digite o valor",
              prefixText: "R\$ ",
              filled: true,
              fillColor: const Color(0xFFDBD9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1482C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {

                double valor =
                    double.tryParse(saldoController.text) ?? 0;

                try {

                  final functions =
                      FirebaseFunctions.instance;

                  final callable =
                  functions.httpsCallable(
                    'addBalance',
                  );

                  await callable.call({
                    "value": valor,
                  });

                  await carregarCarteira();

                  Navigator.pop(context);

                } catch (e) {

                  print(
                    "Erro ao adicionar saldo: $e",
                  );
                }
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Row(
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const Expanded(
                    child: Text(
                      "Carteira",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF373737),
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [

                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1482C7),
                            Color(0xFF8DC0DF),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          "assets/images/wallet.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1482C7),
                        ),
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0x661482C8),
                            Color(0x668DC0DF),
                          ],
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [

                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  const Text(
                                    "Saldo em dinheiro",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        mostrarSaldo =
                                        !mostrarSaldo;
                                      });
                                    },
                                    child: Icon(
                                      mostrarSaldo
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                mostrarSaldo
                                    ? "R\$ ${saldo.toStringAsFixed(2)}"
                                    : "••••••",
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF1482C7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: abrirModalSaldo,
                            child: const Text(
                              "Adicionar saldo",
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: const [

                        Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            "Meus investimentos",
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xFF373737),
                            ),
                          ),
                        ),

                        Text(
                          "Ver todos",
                          style: TextStyle(
                            color: Color(0xFF1482C7),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1482C7),
                        ),
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0x1A1482C7),
                      ),
                      child: Column(
                        children: const [

                          _InvestimentoItem(
                            nome: "FinBlock",
                            valor: "R\$ 1.200,00",
                            porcentagem: "+ 2,35%",
                            positivo: true,
                          ),

                          Divider(color: Color(0xFF1482C7)),

                          _InvestimentoItem(
                            nome: "AgroVision",
                            valor: "R\$ 1.150,00",
                            porcentagem: "- 2,35%",
                            positivo: false,
                          ),

                          Divider(color: Color(0xFF1482C7)),

                          _InvestimentoItem(
                            nome: "MedSync",
                            valor: "R\$ 1.300,00",
                            porcentagem: "+ 3,35%",
                            positivo: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: const [

                        Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            "Histórico",
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xFF373737),
                            ),
                          ),
                        ),

                        Text(
                          "Ver tudo",
                          style: TextStyle(
                            color: Color(0xFF1482C7),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1482C7),
                        ),
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0x1A1482C7),
                      ),
                      child: Column(
                        children: historico.map((item) {

                          final type = item["type"];

                          final positivo =
                              type == "sell" ||
                                  type == "deposit";

                          String titulo = "";

                          if (type == "buy") {
                            titulo =
                            "Compra - ${item["startupName"]}";
                          }

                          if (type == "sell") {
                            titulo =
                            "Venda - ${item["startupName"]}";
                          }

                          if (type == "deposit") {
                            titulo = "Adição de saldo";
                          }

                          return Column(
                            children: [

                              _HistoricoItem(
                                titulo: titulo,

                                valor:
                                "${positivo ? "+" : "-"}R\$ ${item["amount"]}",

                                data: "Agora",

                                positivo: positivo,
                              ),

                              const Divider(
                                color: Color(0xFF1482C7),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
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

class _InvestimentoItem extends StatelessWidget {
  final String nome;
  final String valor;
  final String porcentagem;
  final bool positivo;

  const _InvestimentoItem({
    required this.nome,
    required this.valor,
    required this.porcentagem,
    required this.positivo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [

          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1482C7),
            child: Text(
              nome[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              nome,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(
                valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                porcentagem,
                style: TextStyle(
                  color:
                  positivo ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _HistoricoItem extends StatelessWidget {
  final String titulo;
  final String valor;
  final String data;
  final bool positivo;

  const _HistoricoItem({
    required this.titulo,
    required this.valor,
    required this.data,
    required this.positivo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [

          CircleAvatar(
            radius: 16,
            backgroundColor:
            positivo ? Colors.green : Colors.red,
            child: Icon(
              positivo
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.white,
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(
                valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                data,
                style: const TextStyle(fontSize: 12),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          _NavIcon(
            icon: Icons.home,
            label: "Início",
            onTap: () {
              Navigator.pushNamed(context, '/geral');
            },
          ),

          _NavIcon(
            icon: Icons.emoji_events,
            label: "Startups",
            onTap: () {
              Navigator.pushNamed(context, '/catalogo');
            },
          ),

          const _NavIcon(
            icon: Icons.wallet,
            label: "Carteira",
            active: true,
          ),

          _NavIcon(
            icon: Icons.show_chart,
            label: "Valorização",
            onTap: () {},
          ),

          _NavIcon(
            icon: Icons.store,
            label: "Negociar",
            onTap: () {},
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
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            color: active
                ? const Color(0xFF1482C7)
                : Colors.black,
          ),

          const SizedBox(height: 2),

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