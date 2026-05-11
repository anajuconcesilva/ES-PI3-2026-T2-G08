import 'package:cloud_functions/cloud_functions.dart';

import 'functions_client.dart';

class WalletService {
  const WalletService({this.functionsClient = const FunctionsClient()});

  final FunctionsClient functionsClient;

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await functionsClient.callMap('getWallet');
      return Map<String, dynamic>.from(response['wallet'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao buscar carteira');
    }
  }

  Future<Map<String, dynamic>> addBalance(num value) async {
    try {
      final response = await functionsClient.callMap('addBalance', {
        'value': value,
      });

      return Map<String, dynamic>.from(response['wallet'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao adicionar saldo');
    }
  }

  Future<Map<String, dynamic>> buyToken({
    required String startupId,
    required num quantity,
    required num tokenPrice,
  }) async {
    try {
      final response = await functionsClient.callMap('buyToken', {
        'startupId': startupId,
        'quantity': quantity,
        'tokenPrice': tokenPrice,
      });

      return Map<String, dynamic>.from(response['wallet'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao comprar tokens');
    }
  }

  Future<Map<String, dynamic>> sellToken({
    required String startupId,
    required num quantity,
    required num tokenPrice,
  }) async {
    try {
      final response = await functionsClient.callMap('sellToken', {
        'startupId': startupId,
        'quantity': quantity,
        'tokenPrice': tokenPrice,
      });

      return Map<String, dynamic>.from(response['wallet'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao vender tokens');
    }
  }
}
