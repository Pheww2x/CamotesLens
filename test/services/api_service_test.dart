// test/services/api_service_test.dart
// ---------------------------------------------------------------------------
// Unit tests for ApiService response parsing and error handling.
// Uses a mock HTTP client — no live server required.
// ---------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:camotes_lens/services/api_service.dart';
import 'package:camotes_lens/models/classification_result.dart';

// Minimal stub File replacement so tests don't need a real filesystem path.
import 'dart:io';

File _fakeImageFile() {
  // Create a temp file with a minimal JPEG header so the multipart request
  // can attach it (the mock client won't actually read the bytes).
  final tmp = File('${Directory.systemTemp.path}/test_leaf.jpg');
  tmp.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0]); // JPEG magic bytes
  return tmp;
}

http.Response _jsonResponse(Map<String, dynamic> body, {int status = 200}) {
  return http.Response(jsonEncode(body), status,
      headers: {'content-type': 'application/json'});
}

void main() {
  group('ApiService.classifyLeaf', () {
    test('returns ClassificationResult on HTTP 200 success response', () async {
      final mockClient = MockClient((_) async => _jsonResponse({
            'success': true,
            'predicted_class': 'PSBSP-1',
            'confidence': 0.94,
            'probabilities': {
              'PSBSP-1': 0.94,
              'PSBSP-2': 0.03,
              'PSBSP-3': 0.02,
              'PSBSP-4': 0.01,
            },
          }));

      final service = ApiService(client: mockClient);
      final result = await service.classifyLeaf(_fakeImageFile());

      expect(result, isA<ClassificationResult>());
      expect(result.predictedClass, 'PSBSP-1');
      expect(result.confidence, closeTo(0.94, 0.001));
    });

    test('throws InvalidImageException on HTTP 400', () async {
      final mockClient = MockClient((_) async => _jsonResponse(
            {'success': false, 'error': 'Unsupported file type.'},
            status: 400,
          ));

      final service = ApiService(client: mockClient);
      expect(
        () => service.classifyLeaf(_fakeImageFile()),
        throwsA(isA<InvalidImageException>()),
      );
    });

    test('throws ServerErrorException on HTTP 500', () async {
      final mockClient = MockClient((_) async => _jsonResponse(
            {'success': false, 'error': 'Internal server error.'},
            status: 500,
          ));

      final service = ApiService(client: mockClient);
      expect(
        () => service.classifyLeaf(_fakeImageFile()),
        throwsA(isA<ServerErrorException>()),
      );
    });

    test('throws MalformedResponseException on non-JSON body', () async {
      final mockClient = MockClient(
        (_) async => http.Response('NOT JSON', 200),
      );

      final service = ApiService(client: mockClient);
      expect(
        () => service.classifyLeaf(_fakeImageFile()),
        throwsA(isA<MalformedResponseException>()),
      );
    });

    test('throws MalformedResponseException when required fields missing',
        () async {
      final mockClient = MockClient(
        (_) async => _jsonResponse({'success': true}),
      );

      final service = ApiService(client: mockClient);
      expect(
        () => service.classifyLeaf(_fakeImageFile()),
        throwsA(isA<MalformedResponseException>()),
      );
    });

    test('throws InvalidImageException on HTTP 413', () async {
      final mockClient = MockClient(
        (_) async => _jsonResponse(
          {'success': false, 'error': 'File too large.'},
          status: 413,
        ),
      );

      final service = ApiService(client: mockClient);
      expect(
        () => service.classifyLeaf(_fakeImageFile()),
        throwsA(isA<InvalidImageException>()),
      );
    });
  });
}
