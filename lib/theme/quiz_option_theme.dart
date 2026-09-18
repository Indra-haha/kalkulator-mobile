import 'package:flutter/material.dart';

class QuizOptionTheme {
  final Color bg;
  final Color border;
  final Color dot;
  final String hint;

  const QuizOptionTheme({
    required this.bg,
    required this.border,
    required this.dot,
    required this.hint,
  });
}

const List<QuizOptionTheme> optionThemes = [
  QuizOptionTheme(
    bg: Color(0xFFFFDAD6),
    border: Color(0xFF93000A),
    dot: Color(0xFFBA1A1A),
    hint: 'Jawaban merah...',
  ),
  QuizOptionTheme(
    bg: Color(0xFFDBE1FF),
    border: Color(0xFF001453),
    dot: Color(0xFF4648D4),
    hint: 'Jawaban biru...',
  ),
  QuizOptionTheme(
    bg: Color(0xFFFFF9C4),
    border: Color(0xFF825100),
    dot: Color(0xFFA36700),
    hint: 'Jawaban kuning...',
  ),
  QuizOptionTheme(
    bg: Color(0xFFC8E6C9),
    border: Color(0xFF1B5E20),
    dot: Color(0xFF2E7D32),
    hint: 'Jawaban hijau...',
  ),
];
