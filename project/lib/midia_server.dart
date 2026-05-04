import 'package:cloud_firestore/cloud_firestore.dart';
import 'midia_model.dart';

class MidiaService {
  static Future<List<Midia>> fetchMidias(String startupId) async {
    final doc = await FirebaseFirestore.instance
        .collection('startups')
        .doc(startupId)
        .get();

    final data = doc.data();
    if (data == null) return [];

    List<Midia> midias = [];

    // PDF
    if (data['pitchDeckUrl'] != null && data['pitchDeckUrl'] != '') {
      midias.add(Midia(
        titulo: 'Pitch Deck',
        tipo: 'pdf',
        url: data['pitchDeckUrl'],
      ));
    }

    // Vídeos
    final videos = data['demoVideos'] as List<dynamic>? ?? [];
    for (int i = 0; i < videos.length; i++) {
      midias.add(Midia(
        titulo: 'Vídeo ${i + 1}',
        tipo: 'video',
        url: videos[i].toString(),
      ));
    }

    // Imagem de capa
    if (data['coverImageUrl'] != null && data['coverImageUrl'] != '') {
      midias.add(Midia(
        titulo: data['name'] ?? 'Imagem',
        tipo: 'imagem',
        url: data['coverImageUrl'],
      ));
    }

    return midias;
  }
}
