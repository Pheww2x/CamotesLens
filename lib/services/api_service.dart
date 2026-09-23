// lib/services/api_service.dart
// ---------------------------------------------------------------------------
// Handles all HTTP communication with the CamotesLens Flask API.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/classification_result.dart';
import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// Application-level exception hierarchy
// ---------------------------------------------------------------------------

/// Base class for all API-level errors surfaced to the UI.
abstract class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class NoInternetException extends ApiException {
  const NoInternetException() : super(AppStrings.errorNoInternet);
}

class TimeoutException extends ApiException {
  const TimeoutException() : super(AppStrings.errorTimeout);
}

class ApiUnavailableException extends ApiException {
  const ApiUnavailableException([String? detail])
      : super(detail ?? AppStrings.errorApiUnavailable);
}

class InvalidImageException extends ApiException {
  const InvalidImageException([String? detail])
      : super(detail ?? AppStrings.errorInvalidImage);
}

class LowConfidenceException extends ApiException {
  const LowConfidenceException([String? detail])
      : super(detail ?? AppStrings.unableToIdentify);
}

class ServerErrorException extends ApiException {
  const ServerErrorException([String? detail])
      : super(detail ?? AppStrings.errorServerError);
}

class MalformedResponseException extends ApiException {
  const MalformedResponseException() : super(AppStrings.errorMalformedResponse);
}

// ---------------------------------------------------------------------------
// ApiService
// ---------------------------------------------------------------------------

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Send [imageFile] to POST /predict and return a [ClassificationResult].
  ///
  /// Throws a typed [ApiException] subclass on any error so the UI layer
  /// only needs to handle one exception hierarchy.
  Future<ClassificationResult> classifyLeaf(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.predictEndpoint}');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    http.StreamedResponse streamedResponse;

    try {
      streamedResponse =
          await _client.send(request).timeout(ApiConfig.connectionTimeout);
    } on SocketException {
      throw const NoInternetException();
    } on http.ClientException {
      throw const ApiUnavailableException();
    } on TimeoutException {
      throw const TimeoutException();
    }

    final responseBody = await http.Response.fromStream(streamedResponse)
        .timeout(ApiConfig.receiveTimeout)
        .catchError((_) => throw const TimeoutException());

    return _parseResponse(responseBody);
  }

  // ── Private helpers ────────────────────────────────────────────────────

  ClassificationResult _parseResponse(http.Response response) {
    // HTTP-level errors
    if (response.statusCode == 400) {
      final body = _tryDecodeJson(response.body);
      final errorMsg = body?['error'] as String?;
      throw InvalidImageException(errorMsg);
    }

    if (response.statusCode == 413) {
      throw const InvalidImageException(
        'The image file is too large (maximum 10 MB).',
      );
    }

    if (response.statusCode == 422) {
      final body = _tryDecodeJson(response.body);
      throw LowConfidenceException(body?['error'] as String?);
    }

    if (response.statusCode >= 500) {
      final body = _tryDecodeJson(response.body);
      final errorMsg = body?['error'] as String?;
      throw ServerErrorException(errorMsg);
    }

    if (response.statusCode != 200) {
      throw ApiUnavailableException(
        'Unexpected server response (HTTP ${response.statusCode}).',
      );
    }

    // Parse JSON body
    final Map<String, dynamic>? json = _tryDecodeJson(response.body);
    if (json == null) throw const MalformedResponseException();

    final success = json['success'] as bool?;
    if (success == false) {
      final msg = json['error'] as String? ?? AppStrings.errorServerError;
      throw ServerErrorException(msg);
    }

    // Validate required fields are present
    if (!json.containsKey('predicted_class') ||
        !json.containsKey('confidence') ||
        !json.containsKey('probabilities')) {
      throw const MalformedResponseException();
    }

    try {
      return ClassificationResult.fromJson(json);
    } catch (_) {
      throw const MalformedResponseException();
    }
  }

  Map<String, dynamic>? _tryDecodeJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
