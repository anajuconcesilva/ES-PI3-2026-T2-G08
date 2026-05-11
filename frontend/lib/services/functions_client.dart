import 'package:cloud_functions/cloud_functions.dart';

class FunctionsClient {
  const FunctionsClient();

  Future<Map<String, dynamic>> callMap(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    final callable = FirebaseFunctions.instance.httpsCallable(name);
    final result = await callable.call<Map<String, dynamic>>(data);

    return Map<String, dynamic>.from(result.data);
  }
}
