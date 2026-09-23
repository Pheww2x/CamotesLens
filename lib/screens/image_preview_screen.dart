// lib/screens/image_preview_screen.dart
// ---------------------------------------------------------------------------
// Shows the selected/captured image with Analyze / Retake / Choose Another.
// Features emerald framing, glassmorphic notice, and gradient primary button.
// ---------------------------------------------------------------------------

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../app/theme.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../widgets/primary_button.dart';
import 'result_screen.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key, required this.imageFile});

  final File imageFile;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late File _currentImage;
  bool _isAnalyzing = false;
  String? _errorMessage;
  String? _qualityMessage;

  final ApiService _apiService = ApiService();
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
    _checkImageQuality();
  }

  Future<void> _checkImageQuality() async {
    try {
      final size = await _currentImage.length();
      if (!mounted) return;
      setState(() {
        _qualityMessage = size == 0
            ? 'This image is empty. Please capture a clear sweet potato leaf.'
            : size > AppConstants.maxUploadSizeBytes
                ? 'This image is too large. Please choose an image smaller than 10 MB.'
                : null;
      });
    } catch (_) {
      if (mounted)
        setState(() => _qualityMessage = AppStrings.errorInvalidImage);
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────

  Future<void> _onAnalyze() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.classifyLeaf(_currentImage);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(result: result, imageFile: _currentImage),
        ),
      );
    } on ApiException catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = AppStrings.errorServerError;
      });
    }
  }

  Future<void> _onRetake() async {
    await _replaceImage(() => _imageService.captureFromCamera());
  }

  Future<void> _onChooseAnother() async {
    await _replaceImage(() => _imageService.pickFromGallery());
  }

  Future<void> _onCropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _currentImage.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 95,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Leaf Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.emeraldVivid,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Leaf Image'),
        ],
      );

      if (!mounted || croppedFile == null) return;
      setState(() {
        _currentImage = File(croppedFile.path);
        _errorMessage = null;
      });
      _checkImageQuality();
    } catch (_) {
      _showSnackbar(AppStrings.errorInvalidImage);
    }
  }

  Future<void> _replaceImage(Future<File?> Function() pickFn) async {
    try {
      final file = await pickFn();
      if (file == null || !mounted) return;
      setState(() {
        _currentImage = file;
        _errorMessage = null;
      });
      _checkImageQuality();
    } on PermissionPermanentlyDeniedException catch (e) {
      _showSnackbar(e.message);
    } on PermissionDeniedException catch (e) {
      _showSnackbar(e.message);
    } catch (_) {
      _showSnackbar(AppStrings.errorInvalidImage);
    }
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

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Leaf Preview',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: _isAnalyzing ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image preview container ───────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.borderEmerald,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        _currentImage,
                        fit: BoxFit.contain,
                      ),
                      if (_isAnalyzing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.emeraldVivid
                                            .withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Analyzing leaf features...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
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
            ),

            // ── Error banner ──────────────────────────────────────────
            if (_qualityMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.amberLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.amberAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(_qualityMessage!,
                            style: const TextStyle(
                                color: Color(0xFF78350F), fontSize: 13))),
                  ]),
                ),
              ),

            if (_errorMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Disclaimer notice ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.classificationDisclaimer,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Action buttons ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
              child: PrimaryButton(
                label: AppStrings.analyzeLeaf,
                icon: Icons.biotech_rounded,
                onPressed: _onAnalyze,
                isLoading: _isAnalyzing,
                enabled: !_isAnalyzing && _qualityMessage == null,
              ),
            ),

            if (!_isAnalyzing) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                child: OutlinedButton.icon(
                  onPressed: _onCropImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                        color: AppColors.borderEmerald, width: 1.5),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.crop, size: 18),
                  label: const Text(
                    'Crop image',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onRetake,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.borderEmerald, width: 1.5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text(
                          AppStrings.retake,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onChooseAnother,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.borderEmerald, width: 1.5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        icon:
                            const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text(
                          AppStrings.chooseAnother,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
