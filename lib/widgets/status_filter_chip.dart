import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandDeep : Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? AppColors.brandDeep : AppColors.neutralBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0x0C000000),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: selected ? Colors.white : AppColors.neutralDark,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w600,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
