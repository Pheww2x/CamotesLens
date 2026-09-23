// test/models/classification_result_test.dart
// ---------------------------------------------------------------------------
// Unit tests for ClassificationResult parsing and derived helpers.
// ---------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:camotes_lens/models/classification_result.dart';

void main() {
  group('ClassificationResult.fromJson', () {
    test('parses a well-formed success response', () {
      final json = {
        'success': true,
        'predicted_class': 'PSBSP-1',
        'confidence': 0.94,
        'probabilities': {
          'PSBSP-1': 0.94,
          'PSBSP-2': 0.03,
          'PSBSP-3': 0.02,
          'PSBSP-4': 0.01,
        },
      };

      final result = ClassificationResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.predictedClass, 'PSBSP-1');
      expect(result.confidence, closeTo(0.94, 0.0001));
      expect(result.probabilities.length, 4);
    });

    test('sorts probabilities descending', () {
      final json = {
        'success': true,
        'predicted_class': 'PSBSP-3',
        'confidence': 0.80,
        'probabilities': {
          'PSBSP-1': 0.05,
          'PSBSP-2': 0.10,
          'PSBSP-3': 0.80,
          'PSBSP-4': 0.05,
        },
      };

      final result = ClassificationResult.fromJson(json);
      final probs = result.probabilities.values.toList();

      for (var i = 0; i < probs.length - 1; i++) {
        expect(probs[i], greaterThanOrEqualTo(probs[i + 1]));
      }
    });

    test('handles missing optional fields gracefully', () {
      final json = <String, dynamic>{
        'success': null,
        'predicted_class': null,
        'confidence': null,
        'probabilities': null,
      };

      final result = ClassificationResult.fromJson(json);
      expect(result.success, isFalse);
      expect(result.predictedClass, 'Unknown');
      expect(result.confidence, 0.0);
      expect(result.probabilities, isEmpty);
    });

    test('confidencePercent formats correctly', () {
      final result = ClassificationResult.fromJson({
        'success': true,
        'predicted_class': 'PSBSP-1',
        'confidence': 0.9456,
        'probabilities': {'PSBSP-1': 0.9456},
      });

      expect(result.confidencePercent, '94.6%');
    });
  });

  group('ClassificationResult.mock', () {
    test('returns a valid mock with success=true', () {
      final mock = ClassificationResult.mock();
      expect(mock.success, isTrue);
      expect(mock.predictedClass, isNotEmpty);
      expect(mock.confidence, greaterThan(0.0));
      expect(mock.probabilities, isNotEmpty);
    });

    test('mock probabilities sum to approximately 1.0', () {
      final mock = ClassificationResult.mock();
      final sum = mock.probabilities.values.reduce((a, b) => a + b);
      expect(sum, closeTo(1.0, 0.01));
    });
  });

  group('ClassificationResult.toJson', () {
    test('round-trips successfully', () {
      final original = ClassificationResult.fromJson({
        'success': true,
        'predicted_class': 'PSBSP-2',
        'confidence': 0.75,
        'probabilities': {'PSBSP-1': 0.25, 'PSBSP-2': 0.75},
      });

      final json = original.toJson();
      expect(json['success'], isTrue);
      expect(json['predicted_class'], 'PSBSP-2');
    });
  });
}
