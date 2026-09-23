import 'dart:convert';

import 'classification_result.dart';

class ClassificationHistory {
  const ClassificationHistory({
    required this.id,
    required this.imagePath,
    required this.predictedClass,
    required this.confidence,
    required this.createdAt,
    this.isFavorite = false,
    this.isSynced = false,
  });

  final String id;
  final String imagePath;
  final String predictedClass;
  final double confidence;
  final DateTime createdAt;
  final bool isFavorite;
  final bool isSynced;

  factory ClassificationHistory.fromResult({
    required ClassificationResult result,
    required String imagePath,
  }) {
    final now = DateTime.now();
    return ClassificationHistory(
      id: '${now.microsecondsSinceEpoch}_$imagePath',
      imagePath: imagePath,
      predictedClass: result.predictedClass,
      confidence: result.confidence,
      createdAt: now,
    );
  }

  factory ClassificationHistory.fromJson(Map<String, dynamic> json) {
    return ClassificationHistory(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      predictedClass: json['predictedClass'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'predictedClass': predictedClass,
        'confidence': confidence,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
        'isSynced': isSynced,
      };

  String encode() => jsonEncode(toJson());

  ClassificationHistory copyWith({bool? isFavorite, bool? isSynced}) {
    return ClassificationHistory(
      id: id,
      imagePath: imagePath,
      predictedClass: predictedClass,
      confidence: confidence,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
