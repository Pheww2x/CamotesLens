// lib/widgets/confidence_card.dart
// ---------------------------------------------------------------------------
// Premium card displaying predicted variety, confidence score & gradient bar.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/classification_result.dart';
import '../utils/constants.dart';

class ConfidenceCard extends StatefulWidget {
  const ConfidenceCard({
    super.key,
    required this.result,
  });

  final ClassificationResult result;

  @override
  State<ConfidenceCard> createState() => _ConfidenceCardState();
}

class _ConfidenceCardState extends State<ConfidenceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLowConfidence =
        widget.result.confidence < AppConstants.lowConfidenceThreshold;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLowConfidence
              ? AppColors.amberAccent.withValues(alpha: 0.3)
              : const Color(0xFFE2EBE4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLowConfidence ? AppColors.amberAccent : AppColors.primary)
                .withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header pill ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSubtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderEmerald),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.predictedVariety,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowConfidence
                        ? AppColors.amberLight
                        : AppColors.emeraldLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLowConfidence ? 'Uncertain' : 'High Match',
                    style: TextStyle(
                      color: isLowConfidence
                          ? const Color(0xFFB45309)
                          : AppColors.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Variety Title ────────────────────────────────────────
            Text(
              isLowConfidence
                  ? 'Unable to identify'
                  : widget.result.predictedClass,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 14),

            // ── Confidence Row ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.confidence,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Text(
                  widget.result.confidencePercent,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isLowConfidence
                            ? colorScheme.error
                            : AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Animated Gradient Progress Bar ───────────────────────
            AnimatedBuilder(
              animation: _barAnimation,
              builder: (context, child) {
                final animatedProgress =
                    widget.result.confidence * _barAnimation.value;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final fullWidth = constraints.maxWidth;
                    return Container(
                      height: 12,
                      width: fullWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: fullWidth * animatedProgress.clamp(0.0, 1.0),
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: isLowConfidence
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.amberAccent,
                                        Color(0xFFEF4444)
                                      ],
                                    )
                                  : AppColors.barGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: (isLowConfidence
                                          ? AppColors.amberAccent
                                          : AppColors.emeraldVivid)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // ── Low-confidence warning ───────────────────────────────
            if (isLowConfidence) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.amberAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.lowConfidenceWarning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF78350F),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
