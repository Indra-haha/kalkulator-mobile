import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/quiz.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_pill_button.dart';
import '../../widgets/quarantine_card.dart';
import '../../widgets/room_card.dart';
import '../../widgets/status_filter_chip.dart';
import 'rooms_page.dart';

const _statusFilters = ['waiting', 'open', 'in-Game', 'ended'];

class MyQuizPage extends StatefulWidget {
  final MyQuizzes data;

  const MyQuizPage({super.key, required this.data});

  @override
  State<MyQuizPage> createState() => _MyQuizPageState();
}

class _MyQuizPageState extends State<MyQuizPage> {
  String _selectedStatus = 'waiting';

  MyQuizzes get _data => widget.data;

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

  void _openRooms(Quizes quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomsPage(quizId: quiz.id)),
    );
  }

  void _onCreateRoom() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Create Room belum tersedia.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: const Text('Quiz Saya'),
      ),
      body: _buildBody(),
      floatingActionButton: AppPillButton(
        label: 'Create Room',
        onPressed: _onCreateRoom,
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
              onTap: () => _openRooms(entry.quiz),
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