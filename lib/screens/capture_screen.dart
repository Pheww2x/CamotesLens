import 'dart:io';

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import 'image_preview_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _imageService = ImageService();

  Future<void> _pick(Future<File?> Function() action) async {
    try {
      final file = await action();
      if (!mounted || file == null) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ImagePreviewScreen(imageFile: file)));
    } on PermissionPermanentlyDeniedException catch (error) {
      _showMessage(error.message);
    } on PermissionDeniedException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(AppStrings.errorInvalidImage);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.capture)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Text('Position one leaf inside the frame',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            const Text(
                'Use a clear background, even lighting, and keep the entire leaf visible.'),
            const SizedBox(height: 18),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.emeraldMint, width: 2),
              ),
              child: CustomPaint(
                painter: _CaptureGuidePainter(),
                child: const Center(
                    child: Icon(Icons.eco_outlined,
                        size: 74, color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _pick(_imageService.captureFromCamera),
              icon: const Icon(Icons.camera_alt),
              label: const Text(AppStrings.takePhoto),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pick(_imageService.pickFromGallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text(AppStrings.chooseFromGallery),
            ),
            const SizedBox(height: 26),
            const _GuideList(),
          ],
        ),
      ),
    );
  }
}

class _GuideList extends StatelessWidget {
  const _GuideList();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('How to capture',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...const [
            'Place one leaf on a clear background.',
            'Make sure the entire leaf is visible.',
            'Use good lighting and avoid blur.',
            'Keep the camera parallel to the leaf.',
          ].map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      size: 18, color: AppColors.emeraldVivid),
                  const SizedBox(width: 8),
                  Expanded(child: Text(text))
                ]),
              )),
        ]),
      ),
    );
  }
}

class _CaptureGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = RRect.fromRectAndRadius(
        Offset(size.width * .12, size.height * .14) &
            Size(size.width * .76, size.height * .72),
        const Radius.circular(20));
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
