import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz.dart';
import '../theme/app_theme.dart';

class QuarantineCard extends StatelessWidget {
  final Quizes quiz;
  final VoidCallback? onTap;

  const QuarantineCard({super.key, required this.quiz, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFC7D2FE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'Quarantine',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.brandDeep,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (quiz.title.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Text(
                  quiz.title,
                  style: AppTextStyles.heading2,
                ),
              ),
            if (quiz.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: Text(
                  quiz.description,
                  style: AppTextStyles.bodyCaption,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xCCC7D2FE)),
                ),
              ),
              child: Row(
                children: [
                  _durationChip(),
                  const SizedBox(width: 4),
                  _gameChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationChip() {
    final total = quiz.questions.fold<double>(0, (sum, q) => sum + q.duration);
    final minutes = total.ceil();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 14, color: AppColors.neutralDark),
        const SizedBox(width: 4),
        Text(
          '$minutes menit',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _gameChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Text(
        '${quiz.rooms.length} Game',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.brandDeep,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    );
  }
}
