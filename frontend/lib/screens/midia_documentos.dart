import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

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
                    return const Center(child: Text("Nenhuma mídia encontrada"));
                  }

                  final pdfs = midias.where((m) => m.tipo == "pdf").toList();
                  final videos = midias.where((m) => m.tipo == "video").toList();
                  final imagens = midias.where((m) => m.tipo == "imagem").toList();

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

                          // 🔵 BARRA AZUL IGUAL À OUTRA TELA
                          _buildTabMidia(context),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const SizedBox(height: 10),

                                // ── PDFs ──
                                if (pdfs.isNotEmpty) ...[
                                  const Text(
                                    "Documentos",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                              const Icon(Icons.insert_drive_file, color: azul, size: 40),
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

                                  const SizedBox(height: 25),
                                ],

                                // ── Vídeos ──
                                if (videos.isNotEmpty) ...[
                                  const Text(
                                    "Vídeos",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),

                                  ...videos.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: VideoWidget(url: m.url),
                                  )),

                                  const SizedBox(height: 10),
                                ],

                                // ── Galeria ──
                                if (imagens.isNotEmpty) ...[
                                  const Text(
                                    "Galeria",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),

                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: imagens.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.broken_image, size: 40, color: Colors.red),
                                                        SizedBox(height: 4),
                                                        Text("Erro ao carregar", style: TextStyle(fontSize: 10)),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return const Center(child: CircularProgressIndicator());
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // 🔝 HEADER
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Detalhes da Startup",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.person, size: 35),
        ],
      ),
    );
  }

  Widget _buildTabMidia(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.home, label: "Início"),
          _NavItem(icon: Icons.emoji_events, label: "Startups", active: true),
          _NavItem(icon: Icons.wallet, label: "Carteira"),
          _NavItem(icon: Icons.show_chart, label: "Valorização"),
          _NavItem(icon: Icons.store, label: "Negociar"),
        ],
      ),
    );
  }
}

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
            aspectRatio: controller.value.aspectRatio == 0
                ? 16 / 9
                : controller.value.aspectRatio,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFF1482C7) : Colors.black),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active ? const Color(0xFF1482C7) : Colors.black,
          ),
        ),
      ],
    );
  }
}