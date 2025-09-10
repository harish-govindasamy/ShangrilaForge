import 'package:flutter/material.dart';

class FormFieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;
  final bool required;
  final EdgeInsetsGeometry? padding;

  const FormFieldWrapper({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
    this.required = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
