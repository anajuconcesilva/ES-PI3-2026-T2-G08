// CÓDIGO FEITO PELO ALUNO: DIOGO GONÇALVES TONHOSOLO
//RA: 25894007
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'midia_documentos.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

class TelaSocietario extends StatefulWidget {
  final String startupId;

  const TelaSocietario({
    super.key,
    required this.startupId,
  });

  @override
  State<TelaSocietario> createState() =>
      _TelaSocietarioState();
}

class _TelaSocietarioState
    extends State<TelaSocietario> {

  int abaGovernanca = 0;


  bool _carregando = true;
  String? _erro;
  List _founders = [];
  List _externalMembers = [];

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
      final functions =
          FirebaseFunctions.instanceFor(region: 'us-central1');

      final result = await functions
          .httpsCallable('getStartupDetails')
          .call({'id': widget.startupId});

      final data =
          Map<String, dynamic>.from(result.data['data']);

      if (mounted) {
        setState(() {
          _founders =
              List.from(data['founders'] ?? []);
          _externalMembers =
              List.from(data['externalMembers'] ?? []);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),

      bottomNavigationBar:
          const CustomBottomNav(paginaAtiva: 'startups'),
    );
  }

  Widget _buildBody() {

    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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

    // dados carregados
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1482C7),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            _buildTabSocietario(context),

            const SizedBox(height: 20),

            const Text(
              "Conheça nossos Sócios:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildListaSocios(_founders),

            const SizedBox(height: 30),

            const Text(
              "Percentual de cada Sócio:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            _buildGraficoPizza(_founders),

            const SizedBox(height: 20),

            _buildSecaoGovernanca(_externalMembers),

            const SizedBox(height: 20),
          ],
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

  Widget _buildTabSocietario(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaMidiaCompleta(
              startupId: widget.startupId,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
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
              "Societário",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  Widget _buildListaSocios(List founders) {
    if (founders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "Nenhum sócio cadastrado.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Wrap(
      spacing: 40,
      runSpacing: 10,
      children: founders.map((f) {
        return SizedBox(
          width: 120,
          child: Text(
            "${founders.indexOf(f) + 1}. ${f['name']}",
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGraficoPizza(List founders) {
    if (founders.isEmpty) return const SizedBox.shrink();

    final List<Color> cores = [
      const Color(0xFF1482C7),
      const Color(0xFF2E75B6),
      const Color(0xFF9DC3E6),
      const Color(0xFFBDD7EE),
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: founders.map((f) {
            final index = founders.indexOf(f);
            // Suporte a int e double vindos do Firestore
            final double percent =
                (f['equityPercent'] ?? 0).toDouble();

            return PieChartSectionData(
              color: cores[index % cores.length],
              value: percent,
              title: "${f['name']}\n$percent%",
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSecaoGovernanca(List externalMembers) {
    final conselheiros = externalMembers
        .where((m) =>
            m['role'] == 'Conselheiro' ||
            m['role'] == 'Conselheira')
        .toList();

    final mentores = externalMembers
        .where((m) =>
            m['role'] == 'Mentor' ||
            m['role'] == 'Mentora')
        .toList();

    return Column(
      children: [
        const Text(
          "Governança: conselheiros e mentores",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btnGovernanca("Conselheiros", 0),
            const SizedBox(width: 17),
            _btnGovernanca("Mentores", 1),
          ],
        ),

        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildListaSimples(
                  abaGovernanca == 0
                      ? conselheiros
                      : mentores,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btnGovernanca(String label, int index) {
    final bool ativo = abaGovernanca == index;

    return GestureDetector(
      onTap: () {
        setState(() => abaGovernanca = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: ativo
              ? const Color(0xFFBDD7EE)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF1482C7),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildListaSimples(List lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text("Nenhum registro encontrado."),
      );
    }

    return Column(
      children: lista.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            "${lista.indexOf(item) + 1}. ${item['name']}",
          ),
        );
      }).toList(),
    );
  }
}