import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz.dart';

class QuizCacheService {
  QuizCacheService._();
  static final QuizCacheService instance = QuizCacheService._();

  static const _kMyQuizzes = 'cache_my_quizzes';
  static const _kAllQuizzes = 'cache_all_quizzes';

  Future<void> saveMyQuizzes(MyQuizzes data) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(data.all.map((q) => q.toJson()).toList());
    await prefs.setString(_kMyQuizzes, raw);
  }

  Future<void> saveAllQuizzes(AllQuizzes data) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(data.all.map((q) => q.toJson()).toList());
    await prefs.setString(_kAllQuizzes, raw);
  }

  Future<List<Quizes>> getMyQuizzes() async {
    return _read(_kMyQuizzes);
  }

  Future<List<Quizes>> getAllQuizzes() async {
    return _read(_kAllQuizzes);
  }

  Future<List<Quizes>> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Quizes.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Quizes?> getQuizById(String id) async {
    final quizzes = [...await getMyQuizzes(), ...await getAllQuizzes()];
    for (final quiz in quizzes) {
      if (quiz.id == id) return quiz;
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kMyQuizzes);
    await prefs.remove(_kAllQuizzes);
  }
}
