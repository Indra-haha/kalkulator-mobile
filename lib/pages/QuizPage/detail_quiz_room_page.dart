import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/quiz.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header_bar.dart';
import '../../widgets/quiz_card.dart' show relativeTime;

class DetailQuizRoomPage extends StatelessWidget {
  final Quizes quiz;

  const DetailQuizRoomPage({super.key, required this.quiz});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppHeaderBar(
        title: 'Detail Quiz',
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _heroCard(quiz),
        const SizedBox(height: 24),
        _roomSectionHeader(quiz.rooms.where((room) => room.status != 'waiting').length),
        const SizedBox(height: 16),
        if (quiz.rooms.isEmpty || quiz.rooms.every((room) => room.status == 'waiting'))
          _emptyRooms()
        else
          for (var i = 0; i < quiz.rooms.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            if (quiz.rooms[i].status != 'waiting')
            _roomCard(context, quiz, quiz.rooms[i], i),
          ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _heroCard(Quizes quiz) {
    final status = _quizStatus(quiz);
    final info = _statusInfo(status);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6063EE), Color(0xFF4648D4)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144648D4),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _heroStatusPill(info.color),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              quiz.title,
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
            ),
            if (quiz.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                quiz.description,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _statTile(
                      icon: Icons.timer_outlined,
                      value: _formatDuration(_totalDuration(quiz)),
                      label: 'Durasi',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statTile(
                      icon: Icons.list_alt,
                      value: '${quiz.questions.length}',
                      label: 'Pertanyaan',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statTile(
                      icon: Icons.checklist_rtl,
                      value: 'Pilihan Ganda',
                      label: 'Tipe',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStatusPill(Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            _statusInfo(_quizStatus(quiz)).label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroInfoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
        ),
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomSectionHeader(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Daftar Room',
              style: AppTextStyles.heading1.copyWith(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE1E0FF),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count Room',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF07006C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih room untuk langsung bergabung ke server kuis',
          style: AppTextStyles.bodyMeta,
        ),
      ],
    );
  }

  Widget _roomCard(
    BuildContext context,
    Quizes quiz,
    RoomSummary room,
    int index,
  ) {
    final info = _statusInfo(room.status);
    final subtitle = room.createdAt.isNotEmpty
        ? 'Dibuat ${relativeTime(room.createdAt)}'
        : 'Room #${index + 1}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: info.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: info.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            room.judul,
            style: GoogleFonts.montserrat(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PIN SERVER', style: AppTextStyles.bodyMeta),
                    const SizedBox(height: 2),
                    Text(
                      _formatKode(room.kode),
                      style: GoogleFonts.montserrat(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                        letterSpacing: 1.20,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (room.status == 'open')
                  SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: () => _showSnack(
                        context,
                        'Join Room ${room.kode} — fitur join menyusul.',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyRooms() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.meeting_room_outlined, size: 48, color: AppColors.neutral),
          const SizedBox(height: 12),
          Text(
            'Belum ada room untuk kuis ini.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  String _quizStatus(Quizes quiz) {
    if (quiz.status.isNotEmpty) return quiz.status;
    const priority = ['in-Game', 'open', 'ended'];
    for (final status in priority) {
      if (quiz.rooms.any((room) => room.status == status && room.status != 'waiting' ) ) return status;
    }
    return '';
  }

  ({String label, Color color, Color bg}) _statusInfo(String status) {
    switch (status) {
      case 'open':
        return (
          label: "${status[0].toUpperCase()}${status.substring(1)}",
          color: const Color(0xFF6B38D4),
          bg: const Color(0xFFE9DDFF),
        );
      case 'in-Game':
        return (
          label: "${status[0].toUpperCase()}${status.substring(1)}",
          color: AppColors.warningDark,
          bg: AppColors.warningBg,
        );
      case 'ended':
        return (
          label: "${status[0].toUpperCase()}${status.substring(1)}",
          color: AppColors.neutralDark,
          bg: AppColors.neutralBg,
        );
      case 'waiting':
        return (
          label: "${status[0].toUpperCase()}${status.substring(1)}",
          color: AppColors.muted,
          bg: AppColors.softBg,
        );
      default:
        return (
          label: "${status[0].toUpperCase()}${status.substring(1)}",
          color: AppColors.brandDeep,
          bg: const Color(0xFFE1E0FF),
        );
    }
  }

  String _formatKode(String kode) {
    if (kode.length == 6) {
      return '${kode.substring(0, 3)} ${kode.substring(3)}';
    }
    return kode;
  }

  double _totalDuration(Quizes quiz) {
    var total = 0.0;
    for (final q in quiz.questions) {
      total += q.duration;
    }
    return total;
  }

  String _formatDuration(double totalSeconds) {
    final total = totalSeconds.round();
    if (total < 60) return '$total Detik';
    final m = total ~/ 60;
    final s = total % 60;
    if (s == 0) return '$m Menit';
    return '$m Menit $s Detik';
  }
}
