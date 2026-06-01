// CÓDIGO FEITO PELO ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../trading_service.dart';
import 'tela_societario.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

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

  bool _carregando = true;
  String? _erro;
  bool _isLoading = false;

  String _nome = '';
  String _descricaoCurta = '';
  String? _logoUrl;
  String _stage = '';
  String _sumario = '';
  int _precoCents = 0;

  int _meusTokens = 0;

  int _capitalAportadoCents = 0;

  final _functions =
  FirebaseFunctions.instanceFor(region: 'us-central1');

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!_carregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final results = await Future.wait([
        _functions
            .httpsCallable('getStartupDetails')
            .call({'id': widget.startupId}),
        _functions
            .httpsCallable('getWallet')
            .call({}),
      ]);

      final startupData =
      Map<String, dynamic>.from(results[0].data['data']);

      final walletData =
      Map<String, dynamic>.from(results[1].data['wallet'] ?? {});
      final investments =
          walletData['investments'] as Map<dynamic, dynamic>? ?? {};
      final myInvestment = investments[widget.startupId];

      int myQty = 0;
      if (myInvestment is int) {
        myQty = myInvestment;
      } else if (myInvestment is Map) {
        myQty = _asInt(myInvestment['quantity']);
      }

      if (mounted) {
        setState(() {
          _nome = startupData['name'] ?? 'Sem nome';
          _descricaoCurta =
              startupData['shortDescription'] ?? 'Sem descrição';
          _logoUrl = startupData['coverImageUrl'];
          _stage = startupData['stage'] ?? 'Desconhecido';
          _sumario = startupData['executiveSummary'] ??
              startupData['shortDescription'] ??
              '';
          _precoCents =
              _asInt(startupData['currentTokenPriceCents']);
          _meusTokens = myQty;

          _capitalAportadoCents = _asInt(startupData['capitalRaisedCents'] ?? 0);

          _carregando = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() {
          _erro = _traduzirErro(e);
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Erro inesperado ao carregar os dados.';
          _carregando = false;
        });
      }
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _traduzirErro(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Sua sessão expirou. Faça login novamente.';
      case 'not-found':
        return 'Startup não encontrada.';
      case 'invalid-argument':
        return 'Requisição inválida. Tente novamente.';
      default:
        return e.message ?? 'Erro ao carregar os dados.';
    }
  }

  String _traduzirErroTransacao(dynamic e) {
    if (e is FirebaseFunctionsException) {
      final msg = e.message?.toLowerCase() ?? '';
      if (e.code == 'unauthenticated') {
        return 'Sua sessão expirou. Faça login novamente.';
      }
      if (msg.contains('saldo insuficiente') ||
          msg.contains('insufficient')) {
        return 'Saldo insuficiente para realizar esta transação.';
      }
      if (msg.contains('tokens insuficientes') ||
          msg.contains('investimento não encontrado')) {
        return 'Você não possui tokens suficientes para vender.';
      }
      return e.message ?? 'Erro ao processar a transação.';
    }
    return 'Erro inesperado. Tente novamente.';
  }

  Future<void> _handleDirectTransaction(
      bool isBuy, int currentPriceCents) async {
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
              final qty =
                  int.tryParse(quantityController.text.trim()) ?? 0;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              if (qty <= 0) {
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Quantidade inválida')),
                );
                return;
              }

              navigator.pop();
              if (!mounted) return;

              setState(() => _isLoading = true);

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
                      content: Text(
                        isBuy
                            ? 'Compra realizada com sucesso!'
                            : 'Venda realizada com sucesso!',
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  await _carregarDados();
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(_traduzirErroTransacao(e)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody()),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar:
      const CustomBottomNav(paginaAtiva: 'startups'),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _carregarDados,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStageBadge(_stage),
          const SizedBox(height: 20),
          _buildLargeImage(_logoUrl),
          const SizedBox(height: 20),
          Text(
            _nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _descricaoCurta,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 25),

          _buildTokenCard(_precoCents, _meusTokens, _capitalAportadoCents),

          const SizedBox(height: 25),
          _buildInfoCard(_sumario, widget.startupId),
          const SizedBox(height: 30),
        ],
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
            onPressed: () {
              // Força o redirecionamento limpando todas as rotas anteriores até a base
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/catalogo',
                    (route) => false,
              );
            },
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
        style: const TextStyle(fontSize: 16),
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
            ? Image.network(url, fit: BoxFit.cover)
            : const Icon(
          Icons.image,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTokenCard(int precoCents, int meusTokens, int capitalAportadoCents) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1482C7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Meus Tokens:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _actionButton(
                "Vender",
                const Color(0xFFF44336),
                    () => _handleDirectTransaction(false, precoCents),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            "Capital Aportado:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "R\$ ${(capitalAportadoCents / 100.0).toStringAsFixed(2).replaceAll('.', ',')}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              "Preço por token: R\$ ${(precoCents / 100.0).toStringAsFixed(2).replaceAll('.', ',')}",
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      String label,
      Color color,
      VoidCallback onPressed,
      ) {
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
        onPressed: _isLoading ? null : onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String sumario, String id) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1482C7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TelaSocietario(startupId: id),
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
                borderRadius: const BorderRadius.vertical(
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
                    style:
                    TextStyle(fontWeight: FontWeight.bold),
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
                  style:
                  TextStyle(fontWeight: FontWeight.bold),
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
}