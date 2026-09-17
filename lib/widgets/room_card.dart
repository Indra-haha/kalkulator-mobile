import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class RoomCard extends StatelessWidget {
  final Quizes quiz;
  final RoomSummary room;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.quiz,
    required this.room,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutralBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: StatusBadge.dotColor(room.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            quiz.title,
                            style: AppTextStyles.heading2,
                          ),
                        ),
                      ],
                    ),
                    if (quiz.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        quiz.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyCaption,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge.fromLabel(room.status),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _codeChip(),
                    const SizedBox(width: 6),
                    _copyButton(context),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Text(
        room.kode,
        style: const TextStyle(
          fontFamily: 'monospace',
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1.33,
          letterSpacing: 0.60,
        ),
      ),
    );
  }

  Widget _copyButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: room.kode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode room disalin.'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC7D2FE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy, size: 14, color: AppColors.brandDeep),
            const SizedBox(width: 4),
            Text(
              'Salin',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.brandDeep,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
