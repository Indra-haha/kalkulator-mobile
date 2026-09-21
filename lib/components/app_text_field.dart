import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: const TextStyle(fontSize: 16),
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    );
  }
}