import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/api_client.dart';
import '../services/quiz_service.dart';
import '../services/session_service.dart';
import 'login_page.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final int? userId;

  const QuizPage({super.key, this.user, this.userId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Quizes> _quizes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await SessionService.instance.getToken();
    if (token == null) {
      _goToLogin();
      return;
    }

    try {
      final data = await QuizService.instance.getMyQuizzes(token);
      if (!mounted) return;
      setState(() {
        _quizes = data;
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
      debugPrint('Quiz load error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Tidak dapat terhubung ke server. ($e)';
        _loading = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quiz'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_quizes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada quiz untukmu.'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _quizes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final data = _quizes[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (data.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (data.token.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Token: ${data.token}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${data.questions.length} soal',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}