import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

enum RoomStatus { waiting, open, inGame, ended }

class StatusBadge extends StatelessWidget {
  final String label;
  final RoomStatus status;

  const StatusBadge({super.key, required this.label, required this.status});

  factory StatusBadge.fromLabel(String status) {
    final s = _parse(status);
    return StatusBadge(label: status, status: s);
  }

  static RoomStatus _parse(String s) {
    switch (s) {
      case 'waiting':
        return RoomStatus.waiting;
      case 'open':
        return RoomStatus.open;
      case 'in-Game':
        return RoomStatus.inGame;
      case 'ended':
        return RoomStatus.ended;
      default:
        return RoomStatus.waiting;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.50,
        ),
      ),
    );
  }

  (Color, Color, Color) _colors() {
    switch (status) {
      case RoomStatus.waiting:
        return (AppColors.brandDeep, Colors.white, AppColors.brandDeep);
      case RoomStatus.open:
        return (AppColors.warningBg, AppColors.warningDark, AppColors.warningBorder);
      case RoomStatus.inGame:
        return (AppColors.successBg, AppColors.successDark, AppColors.successBorder);
      case RoomStatus.ended:
        return (AppColors.neutralBg, AppColors.neutralDark, AppColors.neutralBorder);
    }
  }

  static Color dotColor(String status) {
    final s = _parse(status);
    switch (s) {
      case RoomStatus.waiting:
        return AppColors.brandDeep;
      case RoomStatus.open:
        return AppColors.warning;
      case RoomStatus.inGame:
        return AppColors.success;
      case RoomStatus.ended:
        return AppColors.neutral;
    }
  }
}
