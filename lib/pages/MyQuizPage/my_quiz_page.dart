import 'package:flutter/material.dart';

import '../../models/quiz.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_tab_bar.dart';
import '../../widgets/quiz_card.dart';
import 'rooms_page.dart';

const _filters = ['waiting', 'open', 'in-Game', 'ended'];

class MyQuizPage extends StatelessWidget {
  final MyQuizzes data;

  const MyQuizPage({super.key, required this.data});

  List<Quizes> _quizzesFor(String status) {
    switch (status) {
      case 'waiting':
        return data.waiting;
      case 'open':
        return data.open;
      case 'in-Game':
        return data.inGame;
      case 'ended':
        return data.ended;
      default:
        return const [];
    }
  }

  void _openRooms(BuildContext context, Quizes quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomsPage(quizId: quiz.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _filters.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Saya'),
          backgroundColor: AppColors.highlight,
          foregroundColor: Colors.white,
          bottom: AppTabBar(tabs: _filters),
        ),
        body: TabBarView(
          children: [
            for (final filter in _filters) _buildList(context, filter),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, String status) {
    final quizzes = _quizzesFor(status);

    if (quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Belum ada quiz di "$status".',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: quizzes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return QuizCard(
          quiz: quiz,
          onTap: () => _openRooms(context, quiz),
        );
      },
    );
  }
}
