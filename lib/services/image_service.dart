// lib/services/image_service.dart
// ---------------------------------------------------------------------------
// Wraps image_picker and permission_handler for camera/gallery access.
// ---------------------------------------------------------------------------

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

class PermissionDeniedException implements Exception {
  const PermissionDeniedException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PermissionPermanentlyDeniedException implements Exception {
  const PermissionPermanentlyDeniedException(this.message);
  final String message;
  @override
  String toString() => message;
}

// ---------------------------------------------------------------------------
// ImageService
// ---------------------------------------------------------------------------

class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Launch the device camera and return the captured [File], or null if the
  /// user cancelled.
  ///
  /// Throws [PermissionDeniedException] or [PermissionPermanentlyDeniedException]
  /// if camera access is not granted.
  Future<File?> captureFromCamera() async {
    await _assertCameraPermission();

    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
      preferredCameraDevice: CameraDevice.rear,
    );

    return xFile == null ? null : File(xFile.path);
  }

  /// Open the device gallery and return the selected [File], or null if the
  /// user cancelled.
  ///
  /// Throws [PermissionDeniedException] or [PermissionPermanentlyDeniedException]
  /// if storage access is not granted.
  Future<File?> pickFromGallery() async {
    await _assertGalleryPermission();

    final XFile? xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    return xFile == null ? null : File(xFile.path);
  }

  // ── Permission helpers ─────────────────────────────────────────────────

  Future<void> _assertCameraPermission() async {
    final status = await Permission.camera.request();
    _checkStatus(status, AppStrings.errorCameraPermission);
  }

  Future<void> _assertGalleryPermission() async {
    // Android 13+ uses READ_MEDIA_IMAGES; older versions use READ_EXTERNAL_STORAGE.
    final status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      // Fall back to storage permission for older Android versions
      final storageStatus = await Permission.storage.request();
      _checkStatus(storageStatus, AppStrings.errorGalleryPermission);
      return;
    }
    _checkStatus(status, AppStrings.errorGalleryPermission);
  }

  void _checkStatus(PermissionStatus status, String baseMessage) {
    if (status.isPermanentlyDenied) {
      throw PermissionPermanentlyDeniedException(
        '$baseMessage\n\nPlease open Settings and enable the permission manually.',
      );
    }
    if (status.isDenied) {
      throw PermissionDeniedException(baseMessage);
    }
  }
}
