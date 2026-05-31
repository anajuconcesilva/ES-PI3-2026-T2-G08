// * Código feito por Felipe Lima Miranda, RA: 25023932

import 'package:cloud_functions/cloud_functions.dart';

class BalcaoData {
  final List<Map<String, dynamic>> startups;
  final List<Map<String, dynamic>> offers;

  const BalcaoData({required this.startups, required this.offers});
}

class TradingService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<BalcaoData> fetchBalcaoData() async {
    final results = await Future.wait([listStartups(), listOffers()]);

    return BalcaoData(startups: results[0], offers: results[1]);
  }

  static Future<List<Map<String, dynamic>>> listStartups({
    String? search,
  }) async {
    final payload = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      payload['search'] = search.trim();
    }

    final result = await _functions.httpsCallable('listStartups').call(payload);
    final data = Map<String, dynamic>.from(result.data as Map);
    final startups = (data['data'] as List<dynamic>? ?? []);

    return startups
        .map((startup) => Map<String, dynamic>.from(startup as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> listOffers() async {
    final result = await _functions.httpsCallable('listOffers').call();
    final data = Map<String, dynamic>.from(result.data as Map);
    final offers = (data['offers'] as List<dynamic>? ?? []);

    return offers
        .map((offer) => Map<String, dynamic>.from(offer as Map))
        .toList();
  }

  static Future<void> createOffer({
    required String startupId,
    required String type,
    required int quantity,
    required int tokenPrice,
  }) async {
    await _functions.httpsCallable('createOffer').call({
      'startupId': startupId,
      'type': type,
      'quantity': quantity,
      'tokenPrice': tokenPrice,
    });
  }

  static Future<void> executeOffer({required String offerId}) async {
    await _functions.httpsCallable('executeOffer').call({'offerId': offerId});
  }

  static Future<void> buyToken({
    required String startupId,
    required int quantity,
    required int tokenPrice,
  }) async {
    await _functions.httpsCallable('buyToken').call({
      'startupId': startupId,
      'quantity': quantity,
      'tokenPrice': tokenPrice,
    });
  }

  static Future<void> sellToken({
    required String startupId,
    required int quantity,
    required int tokenPrice,
  }) async {
    await _functions.httpsCallable('sellToken').call({
      'startupId': startupId,
      'quantity': quantity,
      'tokenPrice': tokenPrice,
    });
  }

  static int convertToCents(double value) {
    return (value * 100).round();
  }
}
