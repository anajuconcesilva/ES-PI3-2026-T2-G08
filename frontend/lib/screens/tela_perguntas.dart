import 'package:flutter/material.dart';
import 'package:mescla_invest_app/services/question_service.dart';

class TelaPerguntas extends StatefulWidget {
  final String startupId;

  const TelaPerguntas({super.key, required this.startupId});

  @override
  State<TelaPerguntas> createState() => _TelaPerguntasState();
}

class _TelaPerguntasState extends State<TelaPerguntas> {
  final QuestionService questionService = const QuestionService();
  final TextEditingController perguntaController = TextEditingController();

  late Future<Map<String, dynamic>> perguntasFuture;
  String visibilidade = 'publica';
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    perguntasFuture = questionService.listQuestionsData(
      startupId: widget.startupId,
    );
  }

  @override
  void dispose() {
    perguntaController.dispose();
    super.dispose();
  }

  void recarregarPerguntas() {
    setState(() {
      perguntasFuture = questionService.listQuestionsData(
        startupId: widget.startupId,
      );
    });
  }

  Future<void> enviarPergunta() async {
    final texto = perguntaController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite sua pergunta.')),
      );
      return;
    }

    setState(() => enviando = true);

    try {
      await questionService.createQuestion(
        startupId: widget.startupId,
        text: texto,
        visibility: visibilidade,
      );

      perguntaController.clear();
      recarregarPerguntas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pergunta enviada com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => enviando = false);
      }
    }
  }

  Future<void> responderPergunta(Map<String, dynamic> pergunta) async {
    final respostaController = TextEditingController(
      text: pergunta['answer']?.toString() ?? '',
    );

    final resposta = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Responder pergunta'),
          content: TextField(
            controller: respostaController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Digite a resposta',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                respostaController.text.trim(),
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    respostaController.dispose();

    if (resposta == null || resposta.isEmpty) {
      return;
    }

    try {
      await questionService.answerQuestion(
        startupId: widget.startupId,
        questionId: pergunta['id'].toString(),
        answer: resposta,
      );

      recarregarPerguntas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resposta salva com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1482C7);

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: const Text('Perguntas e Respostas'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8E8E8),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: perguntasFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final perguntas = (data['questions'] as List<dynamic>? ?? [])
              .map((pergunta) => Map<String, dynamic>.from(pergunta as Map))
              .toList();
          final access = Map<String, dynamic>.from(data['access'] ?? {});
          final canManageStartup = access['canManageStartup'] == true;
          final canReadPrivateQuestions =
              access['canReadPrivateQuestions'] == true;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _secaoNovaPergunta(
                azul: azul,
                canReadPrivateQuestions: canReadPrivateQuestions,
              ),
              const SizedBox(height: 22),
              Text(
                canReadPrivateQuestions
                    ? 'Perguntas da startup'
                    : 'Perguntas públicas',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (perguntas.isEmpty)
                const Text('Nenhuma pergunta encontrada.')
              else
                ...perguntas.map(
                  (pergunta) => _cardPergunta(
                    pergunta: pergunta,
                    azul: azul,
                    canManageStartup: canManageStartup,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _secaoNovaPergunta({
    required Color azul,
    required bool canReadPrivateQuestions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: azul),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enviar pergunta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: perguntaController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Digite sua pergunta para os empreendedores',
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Pública'),
                selected: visibilidade == 'publica',
                onSelected: (_) => setState(() => visibilidade = 'publica'),
              ),
              ChoiceChip(
                label: const Text('Privada'),
                selected: visibilidade == 'privada',
                onSelected: (_) => setState(() => visibilidade = 'privada'),
              ),
            ],
          ),
          if (!canReadPrivateQuestions && visibilidade == 'privada') ...[
            const SizedBox(height: 8),
            const Text(
              'Perguntas privadas são aceitas apenas para investidores da startup.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: enviando ? null : enviarPergunta,
              icon: enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: azul,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardPergunta({
    required Map<String, dynamic> pergunta,
    required Color azul,
    required bool canManageStartup,
  }) {
    final resposta = pergunta['answer']?.toString();
    final temResposta = resposta != null && resposta.isNotEmpty;
    final visibility = pergunta['visibility']?.toString() ?? 'publica';
    final status = pergunta['status']?.toString() ?? 'pendente';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: azul.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                visibility == 'privada' ? Icons.lock : Icons.public,
                size: 18,
                color: azul,
              ),
              const SizedBox(width: 6),
              Text(
                visibility == 'privada' ? 'Privada' : 'Pública',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                status,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pergunta['text']?.toString() ?? '',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              temResposta ? resposta : 'Aguardando resposta...',
              style: TextStyle(
                fontSize: 14,
                color: temResposta ? Colors.black : Colors.black54,
              ),
            ),
          ),
          if (canManageStartup) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => responderPergunta(pergunta),
                icon: const Icon(Icons.reply),
                label: Text(temResposta ? 'Editar resposta' : 'Responder'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
