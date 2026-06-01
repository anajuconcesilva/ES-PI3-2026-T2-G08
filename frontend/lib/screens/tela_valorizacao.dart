// CÓDIGO FEITO PELO ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mescla_invest_app/trading_service.dart';
import 'package:mescla_invest_app/screens/tela_detalhes.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

class TelaValorizacao extends StatefulWidget {
  const TelaValorizacao({super.key});

  @override
  State<TelaValorizacao> createState() => _TelaValorizacaoState();
}

class _TelaValorizacaoState extends State<TelaValorizacao> {
  String _periodoLabelSelecionado = 'Diário';
  List<Map<String, dynamic>> _startups = [];
  Map<String, dynamic>? _startupSelecionada;
  String _periodoSelecionado = 'daily';
  Map<String, dynamic>? _dadosValorizacao;

  bool _carregandoStartups = true;
  bool _carregandoGrafico = false;
  String? _erro;
  int? _tooltipIndex;

  final List<Map<String, String>> _periodos = [
    {'label': 'Diário',  'value': 'daily'},
    {'label': 'Semanal', 'value': 'weekly'},
    {'label': 'Mensal',  'value': 'monthly'},
    {'label': 'Anual',   'value': 'ytd'},
  ];

  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  @override
  void initState() {
    super.initState();
    _carregarStartups();
  }

