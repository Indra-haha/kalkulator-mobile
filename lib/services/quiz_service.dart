import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quiz.dart';
import 'api_client.dart';

class QuizService {
  QuizService._();
  static final QuizService instance = QuizService._();

  Future<List<Quizes>> getQuizzes(String token) async {
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
    final list = data['quizzes'] as List;
    return list
        .map((e) => Quizes.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<Quizes>> getMyQuizzes(String token) async {
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
    final raw = _extractQuizList(data);
    return raw
        .map((e) => Quizes.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Quizes> createQuiz({
    required String token,
    required String title,
    String? description,
    required List<Map<String, dynamic>> questions,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiClient.baseUrl}/api/create/quiz'),
          headers: ApiClient.headers(token: token, body: true),
          body: jsonEncode({
            'title': title,
            'description': ?description,
            'questions': questions,
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

  Future<Quizes> getQuizDetail({
    required String token,
    required String id,
  }) async {
    final response = await http
        .get(
          Uri.parse('${ApiClient.baseUrl}/api/quiz/$id'),
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
    return Quizes.fromJson((data['quiz'] as Map).cast<String, dynamic>());
  }

  List<dynamic> _extractQuizList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['quizzes', 'quiz']) {
        final value = data[key];
        if (value is List) return value;
      }
      for (final value in data.values) {
        if (value is List) return value;
      }
    }
    return const [];
  }
}