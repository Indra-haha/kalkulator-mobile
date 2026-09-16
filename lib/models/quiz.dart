class Quizes {
  final String id;
  final String title;
  final String description;
  final String token;
  final List<QuizQuestion> questions;

  Quizes({
    required this.id,
    required this.title,
    required this.description,
    required this.token,
    required this.questions,
  });

  factory Quizes.fromJson(Map<String, dynamic> json) {
    return Quizes(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      token: json['token'] as String? ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((e) => QuizQuestion.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;

  QuizQuestion({required this.question, required this.options});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List? ?? []).cast<String>(),
    );
  }
}

class QuizSummary {
  final String id;
  final String title;
  final String description;
  final int totalQuestions;

  const QuizSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
  });

  factory QuizSummary.fromJson(Map<String, dynamic> json) {
    return QuizSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalQuestions: json['total_questions'] as int? ?? 0,
    );
  }
}