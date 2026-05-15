class Usuario {
  final String nome;
  final String email;
  final String cpf;
  final String telefone;

  Usuario({
    required this.nome,
    required this.email,
    required this.cpf,
    required this.telefone,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
    );
  }
}