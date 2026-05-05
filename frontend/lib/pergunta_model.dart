//tela feita pela aluna marilia santos RA 25014905

class Pergunta {
  final String id;
  final String pergunta;
  final String resposta;
  final bool publica;

  Pergunta({
    required this.id,
    required this.pergunta,
    required this.resposta,
    required this.publica,
  });

  factory Pergunta.fromMap(String id, Map<String, dynamic> map) {
    return Pergunta(
      id: id,
      pergunta: map['pergunta'] ?? '',
      resposta: map['resposta'] ?? '',
      publica: map['publica'] ?? true,
    );
  }
}