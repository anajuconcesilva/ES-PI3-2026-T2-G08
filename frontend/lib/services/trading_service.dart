import 'package:cloud_functions/cloud_functions.dart';

import 'functions_client.dart';

class TradingService {
  const TradingService({this.functionsClient = const FunctionsClient()});

  final FunctionsClient functionsClient;

  Future<Map<String, dynamic>> createOffer({
    required String startupId,
    required String type,
    required num quantity,
    required num tokenPrice,
  }) async {
    try {
      final response = await functionsClient.callMap('createOffer', {
        'startupId': startupId,
        'type': type,
        'quantity': quantity,
        'tokenPrice': tokenPrice,
      });

      return Map<String, dynamic>.from(response['offer'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao criar oferta');
    }
  }

  Future<List<Map<String, dynamic>>> listOffers() async {
    try {
      final response = await functionsClient.callMap('listOffers');
      final offers = response['offers'] as List<dynamic>? ?? [];

      return offers
          .map((offer) => Map<String, dynamic>.from(offer as Map))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao listar ofertas');
    }
  }

  Future<void> executeOffer(String offerId) async {
    try {
      await functionsClient.callMap('executeOffer', {
        'offerId': offerId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao executar oferta');
    }
  }
}
