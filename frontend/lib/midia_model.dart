//feito pela marilia santos

  class Midia {
  final String titulo;
  final String tipo;
  final String url;

  Midia({
    required this.titulo,
    required this.tipo,
    required this.url,
  });

  factory Midia.fromMap(Map<String, dynamic> map) {
    return Midia(
      titulo: map['titulo'] ?? '',
      tipo: map['tipo'] ?? '',
      url: map['url'] ?? '',
    );
  }
}