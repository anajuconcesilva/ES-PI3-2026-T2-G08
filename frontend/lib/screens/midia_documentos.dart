// tela feita pela aluna marilia santos RA 25014905

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/screens/tela_perguntas.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mescla_invest_app/widgets/custom_bottom_nav.dart';

import '../midia_model.dart';
import '../midia_server.dart';

class TelaMidiaCompleta extends StatefulWidget {
  final String startupId;

  const TelaMidiaCompleta({super.key, required this.startupId});

  @override
  State<TelaMidiaCompleta> createState() => _TelaMidiaCompletaState();
}

class _TelaMidiaCompletaState extends State<TelaMidiaCompleta> {
  late Future<List<Midia>> futureMidias;

  @override
  void initState() {
    super.initState();

    futureMidias = MidiaService.fetchMidias(widget.startupId);
  }

  Future<void> abrirLink(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir o link");
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1482C7);

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: FutureBuilder<List<Midia>>(
                future: futureMidias,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),

                        child: Text(
                          "Erro ao carregar mídias:\n${snapshot.error}",

                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final midias = snapshot.data ?? [];

                  if (midias.isEmpty) {
                    return const Center(
                      child: Text("Nenhuma mídia encontrada"),
                    );
                  }

                  final pdfs = midias.where((m) => m.tipo == "pdf").toList();

                  final videos = midias
                      .where((m) => m.tipo == "video")
                      .toList();

                  final imagens = midias
                      .where((m) => m.tipo == "imagem")
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),

                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: azul, width: 1.5),
                      ),

                      child: Column(
                        children: [
                          _buildTabMidia(context),

                          Padding(
                            padding: const EdgeInsets.all(16),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const SizedBox(height: 10),

                                if (pdfs.isNotEmpty) ...[
                                  const Text(
                                    "Documentos",

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 10,

                                    children: pdfs.map((m) {
                                      return GestureDetector(
                                        onTap: () => abrirLink(m.url),

                                        child: SizedBox(
                                          width: 80,

                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.insert_drive_file,

                                                color: azul,

                                                size: 40,
                                              ),

                                              const SizedBox(height: 6),

                                              Text(
                                                m.titulo,

                                                textAlign: TextAlign.center,

                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 25),
                                ],

                                if (videos.isNotEmpty) ...[
                                  const Text(
                                    "Vídeos",

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  ...videos.map(
                                    (m) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),

                                      child: GestureDetector(
                                        onTap: () => abrirLink(m.url),

                                        child: Container(
                                          padding: const EdgeInsets.all(16),

                                          decoration: BoxDecoration(
                                            color: Colors.white,

                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),

                                            border: Border.all(color: azul),
                                          ),

                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.play_circle_fill,

                                                color: azul,

                                                size: 40,
                                              ),

                                              const SizedBox(width: 12),

                                              const Expanded(
                                                child: Text(
                                                  "Abrir vídeo demonstrativo",

                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                ],

                                if (imagens.isNotEmpty) ...[
                                  const Text(
                                    "Galeria",

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  GridView.builder(
                                    shrinkWrap: true,

                                    physics:
                                        const NeverScrollableScrollPhysics(),

                                    itemCount: imagens.length,

                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,

                                          crossAxisSpacing: 12,

                                          mainAxisSpacing: 12,

                                          childAspectRatio: 0.95,
                                        ),

                                    itemBuilder: (context, index) {
                                      final img = imagens[index];

                                      return Card(
                                        elevation: 3,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),

                                        clipBehavior: Clip.antiAlias,

                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Image.network(
                                                img.url,

                                                width: double.infinity,

                                                fit: BoxFit.cover,
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(8),

                                              child: Text(
                                                img.titulo,

                                                textAlign: TextAlign.center,

                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
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

  Widget _buildTabMidia(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) => TelaPerguntas(startupId: widget.startupId),
          ),
        );
      },

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),

        decoration: BoxDecoration(
          color: const Color(0xFFBDD7EE),

          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),

          border: Border.all(color: const Color(0xFF1482C7)),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              "Mídia e Documentos",

              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
