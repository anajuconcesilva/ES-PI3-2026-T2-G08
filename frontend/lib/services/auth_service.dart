import 'package:cloud_functions/cloud_functions.dart';

import 'functions_client.dart';

class AuthService {
  const AuthService({this.functionsClient = const FunctionsClient()});

  final FunctionsClient functionsClient;

  Future<void> registerUser({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String senha,
  }) async {
    try {
      await functionsClient.callMap('registerUser', {
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'senha': senha,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao cadastrar usuario');
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      await functionsClient.callMap('recoverPassword', {
        'email': email,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao enviar email de recuperacao');
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final response = await functionsClient.callMap('me');
      return Map<String, dynamic>.from(response['data'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao buscar usuario autenticado');
    }
  }

  Future<String?> startMfa() async {
    try {
      final response = await functionsClient.callMap('startMfa');
      final data = Map<String, dynamic>.from(response['data'] ?? response);
      return data['code']?.toString();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao iniciar MFA');
    }
  }

  Future<bool> verifyMfa(String code) async {
    try {
      final response = await functionsClient.callMap('verifyMfa', {
        'code': code,
      });
      final data = Map<String, dynamic>.from(response['data'] ?? response);
      return data['verified'] == true;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao validar MFA');
    }
  }

  Future<void> disableMfa() async {
    try {
      await functionsClient.callMap('disableMfa');
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao desativar MFA');
    }
  }

}
