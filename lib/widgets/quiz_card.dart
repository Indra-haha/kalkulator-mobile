import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz.dart';
import '../theme/app_theme.dart';

class QuizCard extends StatelessWidget {
  final Quizes quiz;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: GoogleFonts.montserrat(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.56,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMeta(
                          Icons.sports_esports,
                          '${quiz.rooms.length} Main',
                        ),
                        if (quiz.createdAt.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          _buildMeta(
                            Icons.access_time,
                            relativeTime(quiz.createdAt),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return SizedBox(
      height: 192,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6063EE), Color(0xFF4648D4)],
              ),
            ),
            child: Center(
              child: Icon(Icons.quiz, size: 56, color: Colors.white24),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (quiz.status.isNotEmpty) _buildBadge(quiz.status, 16),
                const SizedBox(height: 4),
                _buildBadge('${quiz.questions.length} Soal', 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}

String relativeTime(String raw) {
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inDays >= 1) return '${diff.inDays} Hari lalu';
  if (diff.inHours >= 1) return '${diff.inHours} Jam lalu';
  if (diff.inMinutes >= 1) return '${diff.inMinutes} Menit lalu';
  return 'Baru saja';
}
