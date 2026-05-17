//tela feita pela aluna marilia santos RA 25014905

class Pergunta {
  final String id;
  final String text;
  final String answer;
  final String visibility;
  final String status;

  Pergunta({
    required this.id,
    required this.text,
    required this.answer,
    required this.visibility,
    required this.status,
  });

  factory Pergunta.fromMap(String id, Map<String, dynamic> map) {
    return Pergunta(
      id: id,
      text: map['text'] ?? '',
      answer: map['answer'] ?? '',
      visibility: map['visibility'] ?? 'publica',
      status: map['status'] ?? 'pendente',
    );
  }

  bool get publica => visibility == 'publica';
  String get pergunta => text;
  String get resposta => answer;
}