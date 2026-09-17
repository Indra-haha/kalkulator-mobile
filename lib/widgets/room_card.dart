import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/quiz.dart';
import '../theme/app_theme.dart';

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
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    quiz.title,
                    style: AppTextStyles.heading2,
                  ),
                ),
              ),
              _codeChip(),
              const SizedBox(width: 6),
              _copyButton(context),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _monitorButton(context),
          ),
        ],
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

  Widget _monitorButton(BuildContext context) {
    return Material(
      color: AppColors.successDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'Pantau Live',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}