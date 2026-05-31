// CÓDIGO FEITO PELA ALUNA: ANA JÚLIA CONCEIÇÃO DA SILVA
// RA:25002592

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_detalhes.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

class TelaCatalogo extends StatefulWidget {
  const TelaCatalogo({super.key});

  @override
  State<TelaCatalogo> createState() => _TelaCatalogoState();
}

class _TelaCatalogoState extends State<TelaCatalogo> {

  String filtroStage = "todos";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  IconButton(
                    onPressed: () =>
                        Navigator.pop(context),

                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Catálogo de Startups",

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: GestureDetector(
                onTap: () async {

                  final selecionado =
                  await showModalBottomSheet<String>(
                    context: context,

                    builder: (context) {

                      return Column(
                        mainAxisSize:
                        MainAxisSize.min,

                        children: [

                          _opcaoFiltro(
                            "todos",
                            "Todos",
                          ),

                          _opcaoFiltro(
                            "nova",
                            "Nova",
                          ),

                          _opcaoFiltro(
                            "em_operacao",
                            "Em operação",
                          ),

                          _opcaoFiltro(
                            "em_expansao",
                            "Em expansão",
                          ),
                        ],
                      );
                    },
                  );

                  if (selecionado != null) {

                    setState(() {
                      filtroStage =
                          selecionado;
                    });
                  }
                },

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFDBD9D9),

                    borderRadius:
                    BorderRadius.circular(25),

                    border: Border.all(
                      color:
                      const Color(0xFF1482C7),
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.filter_list,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          filtroStage == "todos"
                              ? "Filtrar por estágio"
                              : filtroStage.replaceAll(
                            "_",
                            " ",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(

                stream: filtroStage == "todos"
                    ? FirebaseFirestore.instance
                    .collection('startups')
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection('startups')
                    .where(
                  'stage',
                  isEqualTo:
                  filtroStage,
                )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.hasError) {

                    print(
                      "ERRO FIRESTORE: ${snapshot.error}",
                    );

                    return Center(
                      child: Text(
                        "Erro: ${snapshot.error}",
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting ||
                      !snapshot.hasData) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  final docs =
                      snapshot.data!.docs;

                  if (docs.isEmpty) {

                    return const Center(
                      child: Text(
                        "Nenhuma startup encontrada",
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    itemCount: docs.length,

                    itemBuilder:
                        (context, index) {

                      final data =
                      docs[index].data()
                      as Map<String, dynamic>;

                      return _StartupCard(
                        nome:
                        data["name"] ??
                            "Sem nome",

                        descricao:
                        data["shortDescription"] ??
                            "Sem descrição",

                        logoUrl:
                        data["coverImageUrl"],

                        stage:
                        data["stage"] ??
                            "desconhecido",

                        onPressed: () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                                  TelaDetalhesInformaEs(
                                    startupId:
                                    docs[index].id,
                                  ),
                            ),
                          );
                        },
                      );
                    },
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

  Widget _opcaoFiltro(
      String value,
      String label,
      ) {

    return ListTile(
      title: Text(label),

      onTap: () {
        Navigator.pop(
          context,
          value,
        );
      },
    );
  }
}

class _StartupCard extends StatelessWidget {

  final String nome;
  final String descricao;
  final String? logoUrl;
  final String stage;
  final VoidCallback onPressed;

  const _StartupCard({
    required this.nome,
    required this.descricao,
    this.logoUrl,
    required this.stage,
    required this.onPressed,
  });

  String getStageLabel() {

    switch (stage) {

      case "nova":
        return "Nova";

      case "em_operacao":
        return "Em operação";

      case "em_expansao":
        return "Em expansão";

      default:
        return "Desconhecido";
    }
  }

  Color getStageColor() {

    switch (stage) {

      case "nova":
        return Colors.blue;

      case "em_operacao":
        return Colors.green;

      case "em_expansao":
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin:
      const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color:
        const Color(0xFFE8E8E8),

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color:
          const Color(0xFF1482C7),
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [

          logoUrl != null &&
              logoUrl!.isNotEmpty

              ? ClipRRect(
            borderRadius:
            BorderRadius.circular(8),

            child: Image.network(
              logoUrl!,

              width: 70,
              height: 70,

              fit: BoxFit.cover,

              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {

                return const Icon(
                  Icons.broken_image,
                  size: 70,
                );
              },
            ),
          )

              : const Icon(
            Icons.image,
            size: 70,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,

              children: [

                Text(
                  nome,

                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  descricao,

                  textAlign:
                  TextAlign.center,

                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color:
                    getStageColor()
                        .withOpacity(0.2),

                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Text(
                    getStageLabel(),

                    style: TextStyle(
                      color:
                      getStageColor(),

                      fontSize: 11,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 120,

                  child: ElevatedButton(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF1482C7,
                      ),

                      foregroundColor:
                      Colors.white,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),

                    onPressed: onPressed,

                    child: const Text(
                      "Conhecer",
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

