// lib/widgets/primary_button.dart
// ---------------------------------------------------------------------------
// Premium gradient primary-action button with micro-animations.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../app/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = enabled && !isLoading && onPressed != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isInteractive ? AppColors.primaryGradient : null,
        color: isInteractive
            ? null
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        boxShadow: isInteractive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 22,
                    color: isInteractive
                        ? Colors.white
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isInteractive
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.38),
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
