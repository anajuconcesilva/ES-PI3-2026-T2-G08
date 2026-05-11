import 'package:cloud_functions/cloud_functions.dart';

import 'functions_client.dart';

class StartupService {
  const StartupService({this.functionsClient = const FunctionsClient()});

  final FunctionsClient functionsClient;

  Future<List<Map<String, dynamic>>> listStartups({
    String? stage,
    String? search,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (stage != null && stage != 'todos') {
        payload['stage'] = stage;
      }

      if (search != null && search.trim().isNotEmpty) {
        payload['search'] = search.trim();
      }

      final response = await functionsClient.callMap('listStartups', payload);
      final startups = response['data'] as List<dynamic>? ?? [];

      return startups
          .map((startup) => Map<String, dynamic>.from(startup as Map))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao listar startups');
    }
  }

  Future<Map<String, dynamic>> getStartupDetails(String startupId) async {
    try {
      final response = await functionsClient.callMap('getStartupDetails', {
        'id': startupId,
      });

      return Map<String, dynamic>.from(response['data'] ?? response);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao buscar detalhes da startup');
    }
  }
}
