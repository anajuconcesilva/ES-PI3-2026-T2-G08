// tela feita pela aluna marilia santos RA 25014905

import 'package:cloud_firestore/cloud_firestore.dart';
import 'midia_model.dart'; // Importa o modelo que está na mesma pasta

class MidiaService {
  static Future<List<Midia>> fetchMidias(String startupId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('startups')
          .doc(startupId)
          .get();

      final data = doc.data();
      if (data == null) return [];

      List<Midia> midias = [];

      // 1. Pega o PDF (Pitch Deck)
      if (data['pitchDeckUrl'] != null && data['pitchDeckUrl'].toString().isNotEmpty) {
        midias.add(Midia(
          titulo: 'Pitch Deck',
          tipo: 'pdf',
          url: data['pitchDeckUrl'],
        ));
      }

      // 2. Pega os Vídeos (Demo Videos)
      final videos = data['demoVideos'] as List<dynamic>? ?? [];
      for (int i = 0; i < videos.length; i++) {
        if (videos[i].toString().isNotEmpty) {
          midias.add(Midia(
            titulo: 'Vídeo Demonstrativo ${i + 1}',
            tipo: 'video',
            url: videos[i].toString(),
          ));
        }
      }

      // 3. Pega a Imagem de capa (Opcional para mostrar na lista de mídia)
      if (data['coverImageUrl'] != null && data['coverImageUrl'].toString().isNotEmpty) {
        midias.add(Midia(
          titulo: data['name'] ?? 'Imagem da Startup',
          tipo: 'imagem',
          url: data['coverImageUrl'],
        ));
      }

      return midias;
    } catch (e) {
      print("Erro ao buscar mídias: $e");
      return [];
    }
  }
}