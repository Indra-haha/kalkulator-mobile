import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/quiz_cache_service.dart';
import '../services/quiz_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/quiz_card.dart';
import 'MyQuizPage/create_quiz_page.dart';
import 'MyQuizPage/my_quiz_page.dart';
import 'MyQuizPage/rooms_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _user;
  bool _loggingOut = false;
  MyQuizzes _myQuizzes = const MyQuizzes();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadUser();
    _loadData();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.instance.getUser();
    if (user != null && mounted) {
      setState(() => _user = user);
    }
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
      await QuizCacheService.instance.saveMyQuizzes(data);
      if (!mounted) return;
      setState(() {
        _myQuizzes = data;
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

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    final token = await SessionService.instance.getToken();
    try {
      if (token != null) {
        await AuthService.instance.logout(token);
      }
    } catch (_) {
      // Backend tidak terjangkau; session lokal tetap dihapus.
    }
    await SessionService.instance.clear();
    await QuizCacheService.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openRooms(Quizes quiz) async {
    await QuizCacheService.instance.saveMyQuizzes(_myQuizzes);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomsPage(quizId: quiz.id),
        settings: const RouteSettings(name: 'rooms'),
      ),
    );
  }

  void _openAll() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyQuizPage(data: _myQuizzes)),
    );
  }

  ({String status, Quizes quiz})? _currentSection() {
    const priority = ['waiting', 'open', 'in-Game', 'ended'];
    final groups = {
      for (final group in _myQuizzes.groups) group.status: group.quizzes,
    };

    for (final status in priority) {
      final quizzes = groups[status];
      if (quizzes == null || quizzes.isEmpty) continue;
      final sorted = [...quizzes]
        ..sort((a, b) => _latestTime(b).compareTo(_latestTime(a)));
      return (status: status, quiz: sorted.first);
    }
    return null;
  }

  DateTime _latestTime(Quizes quiz) {
    var latest =
        DateTime.tryParse(quiz.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
    for (final room in quiz.rooms) {
      final time = DateTime.tryParse(room.createdAt);
      if (time != null && time.isAfter(latest)) latest = time;
    }
    return latest;
  }

  Future<void> _onCreateQuiz() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateQuizPage()),
    );
    if (created != true || !mounted) return;

    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz berhasil dibuat.')),
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyQuizPage(data: _myQuizzes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        backgroundColor: AppColors.highlight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _loggingOut ? null : _logout,
            icon: _loggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateQuiz,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: Text(
          'Buat Quiz Baru',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final section = _currentSection();

    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 96),
      children: [
        _buildGreeting(),
        const SizedBox(height: 16),
        _buildStats(),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          _buildError()
        else if (section == null)
          _buildEmpty()
        else ...[
          const SizedBox(height: 16),
          _buildSectionHeader(section.status),
          const SizedBox(height: 16),
          QuizCard(
            quiz: section.quiz,
            onTap: () => _openRooms(section.quiz),
          ),
        ],
      ],
    );
  }

  Widget _buildGreeting() {
    final nama = (_user?['nama'] as String?) ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nama.isEmpty ? 'Halo! 👋' : 'Halo, $nama! 👋',
          style: GoogleFonts.montserrat(
            color: AppColors.ink,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Total Main',
                value: '1.2k',
                icon: Icons.sports_esports,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                label: 'Rating Rata-rata',
                value: '4.8',
                icon: Icons.star,
                highlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Host Aktif',
                value: '12',
                icon: Icons.person,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                label: 'Terakhir Update',
                value: '2 Jam',
                icon: Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    final fg = highlight ? AppColors.onHighlight : AppColors.ink;
    final subFg = highlight ? AppColors.onHighlight : AppColors.muted;

    return Container(
      width: double.infinity,
      height: 128,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.highlight : AppColors.softBg,
        borderRadius: BorderRadius.circular(32),
        border: highlight ? null : Border.all(color: const Color(0x4CC7C4D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: fg, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: subFg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  color: fg,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            status,
            style: GoogleFonts.montserrat(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.21,
            ),
          ),
        ),
        TextButton(
          onPressed: _openAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.primary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lihat Semua',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highlight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'Belum ada quiz untukmu.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
