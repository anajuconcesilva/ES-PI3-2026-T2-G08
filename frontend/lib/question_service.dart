import 'package:cloud_functions/cloud_functions.dart';
import 'pergunta_model.dart';

class QuestionResponse {
  final List<Pergunta> perguntas;
  final bool canReadPrivateQuestions;

  QuestionResponse({
    required this.perguntas,
    required this.canReadPrivateQuestions,
  });
}

class QuestionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<QuestionResponse> fetchPerguntas(String startupId) async {
    final result = await _functions
        .httpsCallable('listStartupQuestions')
        .call({
      'startupId': startupId,
    });

    final data = Map<String, dynamic>.from(result.data);
    final response = Map<String, dynamic>.from(data['data']);

    final questions = response['questions'] as List<dynamic>;
    final access = Map<String, dynamic>.from(response['access']);

    final perguntas = questions
        .map((q) => Pergunta.fromMap(
      q['id'],
      Map<String, dynamic>.from(q),
    ))
        .toList();

    return QuestionResponse(
      perguntas: perguntas,
      canReadPrivateQuestions:
      access['canReadPrivateQuestions'] ?? false,
    );
  }

  Future<void> enviarPergunta(
      String startupId,
      String texto,
      bool privada,
      ) async {
    await _functions
        .httpsCallable('createStartupQuestion')
        .call({
      'startupId': startupId,
      'text': texto,
      'visibility': privada ? 'privada' : 'publica',
    });
  }
}