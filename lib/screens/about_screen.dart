// lib/screens/about_screen.dart
// ---------------------------------------------------------------------------
// About screen: purpose, usage guide, limitations, and supported formats.
// Editorial layout with emerald accents and glassmorphic cards.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'About CamotesLens',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Banner ───────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/camotes_lens_logo.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Convolutional neural network-based leaf image analysis for agricultural identification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── How to use ─────────────────────────────────────────
                    const _SectionCard(
                      icon: Icons.help_outline_rounded,
                      title: 'How to Use',
                      accentColor: AppColors.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StepRow(
                            step: '1',
                            text:
                                'Tap "Take Photo" to capture a fresh leaf image using your camera, or "Choose from Gallery".',
                          ),
                          SizedBox(height: 10),
                          _StepRow(
                            step: '2',
                            text:
                                'Review the image preview to verify the leaf is sharply focused and fully visible.',
                          ),
                          SizedBox(height: 10),
                          _StepRow(
                            step: '3',
                            text:
                                'Tap "Analyze Leaf" to submit the image to the CNN classification model.',
                          ),
                          SizedBox(height: 10),
                          _StepRow(
                            step: '4',
                            text:
                                'View the predicted variety, confidence rating, and full class probability breakdown.',
                          ),
                        ],
                      ),
                    ),

                    // ── Image capture guidelines ───────────────────────────
                    _SectionCard(
                      icon: Icons.camera_enhance_outlined,
                      title: 'Image Capture Guidelines',
                      accentColor: AppColors.emeraldVivid,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AppStrings.captureGuidelines
                            .map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.emeraldLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // ── Supported formats ──────────────────────────────────
                    _SectionCard(
                      icon: Icons.image_outlined,
                      title: 'Supported Image Formats',
                      accentColor: AppColors.primaryLight,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.acceptedExtensions
                            .map(
                              (ext) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldSubtle,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderEmerald,
                                  ),
                                ),
                                child: Text(
                                  ext.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // ── Classification limitation ──────────────────────────
                    _SectionCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Classification Limitation',
                      accentColor: AppColors.amberAccent,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.amberLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.amberAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'The classification result is intended as a supplementary '
                          'identification aid and should not be treated as a definitive '
                          'agronomic identification. Results may be affected by image '
                          'quality, lighting conditions, leaf developmental stage, disease, '
                          'physical damage, and varieties not represented in the training dataset.',
                          style: TextStyle(
                            color: Color(0xFF78350F),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),

                    // ── CNN model info ─────────────────────────────────────
                    const _SectionCard(
                      icon: Icons.memory_rounded,
                      title: 'Model Information',
                      accentColor: AppColors.primary,
                      child: _InfoTable(rows: [
                        _InfoRow(
                            label: 'Architecture', value: 'EfficientNetB0'),
                        _InfoRow(
                            label: 'Training strategy',
                            value: 'Transfer learning + fine-tuning'),
                        _InfoRow(
                            label: 'Input size', value: '224 × 224 pixels'),
                        _InfoRow(
                            label: 'Task',
                            value: 'Multi-class leaf classification'),
                      ]),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2EBE4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.text});
  final String step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final r = entry.value;
        final isEven = index % 2 == 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isEven ? AppColors.surfaceSubtle : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 135,
                child: Text(
                  r.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  r.value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
}
