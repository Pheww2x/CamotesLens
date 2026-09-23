// lib/widgets/probability_list.dart
// ---------------------------------------------------------------------------
// Premium card listing all class probabilities with animated gradient bars.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/constants.dart';

class ProbabilityList extends StatefulWidget {
  const ProbabilityList({
    super.key,
    required this.probabilities,
    required this.predictedClass,
  });

  /// Probability map — assumed to already be sorted descending.
  final Map<String, double> probabilities;

  /// The predicted (top) class name — highlighted differently.
  final String predictedClass;

  @override
  State<ProbabilityList> createState() => _ProbabilityListState();
}

class _ProbabilityListState extends State<ProbabilityList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
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
    final entries = widget.probabilities.entries.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.classProbabilities,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entries.length} Classes',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Column(
                  children: entries.asMap().entries.map((mapEntry) {
                    final index = mapEntry.key;
                    final entry = mapEntry.value;
                    return _ProbabilityRow(
                      rank: index + 1,
                      varietyName: entry.key,
                      probability: entry.value,
                      progressFactor: _animation.value,
                      isTopPrediction: entry.key == widget.predictedClass,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  const _ProbabilityRow({
    required this.rank,
    required this.varietyName,
    required this.probability,
    required this.progressFactor,
    required this.isTopPrediction,
  });

  final int rank;
  final String varietyName;
  final double probability;
  final double progressFactor;
  final bool isTopPrediction;

  @override
  Widget build(BuildContext context) {
    final percentText = '${(probability * 100).toStringAsFixed(1)}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: isTopPrediction
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: isTopPrediction
          ? BoxDecoration(
              color: AppColors.emeraldSubtle.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderEmerald,
                width: 1,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (isTopPrediction) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Text(
                        '$rank.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        varietyName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isTopPrediction
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isTopPrediction
                                  ? AppColors.primaryDark
                                  : AppColors.textPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                percentText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isTopPrediction ? FontWeight.w700 : FontWeight.w600,
                      color: isTopPrediction
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;
              final targetWidth =
                  fullWidth * (probability * progressFactor).clamp(0.0, 1.0);
              return Container(
                height: 8,
                width: fullWidth,
                decoration: BoxDecoration(
                  color: isTopPrediction
                      ? AppColors.emeraldLight.withValues(alpha: 0.5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: targetWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: isTopPrediction
                            ? AppColors.primaryGradient
                            : LinearGradient(
                                colors: [
                                  AppColors.primaryLight.withValues(alpha: 0.4),
                                  AppColors.emeraldVivid.withValues(alpha: 0.5),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
