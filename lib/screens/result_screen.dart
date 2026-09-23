// lib/screens/result_screen.dart
// ---------------------------------------------------------------------------
// Displays classification result: predicted variety, confidence, probabilities.
// Styled with emerald accents, animated entrance, and premium data presentation.
// ---------------------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/classification_result.dart';
import '../models/classification_history.dart';
import '../models/variety_info.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';
import '../widgets/confidence_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/probability_list.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  final ClassificationResult result;
  final File imageFile;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final _historyService = HistoryService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    await _historyService.add(
      ClassificationHistory.fromResult(
        result: widget.result,
        imagePath: widget.imageFile.path,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.classificationResult,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Saved result' : 'Save result',
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
            onPressed: () async {
              final items = await _historyService.load();
              if (items.isEmpty || !mounted) return;
              await _historyService.toggleFavorite(items.first.id);
              setState(() => _isFavorite = !_isFavorite);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Leaf thumbnail with gradient frame ────────────────
                  Container(
                    height: 210,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.borderEmerald,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(widget.imageFile, fit: BoxFit.cover),
                          // Subtle dark gradient overlay for label legibility
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.70),
                                    Colors.black.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.emeraldVivid,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.eco_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Submitted leaf image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Confidence card ───────────────────────────────────
                  ConfidenceCard(result: widget.result),

                  _VarietyInformation(
                      varietyName: widget.result.predictedClass),

                  // ── Probability list ──────────────────────────────────
                  ProbabilityList(
                    probabilities: widget.result.probabilities,
                    predictedClass: widget.result.predictedClass,
                  ),

                  // ── Disclaimer ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2EBE4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.classificationDisclaimer,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Action buttons ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: PrimaryButton(
                      label: AppStrings.classifyAnotherLeaf,
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.borderEmerald, width: 1.5),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Text(
                        AppStrings.backToHome,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
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

class _VarietyInformation extends StatelessWidget {
  const _VarietyInformation({required this.varietyName});
  final String varietyName;

  @override
  Widget build(BuildContext context) {
    final matches =
        supportedVarieties.where((item) => item.name == varietyName);
    if (matches.isEmpty) return const SizedBox.shrink();
    final variety = matches.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$varietyName reference',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(variety.leafCharacteristics),
          const SizedBox(height: 8),
          Text('Common uses: ${variety.commonUses}'),
          const SizedBox(height: 8),
          Text('Growing: ${variety.growingInformation}'),
        ]),
      ),
    );
  }
}
