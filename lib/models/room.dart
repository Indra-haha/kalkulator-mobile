import 'quiz.dart';

class Room {
  final String id;
  final String quizId;
  final String kode;
  final String status;
  final String createdAt;
  final QuizSummary? quiz;

  const Room({
    required this.id,
    required this.quizId,
    required this.kode,
    required this.status,
    required this.createdAt,
    this.quiz,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String? ?? '',
      quizId: json['quiz_id'] as String? ?? '',
      kode: json['kode'] as String? ?? '',
      status: json['status'] as String? ?? 'waiting',
      createdAt: json['created_at'] as String? ?? '',
      quiz: json['quiz'] == null
          ? null
          : QuizSummary.fromJson((json['quiz'] as Map).cast<String, dynamic>()),
    );
  }
}