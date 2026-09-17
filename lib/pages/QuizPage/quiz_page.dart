import 'package:flutter/material.dart';

import '../../models/quiz.dart';
import '../../services/api_client.dart';
import '../../services/quiz_cache_service.dart';
import '../../services/quiz_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../login_page.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final int? userId;

  const QuizPage({super.key, this.user, this.userId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  AllQuizzes _allQuizzes = const AllQuizzes();
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
      final data = await QuizService.instance.getQuizzes(token);
      await QuizCacheService.instance.saveAllQuizzes(data);
      if (!mounted) return;
      setState(() {
        _allQuizzes = data;
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
      debugPrint('Quizzes load error: $e');
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
        title: const Text('Quiz'),
        backgroundColor: AppColors.highlight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final groups = _allQuizzes.groups
        .map(
          (g) => (
            status: g.status,
            rooms: g.quizzes.expand((q) => q.rooms).toList(),
          ),
        )
        .where((g) => g.rooms.isNotEmpty)
        .toList();

    if (groups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada room.'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        for (final group in groups) ...[
          _buildFilterHeader(group.status, group.rooms.length),
          const SizedBox(height: 8),
          ...group.rooms.map(_buildRoomTile),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildFilterHeader(String status, int count) {
    return Row(
      children: [
        Text(
          status,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text('$count'),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildRoomTile(RoomSummary room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(
          Icons.meeting_room_outlined,
          color: AppColors.primary,
        ),
        title: Text(
          room.kode,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: room.createdAt.isEmpty ? null : Text(room.createdAt),
        trailing: room.status.isEmpty
            ? null
            : Chip(
                label: Text(room.status),
                visualDensity: VisualDensity.compact,
              ),
      ),
    );
  }
}
