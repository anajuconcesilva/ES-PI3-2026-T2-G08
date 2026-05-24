// CÓDIGO FEITO PELA ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../trading_service.dart';

class TelaBalcaoDetalhes extends StatefulWidget {
  final String startupId;
  final String nome;
  final String preco;
  final String imageUrl;

  const TelaBalcaoDetalhes({
    super.key,
    required this.startupId,
    required this.nome,
    required this.preco,
    required this.imageUrl,
  });

  @override
  State<TelaBalcaoDetalhes> createState() => _TelaBalcaoDetalhesState();
}

class _TelaBalcaoDetalhesState extends State<TelaBalcaoDetalhes> {
  final Color azulPrincipal = const Color(0xFF1482C7);
  final Color vermelhoOferta = const Color(0xFFC80101);
  final Color verdeOferta = const Color(0xFF237E04);
  final fundoCard = const Color(0xFFF0F6FA);

  bool _mostrandoCompra = true;
  List<Map<String, dynamic>> _offers = [];
  bool _loadingOffers = false;

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _parseMoney(String value) {
    return double.parse(
      value.trim().replaceAll('.', '').replaceAll(',', '.'),
    );
  }

  String _shortUserId(dynamic value) {
    final userId = value?.toString() ?? '';

    if (userId.isEmpty) return 'N/A';

    return userId.length <= 8
        ? userId
        : userId.substring(0, 8);
  }

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _loadingOffers = true);

    try {
      final offers = await TradingService.listOffers();

      final startupOffers = offers
          .where(
            (o) => o['startupId'] == widget.startupId,
      )
          .toList();

      setState(() => _offers = startupOffers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao carregar ofertas: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingOffers = false);
      }
    }
  }

  void _showCreateOfferDialog(bool isBuy) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    bool isLoading = false;
    bool dialogAberto = true;

    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            isBuy
                ? 'Nova oferta de compra'
                : 'Nova oferta de venda',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: 'Quantidade de tokens',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: priceController,

                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: const InputDecoration(
                  labelText: 'Preço por token (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pop(context),

              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                final navigator = Navigator.of(context);

                final messenger =
                ScaffoldMessenger.of(context);

                if (quantityController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Preencha todos os campos',
                      ),
                    ),
                  );

                  return;
                }

                setState(() => isLoading = true);

                try {
                  final quantity = int.parse(
                    quantityController.text.trim(),
                  );

                  final price = _parseMoney(
                    priceController.text,
                  );

                  final priceCents =
                  TradingService.convertToCents(
                    price,
                  );

                  if (quantity <= 0 ||
                      priceCents <= 0) {
                    throw Exception(
                      'Quantidade e preço devem ser maiores que zero',
                    );
                  }

                  await TradingService.createOffer(
                    startupId: widget.startupId,
                    type: isBuy ? 'BUY' : 'SELL',
                    quantity: quantity,
                    tokenPrice: priceCents,
                  );

                  if (mounted) {
                    dialogAberto = false;

                    navigator.pop();

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Oferta criada com sucesso!',
                        ),
                      ),
                    );

                    _loadOffers();
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro: $e'),
                    ),
                  );
                } finally {
                  if (dialogAberto) {
                    setState(
                          () => isLoading = false,
                    );
                  }
                }
              },

              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Criar'),
            ),
          ],
        ),
      ),
    ).then((_) {
      quantityController.dispose();
      priceController.dispose();
    });
  }

  Future<void> _executeOffer(String offerId) async {
    try {
      await TradingService.executeOffer(
        offerId: offerId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Oferta executada com sucesso!',
            ),
          ),
        );

        _loadOffers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao executar oferta: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    final minhasOfertas = _offers
        .where(
          (offer) =>
      offer['userId'] == currentUserId,
    )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          "Balcão de negociação",

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: fundoCard,

                borderRadius:
                BorderRadius.circular(20),

                border: Border.all(
                  color: azulPrincipal,
                ),
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,

                    backgroundColor:
                    Colors.grey.shade300,

                    backgroundImage:
                    widget.imageUrl.isNotEmpty
                        ? NetworkImage(
                      widget.imageUrl,
                    )
                        : null,

                    child: widget.imageUrl.isEmpty
                        ? Icon(
                      Icons.business,
                      color: azulPrincipal,
                    )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.nome,

                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Ver detalhes",

                          style: TextStyle(
                            color: azulPrincipal,

                            decoration:
                            TextDecoration
                                .underline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children: [
                      const Text(
                        "Preço médio",

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      Text(
                        "R\$ ${widget.preco}",

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const Text(
                        "+ 2,35% hoje",

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mostrandoCompra = true;
                      });
                    },

                    child: _buildTab(
                      "Comprar",
                      _mostrandoCompra,
                      verdeOferta,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mostrandoCompra = false;
                      });
                    },

                    child: _buildTab(
                      "Vender",
                      !_mostrandoCompra,
                      vermelhoOferta,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_mostrandoCompra)
              _buildOfertasSection(
                "Ofertas de compra",
                verdeOferta,
                true,
              )
            else
              _buildOfertasSection(
                "Ofertas de venda",
                vermelhoOferta,
                false,
              ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),

                borderRadius:
                BorderRadius.circular(15),

                border: Border.all(
                  color: azulPrincipal,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [
                      const Text(
                        "Minhas ofertas",

                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      TextButton(
                        onPressed: _loadOffers,

                        child: const Text(
                          "Atualizar",

                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (_loadingOffers)
                    const Center(
                      child:
                      CircularProgressIndicator(),
                    )
                  else if (minhasOfertas.isEmpty)
                    const Text(
                      "Você não possui nenhuma oferta para este ativo.",

                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children:
                      minhasOfertas.map((offer) {
                        final type =
                        offer['type'] as String;

                        final quantity = _asInt(
                          offer['quantity'],
                        );

                        final price =
                            _asInt(
                              offer['tokenPrice'],
                            ) /
                                100.0;

                        final total =
                            quantity * price;

                        final color =
                        type == 'BUY'
                            ? verdeOferta
                            : vermelhoOferta;

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 8,
                          ),

                          child: Container(
                            padding:
                            const EdgeInsets.all(
                              12,
                            ),

                            decoration: BoxDecoration(
                              border: Border.all(
                                color: color,
                              ),

                              borderRadius:
                              BorderRadius
                                  .circular(
                                8,
                              ),
                            ),

                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [
                                    Text(
                                      type == 'BUY'
                                          ? 'Oferta de Compra'
                                          : 'Oferta de Venda',

                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .bold,

                                        color: color,
                                      ),
                                    ),

                                    Text(
                                      '$quantity tokens por R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',

                                      style:
                                      const TextStyle(
                                        fontSize: 12,
                                        color:
                                        Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                Text(
                                  'Total: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',

                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showCreateOfferDialog(true),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF2D6A4F),

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),

                    child: const Text(
                      "+ Nova oferta de compra",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showCreateOfferDialog(false),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFD32F2F),

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),

                    child: const Text(
                      "+ Nova oferta de venda",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: const _BottomNav(),
    );
  }

  Widget _buildTab(
      String label,
      bool active,
      Color corAtiva,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: active
            ? corAtiva.withOpacity(0.1)
            : Colors.grey.shade100,

        borderRadius:
        BorderRadius.circular(10),

        border: Border.all(
          color: active
              ? corAtiva
              : Colors.transparent,

          width: 1.5,
        ),
      ),

      child: Center(
        child: Text(
          label,

          style: TextStyle(
            color: active
                ? corAtiva
                : Colors.grey.shade600,

            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildOfertasSection(
      String titulo,
      Color cor,
      bool isCompra,
      ) {
    final ofertasFiltered = _offers
        .where(
          (o) =>
      o['type'] ==
          (isCompra ? 'BUY' : 'SELL'),
    )
        .toList();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          titulo,

          style: TextStyle(
            color: cor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        if (_loadingOffers)
          const Center(
            child:
            CircularProgressIndicator(),
          )
        else if (ofertasFiltered.isEmpty)
          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              border: Border.all(
                color: azulPrincipal,
              ),

              borderRadius:
              BorderRadius.circular(10),
            ),

            child: const Center(
              child: Text(
                'Nenhuma oferta disponível no momento',
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: azulPrincipal,
              ),

              borderRadius:
              BorderRadius.circular(10),
            ),

            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: fundoCard,

                    borderRadius:
                    const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),

                  padding: const EdgeInsets.all(10),

                  child: const Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [
                      Expanded(
                        child: Text(
                          "Usuário",

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "Quantidade",

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "Preço(R\$)",

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "Total(R\$)",

                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ...ofertasFiltered.map((offer) {
                  final quantity = _asInt(
                    offer['quantity'],
                  );

                  final tokenPrice =
                      _asInt(
                        offer['tokenPrice'],
                      ) /
                          100.0;

                  final total =
                      quantity * tokenPrice;

                  return _buildTableRow(
                    'Usuário ${_shortUserId(offer['userId'])}',

                    quantity.toString(),

                    tokenPrice
                        .toStringAsFixed(2)
                        .replaceAll('.', ','),

                    total
                        .toStringAsFixed(2)
                        .replaceAll('.', ','),

                    cor,

                        () => _executeOffer(
                      offer['id'] ?? '',
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTableRow(
      String user,
      String qtd,
      String preco,
      String total,
      Color cor,
      VoidCallback onExecute,
      ) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [
          Expanded(
            child: Text(
              user,

              style: TextStyle(
                color: cor,
                fontSize: 11,
              ),
            ),
          ),

          Expanded(
            child: Text(
              qtd,

              style: TextStyle(
                color: cor,
                fontSize: 11,
              ),
            ),
          ),

          Expanded(
            child: Text(
              preco,

              style: TextStyle(
                color: cor,
                fontSize: 11,
              ),
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: [
                Text(
                  total,

                  style: TextStyle(
                    color: cor,
                    fontSize: 11,
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.blue,
                  ),

                  onPressed: onExecute,

                  padding: EdgeInsets.zero,

                  constraints:
                  const BoxConstraints(),
                ),
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
      padding:
      const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,

        children: [
          _IconNav(
            icon: Icons.home,
            label: "Início",

            onTap: () {
              Navigator.pushNamed(
                context,
                '/geral',
              );
            },
          ),

          _IconNav(
            icon: Icons.emoji_events,
            label: "Startups",

            onTap: () {
              Navigator.pushNamed(
                context,
                '/catalogo',
              );
            },
          ),

          _IconNav(
            icon: Icons.wallet,
            label: "Carteira",

            onTap: () {
              Navigator.pushNamed(
                context,
                '/carteira',
              );
            },
          ),

          _IconNav(
            icon: Icons.show_chart,
            label: "Valorização",

            onTap: () {},

          ),

          _IconNav(
            icon: Icons.store,
            label: "Negociar",
            active: true,

            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _IconNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _IconNav({
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