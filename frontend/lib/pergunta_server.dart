//tela feita pela aluna marilia santos RA 25014905

import 'package:cloud_firestore/cloud_firestore.dart';
import 'pergunta_model.dart';

class PerguntaService {
  static Future<List<Pergunta>> fetchPerguntas(String startupId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('startups')
        .doc(startupId)
        .collection('perguntas')
        .orderBy('criadoEm', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Pergunta.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> enviarPergunta(String startupId, String texto) async {
    await FirebaseFirestore.instance
        .collection('startups')
        .doc(startupId)
        .collection('perguntas')
        .add({
      'pergunta': texto,
      'resposta': '',
      'publica': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}