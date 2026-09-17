import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quiz.dart';
import 'api_client.dart';

class QuizService {
  QuizService._();
  static final QuizService instance = QuizService._();

  Future<AllQuizzes> getQuizzes(String token) async {
    final response = await http
        .get(
          Uri.parse('${ApiClient.baseUrl}/api/quizzes'),
          headers: ApiClient.headers(token: token),
        )
        .timeout(const Duration(seconds: 10));
    final data = ApiClient.decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.message(data),
        statusCode: response.statusCode,
      );
    }
    return AllQuizzes.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<MyQuizzes> getMyQuizzes(String token) async {
    final response = await http
        .get(
          Uri.parse('${ApiClient.baseUrl}/api/my-quizzes'),
          headers: ApiClient.headers(token: token),
        )
        .timeout(const Duration(seconds: 10));
    final data = ApiClient.decode(response);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.message(data),
        statusCode: response.statusCode,
      );
    }
    return MyQuizzes.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<Quizes> createQuiz({
    required String token,
    required String title,
    String? description,
    required List<QuizQuestionInput> questions,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiClient.baseUrl}/api/create/quiz'),
          headers: ApiClient.headers(token: token, body: true),
          body: jsonEncode({
            'title': title,
            'description': ?description,
            'questions': questions.map((q) => q.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 10));
    final data = ApiClient.decode(response);
    if (response.statusCode != 201) {
      throw ApiException(
        ApiClient.message(data),
        statusCode: response.statusCode,
      );
    }
    return Quizes.fromJson((data['quiz'] as Map).cast<String, dynamic>());
  }
}
