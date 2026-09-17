import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numerus/pages/MyQuizPage/quiz_test_page.dart';

import '../../models/quiz.dart';
import '../../models/room.dart';
import '../../services/api_client.dart';
import '../../services/quiz_cache_service.dart';
import '../../services/quiz_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header_bar.dart';
import '../../widgets/app_pill_button.dart';
import '../../widgets/quarantine_card.dart';
import '../../widgets/room_card.dart';
import '../../widgets/status_filter_chip.dart';
import '../login_page.dart';
import 'create_room_sheet.dart';
import 'detail_room_page.dart';

const _statusFilters = ['waiting', 'open', 'in-Game', 'ended'];

class MyQuizPage extends StatefulWidget {
  final MyQuizzes data;

  const MyQuizPage({super.key, required this.data});

  @override
  State<MyQuizPage> createState() => _MyQuizPageState();
}

class _MyQuizPageState extends State<MyQuizPage> {
  String _selectedStatus = 'waiting';
  late MyQuizzes _data = widget.data;

  List<({Quizes quiz, RoomSummary room})> _roomsFor(String status) {
    final entries = <({Quizes quiz, RoomSummary room})>[
      for (final quiz in _data.all)
        for (final room in quiz.rooms)
          if (room.status == status) (quiz: quiz, room: room),
    ];
    entries.sort((a, b) {
      final t = _time(a.room.createdAt);
      final o = _time(b.room.createdAt);
      return o.compareTo(t);
    });
    return entries;
  }

  DateTime _time(String raw) {
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _openRooms(Quizes quiz) async {
    final result = await Navigator.of(context).push<PublishResult>(
      MaterialPageRoute<PublishResult>(
        builder: (_) => RoomsPage(quizId: quiz.id),
      ),
    );
    if (mounted && result != null) {
      setState(() => _selectedStatus = result.previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status room menjadi "${result.next}".')),
      );
      await _refresh();
    }
  }

  Future<void> _testRoom(Quizes quiz, RoomSummary room) async {
    final result = await Navigator.of(context).push<PublishResult>(
      MaterialPageRoute<PublishResult>(
        builder: (_) => QuizTestPage(quiz: quiz),
      ),
    );
    if (mounted && result != null) {
      setState(() => _selectedStatus = result.previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status room menjadi "${result.next}".')),
      );
    }
  }

  Future<void> _openRoomDetail(Quizes quiz, RoomSummary room) async {
    final result = await Navigator.of(context).push<PublishResult>(
      MaterialPageRoute<PublishResult>(
        builder: (_) => RoomDetailPage(quizId: quiz.id, room: room),
      ),
    );
    if (mounted && result != null) {
      setState(() => _selectedStatus = result.previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status room menjadi "${result.next}".')),
      );
    }
    if (mounted) await _refresh();
  }

  Future<void> _openCreateRoom() async {
    final room = await showCreateRoomSheet(context, _data);
    if (room == null || !mounted) return;
    await _showKodeDialog(room);
    await _refresh();
  }

  Future<void> _showKodeDialog(Room room) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Room Dibuat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kode Room',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              room.kode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: room.kode));
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Kode room disalin.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Salin'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    final token = await SessionService.instance.getToken();
    if (token == null) {
      _goToLogin();
      return;
    }
    try {
      final data = await QuizService.instance.getMyQuizzes(token);
      await QuizCacheService.instance.saveMyQuizzes(data);
      if (!mounted) return;
      setState(() => _data = data);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await SessionService.instance.clear();
        _goToLogin();
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      debugPrint('MyQuiz reload error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat ulang data.')),
      );
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
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: const AppHeaderBar(title: 'Quiz Saya'),
      body: _buildBody(),
      floatingActionButton: AppPillButton(
        label: 'Create Room',
        icon: Icons.add,
        onPressed: _openCreateRoom,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_data.isEmpty) return _buildEmpty();

    return ListView(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 112,
      ),
      children: [
        if (_data.quarantine.isNotEmpty) ...[
          for (final quiz in _data.quarantine)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuarantineCard(
                quiz: quiz,
                onTap: () => _openRooms(quiz),
              ),
            ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            for (final status in _statusFilters) ...[
              if (status != _statusFilters.first) const SizedBox(width: 8),
              StatusFilterChip(
                label: status,
                selected: _selectedStatus == status,
                onTap: () => setState(() => _selectedStatus = status),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _buildRoomList(_selectedStatus),
      ],
    );
  }

  Widget _buildRoomList(String status) {
    final entries = _roomsFor(status);

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.meeting_room_outlined, size: 48, color: AppColors.neutral),
            const SizedBox(height: 12),
            Text(
              'Tidak ada room dengan status "$status".',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RoomCard(
              quiz: entry.quiz,
              room: entry.room,
              onTap: () => _openRoomDetail(entry.quiz, entry.room),
              onTestPressed: () => _testRoom(entry.quiz, entry.room),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
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
}