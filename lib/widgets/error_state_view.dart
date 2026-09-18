import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? buttonColor;
  final TextStyle? messageStyle;

  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
    this.buttonColor,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: messageStyle ?? const TextStyle(fontSize: 14),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ?? AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    );
  }
}
