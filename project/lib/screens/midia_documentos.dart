import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../midia_model.dart';
import '../midia_server.dart';

class TelaMidiaCompleta extends StatefulWidget {
  const TelaMidiaCompleta({super.key});

  @override
  State<TelaMidiaCompleta> createState() => _TelaMidiaCompletaState();
}

class _TelaMidiaCompletaState extends State<TelaMidiaCompleta> {
  late Future<List<Midia>> futureMidias;

  @override
  void initState() {
    super.initState();
    futureMidias = MidiaService.fetchMidias("rota-verde");
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 1,
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
            child: CircleAvatar(
              backgroundColor: Color(0xFFE8E8E8),
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Midia>>(
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

          final midias = snapshot.data!;

          if (midias.isEmpty) {
            return const Center(child: Text("Nenhuma mídia encontrada"));
          }

          final pdfs = midias.where((m) => m.tipo == "pdf").toList();
          final videos = midias.where((m) => m.tipo == "video").toList();
          final imagens = midias.where((m) => m.tipo == "imagem").toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                border: Border.all(color: azul, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("Mídia", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Mídia e Documentos",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),

                  // ── PDFs ──
                  if (pdfs.isNotEmpty) ...[
                    const Text("Documentos", style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: pdfs.map((m) {
                        return GestureDetector(
                          onTap: () => abrirLink(m.url),
                          child: SizedBox(
                            width: 75,
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: azul,
                                  size: 42,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.titulo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Vídeos ──
                  if (videos.isNotEmpty) ...[
                    const Text("Vídeos", style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 10),
                    ...videos.map(
                          (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: VideoWidget(url: m.url),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Galeria ──
                  if (imagens.isNotEmpty) ...[
                    const Text("Galeria", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  img.url,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image,
                                              size: 40, color: Colors.red),
                                          SizedBox(height: 4),
                                          Text(
                                            "Erro ao carregar",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  img.titulo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
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
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: azul,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, size: 28),
            label: "Startups",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, size: 28),
            label: "Carteira",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart, size: 28),
            label: "Valorização",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store, size: 28),
            label: "Negociar",
          ),
        ],
      ),
    );
  }
}

// ── VideoWidget ──
class VideoWidget extends StatefulWidget {
  final String url;
  const VideoWidget({super.key, required this.url});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        IconButton(
          icon: Icon(
            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            setState(() {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}