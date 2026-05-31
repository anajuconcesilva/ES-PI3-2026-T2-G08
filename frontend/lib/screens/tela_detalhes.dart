// CÓDIGO FEITO PELO ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../trading_service.dart';
import 'tela_societario.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

class TelaDetalhesInformaEs extends StatefulWidget {
  final String startupId;

  const TelaDetalhesInformaEs({super.key, required this.startupId});

  @override
  State<TelaDetalhesInformaEs> createState() => _TelaDetalhesInformaEsState();
}

class _TelaDetalhesInformaEsState extends State<TelaDetalhesInformaEs> {


  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _handleDirectTransaction(
    bool isBuy,
    int currentPriceCents,
  ) async {
    final quantityController = TextEditingController();

    await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(isBuy ? 'Comprar Tokens' : 'Vender Tokens'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preço atual: R\$ ${(currentPriceCents / 100.0).toStringAsFixed(2).replaceAll('.', ',')}',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantidade',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: () async {
          final qty = int.tryParse(quantityController.text.trim()) ?? 0;
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          if (qty <= 0) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Quantidade inválida'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          // Fecha o diálogo de input imediatamente
          navigator.pop();
          if (!mounted) return;

          try {
            if (isBuy) {
              await TradingService.buyToken(
                startupId: widget.startupId,
                quantity: qty,
                tokenPrice: currentPriceCents,
              );
            } else {
              await TradingService.sellToken(
                startupId: widget.startupId,
                quantity: qty,
                tokenPrice: currentPriceCents,
              );
            }

            if (mounted) {
             
              messenger.showSnackBar(
                SnackBar(
                  content: Text(isBuy ? 'Compra realizada com sucesso!' : 'Venda realizada com sucesso!'),
                  backgroundColor:  Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
          if (mounted) {
            String mensagemAmigavel = 'Ocorreu um erro inesperado.';
            
            // Convertem o texto para minúsculo 
            final erroString = e.toString().toLowerCase();

            //  Tratamento para COMPRA (Saldo em dinheiro insuficiente)
            if (isBuy && (erroString.contains('insufficient') || erroString.contains('saldo'))) {
              mensagemAmigavel = 'Saldo insuficiente para realizar esta compra.';
            } 
            // Tratamento para VENDA (Falta de tokens na carteira)
            else if (!isBuy && (erroString.contains('token') || erroString.contains('insufficient') || erroString.contains('quantidade'))) {
              mensagemAmigavel = 'Você não possui tokens suficientes para vender.';
            } 
            //  Sessão expirada
            else if (erroString.contains('unauthenticated') || erroString.contains('auth')) {
              mensagemAmigavel = 'Sua sessão expirou. Faça login novamente.';
            } 
            // Caso seja outro erro do Firebase
            else {
              // Se o erro contiver colchetes tipo [functions/internal], tentamos limpar.
              // Caso contrário, mostra uma mensagem genérica segura para o usuário.
              mensagemAmigavel = 'Não foi possível completar a transação. Verifique os dados.';
            }

    
    messenger.showSnackBar(
      SnackBar(
        content: Text(mensagemAmigavel),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
        },
        child: const Text('Confirmar'),
      ),
    ],
  ),
);
}

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child:
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('startups')
                  .doc(widget.startupId)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Erro ao carregar"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};

                String nome = data["name"] ?? "Sem nome";

                String descricaoCurta =
                    data["shortDescription"] ?? "Sem descrição";

                String? logoUrl = data["coverImageUrl"];

                String stage = data["stage"] ?? "Desconhecido";

                String sumario = data["executiveSummary"] ?? descricaoCurta;

                int precoCents = _asInt(data["currentTokenPriceCents"]);

                int capitalRaisedCents = _asInt(data["capitalRaisedCents"]);

                return Column(
                  children: [
                    _buildHeader(context),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),

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

                              style: const TextStyle(fontSize: 13),
                            ),

                            const SizedBox(height: 25),

                            if (currentUserId != null)
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUserId)
                                    .snapshots(),

                                builder: (context, userSnap) {
                                  final userData =
                                      userSnap.data?.data()
                                          as Map<String, dynamic>?;

                                  final wallet =
                                      userData?['wallet']
                                          as Map<String, dynamic>?;

                                  final investments =
                                      wallet?['investments']
                                          as Map<String, dynamic>?;

                                  final myInvestment =
                                      investments?[widget.startupId];

                                  int myQty = 0;

                                  if (myInvestment is int) {
                                    myQty = myInvestment;
                                  } else if (myInvestment is Map) {
                                    myQty = _asInt(myInvestment['quantity']);
                                  }

                                  return _buildTokenCard(
                                    precoCents,
                                    myQty,
                                    capitalRaisedCents,
                                  );
                                },
                              )
                            else
                              _buildTokenCard(
                                precoCents,
                                0,
                                capitalRaisedCents,
                              ),

                            const SizedBox(height: 25),

                            _buildInfoCard(sumario, widget.startupId),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            
        
        
      ),
    bottomNavigationBar: const CustomBottomNav(paginaAtiva: 'startups'),
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

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildTokenCard(
    int precoCents,
    int meusTokens,
    int capitalRaisedCents,
  ) {
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
              const Text(
                "Meus Tokens:",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              _actionButton(
                "Comprar",
                const Color(0xFF1482C7),

                () => _handleDirectTransaction(true, precoCents),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "$meusTokens",

                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _actionButton(
                "Vender",
                Colors.red,

                () => _handleDirectTransaction(false, precoCents),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Capital Aportado:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "R\$ ${(capitalRaisedCents / 100).toStringAsFixed(2).replaceAll('.', ',')}",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Preço por token: R\$ ${(precoCents / 100.0).toStringAsFixed(2).replaceAll('.', ',')}",

            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 40,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

      onPressed: onPressed,

        child: Text(
          label,

          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
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
                color: const Color(0xFFBDD7EE),

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),

                border: Border.all(color: const Color(0xFF1482C7)),
              ),

              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    "Informações",

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

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
                const Text(
                  "Sumário Executivo:",

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  sumario,

                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
