// lib/widgets/image_picker_card.dart
// ---------------------------------------------------------------------------
// Premium interactive card for camera / gallery selection.
// Features micro-interactions, emerald gradient accents, and glassmorphic styling.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../app/theme.dart';

class ImagePickerCard extends StatefulWidget {
  const ImagePickerCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<ImagePickerCard> createState() => _ImagePickerCardState();
}

class _ImagePickerCardState extends State<ImagePickerCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE2EBE4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: BorderRadius.circular(22),
            splashColor: AppColors.emeraldLight.withValues(alpha: 0.4),
            highlightColor: AppColors.emeraldSubtle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              child: Row(
                children: [
                  // Gradient icon container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emeraldVivid.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sleek arrow circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
