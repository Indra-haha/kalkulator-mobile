import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/quiz.dart';
import '../../services/api_client.dart';
import '../../services/quiz_cache_service.dart';
import '../../services/quiz_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/quiz_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_filter_chip.dart';
import '../login_page.dart';
import 'detail_quiz_room_page.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final int? userId;

  const QuizPage({super.key, this.user, this.userId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const _statuses = ['open', 'in-Game', 'ended'];

  AllQuizzes _allQuizzes = const AllQuizzes();
  bool _loading = true;
  String? _error;
  String _selectedStatus = 'open';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _ensureSelectedStatus();
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

  List<Quizes> _statusQuizzes(String status) {
    return switch (status) {
      'open' => _allQuizzes.open,
      'in-Game' => _allQuizzes.inGame,
      'ended' => _allQuizzes.ended,
      _ => <Quizes>[],
    };
  }

  void _ensureSelectedStatus() {
    if (_statusQuizzes(_selectedStatus).isNotEmpty) return;
    for (final status in _statuses) {
      if (_statusQuizzes(status).isNotEmpty) {
        _selectedStatus = status;
        return;
      }
    }
  }

  List<Quizes> get _selectedQuizzes {
    final quizzes = _statusQuizzes(_selectedStatus);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return quizzes;

    return quizzes.where((quiz) {
      if (quiz.title.toLowerCase().contains(query)) return true;
      return quiz.rooms.any((room) => room.kode.toLowerCase().contains(query));
    }).toList();
  }

  void _openRooms(Quizes quiz) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DetailQuizRoomPage(quiz: quiz)));
  }

  String _statusLabel(String status) {
    return switch (status) {
      'open' => 'Open',
      'in-Game' => 'In-Game',
      'ended' => 'Ended',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: SectionHeader(title: 'Quiz'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchField(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final status in _statuses) ...[
                    if (status != _statuses.first) const SizedBox(width: 8),
                    StatusFilterChip(
                      label: _statusLabel(status),
                      selected: _selectedStatus == status,
                      onTap: () => setState(() => _selectedStatus = status),
                    ),
                  ],
                ],
              ),
            ), 
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Ketik judul kuis atau 6 digit PIN...',
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.neutral,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.70),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 16,
          color: AppColors.neutral,
        ),
        suffixIcon: IconButton(
          tooltip: 'Refresh',
          onPressed: _loading ? null : _loadData,
          icon: const Icon(Icons.refresh, size: 16, color: AppColors.neutral),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neutralBorder),
        ),
      ),
    );
  }

  Widget _buildResults() {
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

    final quizzes = _selectedQuizzes;

    if (quizzes.isEmpty) {
      final query = _searchController.text.trim();
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isEmpty ? Icons.quiz_outlined : Icons.search_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'Belum ada quiz.'
                  : 'Tidak ada hasil untuk "$query".',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        for (var i = 0; i < quizzes.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          QuizCard(quiz: quizzes[i], onTap: () => _openRooms(quizzes[i])),
        ],
      ],
    );
  }
}
