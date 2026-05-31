//CÓDIGO FEITO PELA ALUNA: Ana Júlia Conceição da Silva
//RA: 25002592

//Integração com o backend feita por Lucas David de Sousa
//RA: 25895152

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

class TelaCarteira extends StatefulWidget {
  const TelaCarteira({super.key});

  @override
  State<TelaCarteira> createState() => _TelaCarteiraState();
}

class _TelaCarteiraState extends State<TelaCarteira> {
  bool mostrarSaldo = true;
  double saldo = 0.0;
  List<dynamic> historico = [];
  List<Map<String, dynamic>> investimentos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    carregarCarteira();
  }

  double _parseMoney(String value) {
    return double.tryParse(
      value.trim().replaceAll('.', '').replaceAll(',', '.'),
    ) ??
        0;
  }

  Future<void> carregarCarteira() async {
    try {
      final functions = FirebaseFunctions.instance;

      // =====================
      // WALLET
      // =====================

      final walletCallable = functions.httpsCallable('getWallet');

      dynamic walletData;

      try {
        final walletResponse = await walletCallable.call();

        walletData = walletResponse.data;
      } on FirebaseFunctionsException catch (e) {
        if (e.code != 'not-found') {
          rethrow;
        }

        walletData = {
          "wallet": {"balance": 0, "investments": {}},
        };
      }

      // =====================
      // TRANSACTIONS
      // =====================

      final transactionsCallable = functions.httpsCallable('getTransactions');

      final transactionsResponse = await transactionsCallable.call();

      final transactionsData = transactionsResponse.data;

      // =====================
      // DASHBOARD / VALORIZAÇÃO
      // =====================

      final dashboardCallable = functions.httpsCallable(
        'getPortfolioValuation',
      );

      final dashboardResponse = await dashboardCallable.call({
        "period": "monthly",
      });

      final dashboardData = dashboardResponse.data;

      if (!mounted) return;

      setState(() {
        saldo = (walletData["wallet"]?["balance"] ?? 0) / 100.0;

        final investmentsMap = walletData["wallet"]?["investments"] ?? {};

        final performanceList = List<dynamic>.from(
          dashboardData["data"]?["investments"] ?? [],
        );

        investimentos = Map<String, dynamic>.from(investmentsMap).entries.map((
            entry,
            ) {
          final startupId = entry.key;

          final data = Map<String, dynamic>.from(entry.value);

          final performance = performanceList.firstWhere(
                (item) => item["startupId"] == startupId,
            orElse: () => {},
          );

          final percentage = (performance["variationPercent"] ?? 0).toDouble();

          return {
            "nome": performance["startupName"] ?? startupId,

            "valor": (data["investedValue"] ?? 0) / 100.0,

            "quantidade": data["quantity"] ?? 0,

            "porcentagem": percentage,

            "positivo": percentage >= 0,
          };
        }).toList();

        historico = (transactionsData["data"] as List<dynamic>? ?? []).map((
            item,
            ) {
          return {...item, "amount": (item["amount"] ?? 0) / 100.0};
        }).toList();

        carregando = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar carteira: $e");

      if (!mounted) return;

      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> abrirModalSaldo() async {
    final balanceAdded = await showDialog<bool>(
      context: context,
      builder: (_) => _AddBalanceDialog(parseMoney: _parseMoney),
    );

    if (!mounted || balanceAdded != true) return;

    await carregarCarteira();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Modificado para retornar para /geral caso não haja histórico na pilha
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/geral');
                      }
                    },
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
                          colors: [Color(0xFF1482C7), Color(0xFF8DC0DF)],
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
                        border: Border.all(color: const Color(0xFF1482C7)),
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0x661482C8), Color(0x668DC0DF)],
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          mostrarSaldo = !mostrarSaldo;
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
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1482C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: abrirModalSaldo,
                            child: const Text(
                              "Adicionar saldo",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1482C7)),
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0x1A1482C7),
                      ),

                      child: investimentos.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "Você ainda não possui investimentos",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                          : Column(
                        children: investimentos.map((item) {
                          return Column(
                            children: [
                              _InvestimentoItem(
                                nome: item["nome"],

                                valor:
                                "R\$ ${item["valor"].toStringAsFixed(2)}",

                                porcentagem:
                                "${item["porcentagem"].toStringAsFixed(2)}%",

                                positivo: item["positivo"],
                              ),

                              const Divider(color: Color(0xFF1482C7)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1482C7)),
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0x1A1482C7),
                      ),

                      child: historico.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "Ainda não há transações",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                          : Column(
                        children: historico.map((item) {
                          final type = item["type"];

                          final positivo =
                              type == "sell" || type == "deposit";

                          String titulo = "";

                          if (type == "buy") {
                            titulo =
                            "Compra - ${item["startupName"] ?? "Startup"}";
                          }

                          if (type == "sell") {
                            titulo =
                            "Venda - ${item["startupName"] ?? "Startup"}";
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

                                data: item["createdAt"] != null
                                    ? (() {
                                  final createdAt =
                                  Map<String, dynamic>.from(
                                    item["createdAt"],
                                  );

                                  final seconds =
                                      createdAt["_seconds"] ?? 0;

                                  return DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      seconds * 1000,
                                    ),
                                  );
                                })()
                                    : "",

                                positivo: positivo,
                              ),

                              const Divider(color: Color(0xFF1482C7)),
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


          ],
        ),

      ),
      bottomNavigationBar: const CustomBottomNav(paginaAtiva: 'carteira'),

    );
  }
}

class _AddBalanceDialog extends StatefulWidget {
  final double Function(String value) parseMoney;

  const _AddBalanceDialog({required this.parseMoney});

  @override
  State<_AddBalanceDialog> createState() => _AddBalanceDialogState();
}

class _AddBalanceDialogState extends State<_AddBalanceDialog> {
  final _saldoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _saldoController.dispose();
    super.dispose();
  }

  Future<void> _close({bool added = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    Navigator.of(context).pop(added);
  }

  Future<void> _addBalance() async {
    final messenger = ScaffoldMessenger.of(context);
    final valor = widget.parseMoney(_saldoController.text);

    if (valor <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Digite um valor maior que zero')),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('addBalance');

      await callable.call({"value": valor});

      await _close(added: true);
    } catch (e) {
      debugPrint("Erro ao adicionar saldo: $e");

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao adicionar saldo: $e')),
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE8E8E8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Adicionar saldo",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _saldoController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          onPressed: _isLoading ? null : _close,
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1482C7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isLoading ? null : _addBalance,
          child: _isLoading
              ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Confirmar"),
        ),
      ],
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
    final cor = positivo ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1482C7),

            child: Icon(
              positivo ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              nome,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                "${positivo ? "+" : ""}$porcentagem",
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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
            backgroundColor: positivo ? Colors.green : Colors.red,
            child: Icon(
              positivo ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(child: Text(titulo, style: const TextStyle(fontSize: 15))),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: positivo ? Colors.green : Colors.red,
                ),
              ),

              Text(data, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}