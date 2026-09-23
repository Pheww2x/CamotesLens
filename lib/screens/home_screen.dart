// lib/screens/home_screen.dart
// ---------------------------------------------------------------------------
// Landing screen — agricultural-themed entry point with rich emerald styling.
// ---------------------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../app/theme.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../widgets/image_picker_card.dart';
import 'about_screen.dart';
import 'image_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ImageService _imageService = ImageService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Image source actions ──────────────────────────────────────────────

  Future<void> _onTakePhoto() async {
    await _pickImage(() => _imageService.captureFromCamera());
  }

  Future<void> _onChooseFromGallery() async {
    await _pickImage(() => _imageService.pickFromGallery());
  }

  Future<void> _pickImage(Future<File?> Function() pickFn) async {
    try {
      final file = await pickFn();
      if (file == null || !mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imageFile: file),
        ),
      );
    } on PermissionPermanentlyDeniedException catch (e) {
      _showPermissionDialog(e.message, offerSettings: true);
    } on PermissionDeniedException catch (e) {
      _showPermissionDialog(e.message);
    } catch (_) {
      _showSnackbar(AppStrings.errorInvalidImage);
    }
  }

  void _showPermissionDialog(String message, {bool offerSettings = false}) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.lock_outline, color: AppColors.primary),
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          if (offerSettings)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ph.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero header with multi-stop gradient ──────────────────
            const _HeroHeader(),

            // ── Animated Content ──────────────────────────────────────
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.emeraldVivid,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Select Image Source',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    ImagePickerCard(
                      icon: Icons.camera_alt_rounded,
                      label: AppStrings.takePhoto,
                      subtitle:
                          'Use your camera to capture a fresh leaf image in natural light.',
                      onTap: _onTakePhoto,
                    ),

                    ImagePickerCard(
                      icon: Icons.photo_library_rounded,
                      label: AppStrings.chooseFromGallery,
                      subtitle:
                          'Select an existing high-clarity leaf image from your photos.',
                      onTap: _onChooseFromGallery,
                    ),

                    // ── Capture tips ────────────────────────────────────
                    const SizedBox(height: 12),
                    const _QuickTipsCard(),

                    // ── About button ────────────────────────────────────
                    const SizedBox(height: 16),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _onAbout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.borderEmerald, width: 1.4),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(140, 42),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        icon: const Icon(Icons.info_outline_rounded,
                            size: 18, color: AppColors.primary),
                        label: const Text(
                          AppStrings.about,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _HeroHeader extends StatefulWidget {
  const _HeroHeader();

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x350D6B3F),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, topPadding + 28, 24, 38),
      child: Column(
        children: [
          // Glowing brand logo
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emeraldMint.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/camotes_lens_logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Brand Title
          const Text(
            'CamotesLens',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),

          // App Name Badge / Pill (matches test requirement find.text(AppConstants.appName))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: const Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE2F8EB),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            AppConstants.appSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  const _QuickTipsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Quick Tips for Best Results',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...AppStrings.captureGuidelines.take(4).map(
                  (tip) => _TipRow(tip: tip),
                ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
