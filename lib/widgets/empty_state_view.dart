import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? iconColor;
  final TextStyle? messageStyle;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: iconColor ?? Colors.grey),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style:
                  messageStyle ??
                  GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
