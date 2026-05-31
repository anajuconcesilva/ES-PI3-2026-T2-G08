// tela feita pela aluna marilia santos RA 25014905

import 'package:flutter/material.dart';
import '../pergunta_model.dart';
import '../question_service.dart';
import 'midia_documentos.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

class TelaPerguntas extends StatefulWidget {

  final String startupId;

  const TelaPerguntas({
    super.key,
    this.startupId = '',
  });

  @override
  State<TelaPerguntas> createState() =>
      _TelaPerguntasState();
}

class _TelaPerguntasState
    extends State<TelaPerguntas> {

  late Future<QuestionResponse>
  futurePerguntas;

  bool _privada = false;

  final TextEditingController
  _controller =
  TextEditingController();

  bool _enviando = false;

  @override
  void initState() {
    super.initState();

    futurePerguntas =
        QuestionService().fetchPerguntas(
          widget.startupId,
        );
  }

  void _recarregar() {

    setState(() {

      futurePerguntas =
          QuestionService().fetchPerguntas(
            widget.startupId,
          );
    });
  }

  Future<void> _enviarPergunta() async {

    final texto =
    _controller.text.trim();

    if (texto.isEmpty) return;

    setState(() => _enviando = true);

    try {

      await QuestionService().enviarPergunta(
        widget.startupId,
        texto,
        _privada,
      );

      _controller.clear();

      _recarregar();

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(
            content: Text(
              "Pergunta enviada com sucesso!",
            ),
          ),
        );
      }

    } catch (e) {

      print("ERRO AO ENVIAR: $e");

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(
              "Erro: $e",
            ),
          ),
        );
      }

    } finally {

      if (mounted) {

        setState(() => _enviando = false);
      }
    }
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const azul =
    Color(0xFF1482C7);

    return Scaffold(
      backgroundColor:
      const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [

            _buildHeader(context),

            Expanded(
              child:
              FutureBuilder<QuestionResponse>(

                future:
                futurePerguntas,

                builder: (
                    context,
                    snapshot,
                    ) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {

                    return Center(
                      child: Text(
                        "Erro: ${snapshot.error}",
                      ),
                    );
                  }

                  final response =
                  snapshot.data!;

                  final perguntas =
                      response.perguntas;

                  final podePrivada =
                      response.canReadPrivateQuestions;

                  final publicas =
                  perguntas.where(
                        (p) =>
                    p.publica == true,
                  ).toList();

                  return SingleChildScrollView(
                    padding:
                    const EdgeInsets.all(
                      16,
                    ),

                    child: Container(
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFE8E8E8,
                        ),

                        border:
                        Border.all(
                          color:
                          azul,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          20,
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
                                  builder:
                                      (
                                      context,
                                      ) =>
                                      TelaMidiaCompleta(
                                        startupId:
                                        widget.startupId,
                                      ),
                                ),
                              );
                            },

                            child: Container(
                              width:
                              double.infinity,

                              padding:
                              const EdgeInsets.symmetric(
                                vertical:
                                10,

                                horizontal:
                                15,
                              ),

                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFBDD7EE,
                                ),

                                borderRadius:
                                const BorderRadius.vertical(
                                  top:
                                  Radius.circular(
                                    18,
                                  ),
                                ),

                                border:
                                Border.all(
                                  color:
                                  azul,
                                ),
                              ),

                              child:
                              const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                                children: [

                                  Text(
                                    "Perguntas e Respostas",

                                    style:
                                    TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding:
                            const EdgeInsets.all(
                              16,
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                const SizedBox(
                                  height: 24,
                                ),

                                const Text(
                                  "Interação e Suporte",

                                  style:
                                  TextStyle(
                                    fontSize:
                                    26,

                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                const Text(
                                  "Perguntas e Respostas Públicas",

                                  style:
                                  TextStyle(
                                    fontSize:
                                    14,
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                if (publicas.isEmpty)

                                  const Text(
                                    "Nenhuma pergunta pública ainda.",
                                  )

                                else

                                  ...publicas.map(
                                        (p) => Padding(
                                      padding:
                                      const EdgeInsets.only(
                                        bottom:
                                        16,
                                      ),

                                      child:
                                      _perguntaResposta(
                                        pergunta:
                                        p.pergunta,

                                        resposta:
                                        p.resposta
                                            .isEmpty
                                            ? "Aguardando resposta..."
                                            : p.resposta,
                                      ),
                                    ),
                                  ),

                                const SizedBox(
                                  height: 28,
                                ),

                                Container(
                                  padding:
                                  const EdgeInsets.all(
                                    16,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    azul.withOpacity(
                                      0.25,
                                    ),

                                    borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                    children: [

                                      const Row(
                                        children: [

                                          Icon(
                                            Icons.lock,

                                            color:
                                            azul,
                                          ),

                                          SizedBox(
                                            width:
                                            8,
                                          ),

                                          Text(
                                            "Perguntas Privadas",

                                            style:
                                            TextStyle(
                                              fontSize:
                                              22,

                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 6,
                                      ),

                                      const Text(
                                        "Perguntas privadas são exclusivas para investidores",

                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 16,
                                      ),

                                      Container(
                                        margin:
                                        const EdgeInsets.only(
                                          bottom: 16,
                                        ),

                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal:
                                          14,

                                          vertical:
                                          12,
                                        ),

                                        decoration:
                                        BoxDecoration(
                                          color:
                                          Colors.white.withOpacity(
                                            0.35,
                                          ),

                                          borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                        ),

                                        child: Row(
                                          children: [

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                                children: [

                                                  const Text(
                                                    "Modo exclusivo",

                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      15,

                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 4,
                                                  ),

                                                  Text(
                                                    podePrivada
                                                        ? "Visível apenas para a equipe da startup"
                                                        : "Liberado somente para investidores",

                                                    style:
                                                    const TextStyle(
                                                      fontSize:
                                                      12,

                                                      color:
                                                      Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Switch(
                                              value:
                                              _privada,

                                              onChanged:
                                              podePrivada
                                                  ? (value) {

                                                setState(() {

                                                  _privada = value;
                                                });
                                              }
                                                  : null,

                                              activeColor:
                                              azul,
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      TextField(
                                        controller:
                                        _controller,

                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          "Digite sua pergunta aqui",

                                          filled:
                                          true,

                                          fillColor:
                                          const Color(
                                            0xFFD9D9D9,
                                          ),

                                          suffixIcon:
                                          _enviando
                                              ? const Padding(
                                            padding:
                                            EdgeInsets.all(
                                              12,
                                            ),

                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth:
                                              2,
                                            ),
                                          )
                                              : IconButton(
                                            icon:
                                            const Icon(
                                              Icons.send,
                                            ),

                                            onPressed:
                                            _enviarPergunta,
                                          ),

                                          border:
                                          OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              10,
                                            ),

                                            borderSide:
                                            BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ],
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
            ),

            
          ],
        ),
      ),
       bottomNavigationBar: const CustomBottomNav(paginaAtiva: 'startups'),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ) {

    return Padding(
      padding:
      const EdgeInsets.all(16),

      child: Row(
        children: [

          IconButton(
            icon:
            const Icon(
              Icons.arrow_back,
            ),

            onPressed: () =>
                Navigator.pop(
                  context,
                ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                "Detalhes da Startup",

                style: TextStyle(
                  fontSize: 18,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 48,
          ),
        ],
      ),
    );
  }

  
  Widget _perguntaResposta({
    required String pergunta,
    required String resposta,
  }) {

    const azul =
    Color(0xFF1482C7);

    return Card(
      elevation: 2,

      child: Padding(
        padding:
        const EdgeInsets.all(
          14,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              "Pergunta:",

              style: TextStyle(
                color: azul,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(pergunta),

            const SizedBox(
              height: 12,
            ),

            const Text(
              "Resposta:",

              style: TextStyle(
                color: azul,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(resposta),
          ],
        ),
      ),
    );
  }
}

