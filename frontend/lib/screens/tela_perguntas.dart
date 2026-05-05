// tela feita pela aluna marilia santos RA 25014905
import 'package:flutter/material.dart';
import '../pergunta_model.dart';
import '../pergunta_server.dart';
import 'midia_documentos.dart';

class TelaPerguntas extends StatefulWidget {
  final String startupId;

  const TelaPerguntas({super.key, required this.startupId});

  @override
  State<TelaPerguntas> createState() => _TelaPerguntasState();
}

class _TelaPerguntasState extends State<TelaPerguntas> {
  late Future<List<Pergunta>> futurePerguntas;
  final TextEditingController _controller = TextEditingController();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    futurePerguntas = PerguntaService.fetchPerguntas(widget.startupId);
  }

  void _recarregar() {
    setState(() {
      futurePerguntas = PerguntaService.fetchPerguntas(widget.startupId);
    });
  }

  Future<void> _enviarPergunta() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);

    await PerguntaService.enviarPergunta(widget.startupId, texto);
    _controller.clear();
    _recarregar();

    setState(() => _enviando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pergunta enviada com sucesso!")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1482C7);

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Detalhes da Startup",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.person, size: 30),
          ),
        ],
      ),
      body: FutureBuilder<List<Pergunta>>(
        future: futurePerguntas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final perguntas = snapshot.data!;
          final publicas = perguntas.where((p) => p.publica == true).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                border: Border.all(color: azul),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Retângulo azul no topo → vai para Mídia ──
                  GestureDetector(
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
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDD7EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: azul),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Perguntas e Respostas",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Interação e Suporte",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Perguntas e Respostas Públicas",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // ── Perguntas públicas ──
                  if (publicas.isEmpty)
                    const Text("Nenhuma pergunta pública ainda.")
                  else
                    ...publicas.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _perguntaResposta(
                        pergunta: p.pergunta,
                        resposta: p.resposta.isEmpty
                            ? "Aguardando resposta..."
                            : p.resposta,
                      ),
                    )),

                  const SizedBox(height: 28),

                  // ── Perguntas privadas ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: azul.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock, color: azul),
                            SizedBox(width: 8),
                            Text(
                              "Perguntas Privadas",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Perguntas privadas para os empreendedores",
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Apenas investidores possuem acesso a esta seção",
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Digite sua pergunta aqui",
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),
                            suffixIcon: _enviando
                                ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _enviarPergunta,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: azul,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Startups"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Carteira",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Valorização",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Negociar"),
        ],
      ),
    );
  }

  Widget _perguntaResposta({
    required String pergunta,
    required String resposta,
  }) {
    const azul = Color(0xFF1482C7);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pergunta:",
                style: TextStyle(color: azul, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(pergunta),
            const SizedBox(height: 12),
            const Text("Resposta:",
                style: TextStyle(color: azul, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(resposta),
          ],
        ),
      ),
    );
  }
}