  Future<void> _carregarStartups() async {
    try {
      final result = await _functions.httpsCallable('listStartups').call({});
      final data = result.data as Map<String, dynamic>;
      final list = List<Map<String, dynamic>>.from(
        (data['data'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
      setState(() {
        _startups = list;
        _carregandoStartups = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar startups: $e';
        _carregandoStartups = false;
      });
    }
  }

  Future<void> _carregarValorizacao() async {
    if (_startupSelecionada == null) return;
    setState(() {
      _carregandoGrafico = true;
      _tooltipIndex = null;
    });
    try {
      final result = await _functions.httpsCallable('getTokenValuation').call({
        'startupId': _startupSelecionada!['id'],
        'period': _periodoSelecionado,
      });
      final data = result.data as Map<String, dynamic>;
      setState(() {
        _dadosValorizacao = Map<String, dynamic>.from(data['data']);
        _carregandoGrafico = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar valorização: $e';
        _carregandoGrafico = false;
      });
    }
  }

  // ──  compra/venda ───────────────────────────────
  Future<void> _handleDirectTransaction(bool isBuy) async {
    if (_startupSelecionada == null) return;

    final startupId = _startupSelecionada!['id'] ?? '';
    final precoCents = (_startupSelecionada!['currentTokenPriceCents'] ?? 0) as int;
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
              'Preço atual: R\$ ${(precoCents / 100.0).toStringAsFixed(2).replaceAll('.', ',')}',
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
                  const SnackBar(content: Text('Quantidade inválida')),
                );
                return;
              }

              navigator.pop();
              if (!mounted) return;

              try {
                if (isBuy) {
                  await TradingService.buyToken(
                    startupId: startupId,
                    quantity: qty,
                    tokenPrice: precoCents,
                  );
                } else {
                  await TradingService.sellToken(
                    startupId: startupId,
                    quantity: qty,
                    tokenPrice: precoCents,
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

                  if (e is FirebaseFunctionsException) {
                    final mensagemErro = e.message?.toLowerCase() ?? '';

                    if (mensagemErro.contains('insufficient_balance') ||
                        mensagemErro.contains('saldo insuficiente')) {
                      mensagemAmigavel = 'Saldo insuficiente para realizar esta transação.';
                    } else if (e.code == 'unauthenticated') {
                      mensagemAmigavel = 'Sua sessão expirou. Faça login novamente.';
                    } else {
                      mensagemAmigavel = e.message ?? mensagemAmigavel;
                    }
                  } else {
                    mensagemAmigavel = e.toString();
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


  List<FlSpot> _gerarPontos() {
    if (_dadosValorizacao == null) return [];
    final points = _dadosValorizacao!['points'] as List? ?? [];

    List<FlSpot> spots = [];
    for (int i = 0; i < points.length; i++) {

      final precoCentavos = (points[i]['price'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), precoCentavos));
    }

    return spots;
  }
  double _precoAtual() {
    if (_dadosValorizacao == null) return 0;
    return ((_dadosValorizacao!['currentPrice'] as num?) ?? 0).toDouble();
  }

  double _variacao() {
    if (_dadosValorizacao == null) return 0;
    return (_dadosValorizacao!['variationPercent'] as num?)?.toDouble() ?? 0.0;
  }

  String _formatarMoeda(double centavos) {
    final reais = centavos / 100;
    return 'R\$ ${reais.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _labelPonto(int index) {
    if (_dadosValorizacao == null) return '';
    final points = _dadosValorizacao!['points'] as List? ?? [];
    if (index >= points.length) return '';
    return points[index]['label']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final pontos = _gerarPontos();
    final precoAtual = _precoAtual();
    final variacao = _variacao();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/geral',
                  (route) => false,
            );
          },
        ),
        title: const Text(
          'Valorização de Tokens',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(paginaAtiva: 'valorizacao'),
      body: _carregandoStartups
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(child: Text(_erro!, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Selecione uma Startup e acompanhe o\ncrescimento de seus investimentos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _DropdownStartup(
              startups: _startups,
              selecionada: _startupSelecionada,
              onChanged: (startup) {
                setState(() => _startupSelecionada = startup);
                _carregarValorizacao();
              },
            ),
          ),
          const SizedBox(height: 16),

          if (_startupSelecionada != null)
            _CardStartup(
              startup: _startupSelecionada!,
              onVerDetalhes: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TelaDetalhesInformaEs(
                    startupId: _startupSelecionada!['id'] ?? '',
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Gráfico
          Expanded(
            child: _carregandoGrafico
                ? const Center(child: CircularProgressIndicator())
                : _dadosValorizacao == null
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Desempenho $_periodoLabelSelecionado',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                  Text('${variacao >= 0 ? "+" : ""}${variacao.toStringAsFixed(2).replaceAll('.', ',')}%',
                    style: TextStyle(
                      color: variacao >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: pontos.length < 2
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.show_chart, color: Colors.black26, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            pontos.isEmpty
                                ? 'Sem dados para o período selecionado.'
                                : 'Apenas uma transação neste período.\nSem variação para exibir.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black45, fontSize: 13),
                          ),
                        ],
                      ),
                    )

                        : _Grafico(
                      pontos: pontos,

                      positivo: variacao >= 0,
                      tooltipIndex: _tooltipIndex,
                      precoAtual: precoAtual,
                      labelPonto: _labelPonto,
                      formatarMoeda: _formatarMoeda,
                      onTouch: (index) =>
                          setState(() => _tooltipIndex = index),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AbasPeriodo(
                    periodos: _periodos,
                    selecionado: _periodoSelecionado,
                    onChanged: (p) {
                      final periodoMap = _periodos.firstWhere((element) => element['value'] == p);

                      setState(() {
                        _periodoSelecionado = p;
                        _periodoLabelSelecionado = periodoMap['label']!;
                      });

                      _carregarValorizacao();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          if (_startupSelecionada != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDirectTransaction(true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Comprar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleDirectTransaction(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEDED),
                        foregroundColor: const Color(0xFFFF0800),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFFF0800)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Vender',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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



class _DropdownStartup extends StatelessWidget {
  final List<Map<String, dynamic>> startups;
  final Map<String, dynamic>? selecionada;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _DropdownStartup({
    required this.startups,
    required this.selecionada,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          isExpanded: true,
          hint: const Text('Selecione uma Startup'),
          value: selecionada,
          items: startups.map((s) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: s,
              child: Text(s['name']?.toString() ?? ''),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _CardStartup extends StatelessWidget {
  final Map<String, dynamic> startup;
  final VoidCallback onVerDetalhes;

  const _CardStartup({
    required this.startup,
    required this.onVerDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = startup['coverImageUrl']?.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderLogo(),
              )
                  : _placeholderLogo(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                startup['name']?.toString() ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: onVerDetalhes,
              child: const Text(
                'Ver detalhes',
                style: TextStyle(
                  color: Color(0xFF1482C7),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderLogo() {
    return Container(
      width: 44,
      height: 44,
      color: Colors.grey.shade200,
      child: const Icon(Icons.business, color: Colors.grey),
    );
  }
}

class _Grafico extends StatelessWidget {
  final List<FlSpot> pontos;
  final bool positivo;
  final int? tooltipIndex;
  final double precoAtual;
  final String Function(int) labelPonto;
  final String Function(double) formatarMoeda;
  final ValueChanged<int?> onTouch;

  const _Grafico({
    required this.pontos,
    required this.positivo,
    required this.tooltipIndex,
    required this.precoAtual,
    required this.labelPonto,
    required this.formatarMoeda,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final corLinha = positivo ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final yValues = pontos.map((p) => p.y).toList();
    final yMin = yValues.reduce((a, b) => a < b ? a : b);
    final yMax = yValues.reduce((a, b) => a > b ? a : b);

    final diff = yMax - yMin;
    final yPadding = diff == 0 ? yMax * 0.1 : diff * 0.2;

    final contaOriginalIntervalo = (yMax + yPadding - (yMin - yPadding)) / 5;

    final calculadoMinY = (yMin - yPadding) - (contaOriginalIntervalo * 0.15);
    final calculadoMaxY = yMax + yPadding + 0.01;

    return LineChart(
      LineChartData(
        minY: calculadoMinY,
        maxY: calculadoMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: contaOriginalIntervalo,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: contaOriginalIntervalo,
              getTitlesWidget: (value, _) {
                if (value < -0.1) return const SizedBox.shrink();
                final valorAjustado = value.abs() < 0.1 ? 0.0 : value;

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    formatarMoeda(valorAjustado),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: pontos.length > 6 ? (pontos.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= pontos.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    labelPonto(idx),
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
              onTouch(response.lineBarSpots!.first.spotIndex);
            } else {
              onTouch(null);
            }
          },
          getTouchedSpotIndicator: (_, spots) => spots.map((_) {
            return TouchedSpotIndicatorData(
              FlLine(color: corLinha, strokeWidth: 1.5, dashArray: [4, 4]),
              FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 5,
                  color: corLinha,
                  strokeColor: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          }).toList(),
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => corLinha.withOpacity(0.9),
            getTooltipItems: (spots) => spots.map((spot) {
              return LineTooltipItem(
                '${formatarMoeda(spot.y)} @ ${labelPonto(spot.spotIndex)}',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: pontos,
            isCurved: true,
            curveSmoothness: 0.3,
            color: corLinha,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  corLinha.withOpacity(0.25),
                  corLinha.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbasPeriodo extends StatelessWidget {
  final List<Map<String, String>> periodos;
  final String selecionado;
  final ValueChanged<String> onChanged;

  const _AbasPeriodo({
    required this.periodos,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: periodos.map((p) {
          final ativo = p['value'] == selecionado;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: ativo ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: ativo
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                      : [],
                ),
                child: Text(
                  p['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
                    color: ativo ? const Color(0xFF1482C7) : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}