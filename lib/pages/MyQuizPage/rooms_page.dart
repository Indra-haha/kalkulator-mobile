import 'package:flutter/material.dart';

import '../../models/quiz.dart';
import '../../services/api_client.dart';
import '../../services/quiz_cache_service.dart';
import '../../services/quiz_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../login_page.dart';

class RoomsPage extends StatefulWidget {
  final String quizId;

  const RoomsPage({super.key, required this.quizId});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  Quizes? _quiz;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final cached = await QuizCacheService.instance.getQuizById(widget.quizId);
    if (cached != null && mounted) {
      setState(() => _quiz = cached);
    }

    final token = await SessionService.instance.getToken();
    if (token == null) {
      _goToLogin();
      return;
    }

    try {
      final data = await QuizService.instance.getMyQuizzes(token);
      await QuizCacheService.instance.saveMyQuizzes(data);
      final found = _findQuiz(data, widget.quizId);
      if (!mounted) return;
      setState(() {
        _quiz = found;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await SessionService.instance.clear();
        _goToLogin();
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Rooms load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Tidak dapat terhubung ke server. ($e)';
        _loading = false;
      });
    }
  }

  Quizes? _findQuiz(MyQuizzes data, String id) {
    for (final quiz in data.all) {
      if (quiz.id == id) return quiz;
    }
    return null;
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _quiz?.title;
    return Scaffold(
      appBar: AppBar(
        title: Text(title == null || title.isEmpty ? 'Rooms' : title),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final quiz = _quiz;

    if (quiz == null && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quiz == null && _error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (quiz == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Quiz tidak ditemukan.'),
          ],
        ),
      );
    }

    final rooms = quiz.rooms;

    if (rooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada room untuk quiz ini.'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: rooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final data = rooms[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.kode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (data.status.isNotEmpty)
                      Chip(
                        label: Text(data.status),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (quiz.title.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    quiz.title,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (data.createdAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    data.createdAt,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
