// lib/models/classification_result.dart
// ---------------------------------------------------------------------------
// Strongly-typed model for the API classification response.
// ---------------------------------------------------------------------------

/// Represents the result returned by POST /predict.
class ClassificationResult {
  /// Whether the API call was successful.
  final bool success;

  /// The name of the predicted sweet potato variety.
  final String predictedClass;

  /// Confidence of the top prediction as a value in [0.0, 1.0].
  final double confidence;

  /// Full softmax probability distribution keyed by variety name.
  /// Entries are sorted descending by probability.
  final Map<String, double> probabilities;

  const ClassificationResult({
    required this.success,
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
  });

  // ── Factory constructors ────────────────────────────────────────────────

  /// Parse a successful JSON response from the API.
  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    final rawProbs = json['probabilities'] as Map<String, dynamic>? ?? {};

    // Convert to typed map and sort descending by probability
    final sortedProbs = Map.fromEntries(
      rawProbs.entries
          .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return ClassificationResult(
      success: (json['success'] as bool?) ?? false,
      predictedClass: (json['predicted_class'] as String?) ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: sortedProbs,
    );
  }

  /// Build a mock result for UI development / testing without a live server.
  factory ClassificationResult.mock() {
    return const ClassificationResult(
      success: true,
      predictedClass: 'NSIC SP-37',
      confidence: 0.94,
      probabilities: {
        'NSIC SP-37': 0.94,
        'STOKE PURPLE': 0.03,
        'VSP-7 (V20-429)': 0.02,
        'VSp-6 (V20-209)': 0.01,
      },
    );
  }

  // ── Derived helpers ─────────────────────────────────────────────────────

  /// Confidence expressed as a percentage string, e.g. "94%".
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  // ── Serialisation ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'success': success,
        'predicted_class': predictedClass,
        'confidence': confidence,
        'probabilities': probabilities,
      };

  @override
  String toString() =>
      'ClassificationResult(predicted=$predictedClass, confidence=$confidence)';
}
