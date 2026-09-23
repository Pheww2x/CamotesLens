// test/widget_test.dart
// ---------------------------------------------------------------------------
// Basic smoke tests for CamotesLens screens using mock data.
// ---------------------------------------------------------------------------

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camotes_lens/app/app.dart';
import 'package:camotes_lens/models/classification_result.dart';
import 'package:camotes_lens/screens/result_screen.dart';
import 'package:camotes_lens/screens/about_screen.dart';
import 'package:camotes_lens/utils/constants.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders app name and action buttons', (tester) async {
      await tester.pumpWidget(const CamotesLensApp());

      expect(find.text(AppConstants.appName), findsWidgets);
      expect(find.text(AppStrings.takePhoto), findsOneWidget);
      expect(find.text(AppStrings.chooseFromGallery), findsOneWidget);
      expect(find.text(AppStrings.about), findsOneWidget);
    });
  });

  group('AboutScreen', () {
    testWidgets('renders classification limitation section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Classification Limitation'), findsOneWidget);
    });

    testWidgets('renders how to use section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('How to Use'), findsOneWidget);
    });

    testWidgets('renders model information section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Model Information'), findsOneWidget);
      expect(find.text('EfficientNetB0'), findsOneWidget);
    });
  });

  group('ResultScreen with mock data', () {
    late File tempFile;

    setUpAll(() async {
      // Write a minimal JPEG to a real temp path so Image.file doesn't crash
      tempFile = File('${Directory.systemTemp.path}/camotes_test_leaf.jpg');
      await tempFile.writeAsBytes(_minimalJpegBytes());
    });

    testWidgets('shows classification result title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: ClassificationResult.mock(),
          imageFile: tempFile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.classificationResult), findsOneWidget);
    });

    testWidgets('shows predicted variety label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: ClassificationResult.mock(),
          imageFile: tempFile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.predictedVariety), findsOneWidget);
    });

    testWidgets('shows confidence label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: ClassificationResult.mock(),
          imageFile: tempFile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.confidence), findsOneWidget);
    });

    testWidgets('shows class probabilities label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: ClassificationResult.mock(),
          imageFile: tempFile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.classProbabilities), findsOneWidget);
    });

    testWidgets('shows classify another leaf button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ResultScreen(
          result: ClassificationResult.mock(),
          imageFile: tempFile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.classifyAnotherLeaf), findsOneWidget);
    });
  });
}

/// Returns a minimal valid JPEG byte sequence (1×1 white pixel).
Uint8List _minimalJpegBytes() {
  return Uint8List.fromList([
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
    0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xD9,
  ]);
}
