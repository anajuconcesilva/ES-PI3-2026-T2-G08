import 'package:cloud_functions/cloud_functions.dart';

import 'functions_client.dart';

class QuestionService {
  const QuestionService({this.functionsClient = const FunctionsClient()});

  final FunctionsClient functionsClient;

  Future<void> createQuestion({
    required String startupId,
    required String text,
    String visibility = 'publica',
  }) async {
    try {
      await functionsClient.callMap('createStartupQuestion', {
        'startupId': startupId,
        'text': text,
        'visibility': visibility,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao criar pergunta');
    }
  }

  Future<List<Map<String, dynamic>>> listQuestions({
    required String startupId,
    String? visibility,
    String? status,
  }) async {
    try {
      final payload = <String, dynamic>{
        'startupId': startupId,
      };

      if (visibility != null) {
        payload['visibility'] = visibility;
      }

      if (status != null) {
        payload['status'] = status;
      }

      final response =
          await functionsClient.callMap('listStartupQuestions', payload);
      final data = Map<String, dynamic>.from(response['data'] ?? response);
      final questions = data['questions'] as List<dynamic>? ?? [];

      return questions
          .map((question) => Map<String, dynamic>.from(question as Map))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao listar perguntas');
    }
  }

  Future<void> answerQuestion({
    required String startupId,
    required String questionId,
    required String answer,
  }) async {
    try {
      await functionsClient.callMap('answerStartupQuestion', {
        'startupId': startupId,
        'questionId': questionId,
        'answer': answer,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao responder pergunta');
    }
  }
}
