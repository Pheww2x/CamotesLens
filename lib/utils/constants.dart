// lib/utils/constants.dart
// ---------------------------------------------------------------------------
// Application-wide constants for CamotesLens.
// ---------------------------------------------------------------------------

class ApiConfig {
  ApiConfig._();

  /// Base URL of the CamotesLens Flask API.
  ///
  /// • Android Emulator  →  use 10.0.2.2 (maps to host loopback)
  /// • Physical Device   →  replace with the host machine's LAN IP address,
  ///                        e.g. "http://192.168.1.100:5000"
  static const String baseUrl = 'http://10.0.2.2:5000';

  static const String predictEndpoint = '/predict';
  static const String healthEndpoint = '/health';

  /// Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Sweet Potato Variety Classifier';
  static const String appSubtitle =
      'Identify sweet potato varieties through leaf image analysis.';
  static const String appVersion = '1.0.0';

  /// Classification confidence threshold below which the low-confidence
  /// warning is displayed. Value is in [0.0, 1.0].
  static const double lowConfidenceThreshold = 0.70;

  /// Accepted image extensions communicated to the image picker.
  static const List<String> acceptedExtensions = ['jpg', 'jpeg', 'png'];

  /// Maximum image upload size (10 MB) — enforced server-side; surfaced for UI.
  static const int maxUploadSizeBytes = 10 * 1024 * 1024;
}

class AppStrings {
  AppStrings._();

  // ── Actions ──────────────────────────────────────────────────────────────
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String analyzeLeaf = 'Analyze Leaf';
  static const String retake = 'Retake';
  static const String chooseAnother = 'Choose Another';
  static const String classifyAnotherLeaf = 'Classify Another Leaf';
  static const String backToHome = 'Back to Home';
  static const String about = 'About';
  static const String home = 'Home';
  static const String capture = 'Capture';
  static const String history = 'History';
  static const String varieties = 'Varieties';
  static const String profile = 'Profile';

  // ── Result labels ────────────────────────────────────────────────────────
  static const String classificationResult = 'Classification Result';
  static const String predictedVariety = 'Predicted Variety';
  static const String confidence = 'Confidence';
  static const String classProbabilities = 'Class Probabilities';
  static const String unableToIdentify =
      'Unable to confidently identify the variety. Please capture another clear leaf image.';

  // ── Warnings & notices ───────────────────────────────────────────────────
  static const String lowConfidenceWarning =
      'The model has low confidence in this classification. '
      'Consider capturing another clear image of the leaf or verifying '
      'the result with a qualified agricultural expert.';

  static const String classificationDisclaimer =
      'This classification result is an identification aid only and '
      'should not be treated as a definitive agronomic identification.';

  // ── Errors ───────────────────────────────────────────────────────────────
  static const String errorNoInternet =
      'Unable to connect to the classification server. '
      'Please check your internet connection and try again.';

  static const String errorApiUnavailable =
      'The classification server is currently unavailable. '
      'Please try again later.';

  static const String errorTimeout =
      'The request timed out. Please check your connection and try again.';

  static const String errorInvalidImage =
      'The selected image could not be processed. '
      'Please choose a valid JPEG or PNG image.';

  static const String errorServerError =
      'The server encountered an error while processing the image. '
      'Please try again with a different image.';

  static const String errorMalformedResponse =
      'An unexpected response was received from the server. '
      'Please try again.';

  static const String errorCameraPermission =
      'Camera permission is required to capture leaf images. '
      'Please grant camera access in your device settings.';

  static const String errorGalleryPermission =
      'Storage permission is required to select images from the gallery. '
      'Please grant storage access in your device settings.';

  // ── Image capture guidelines ─────────────────────────────────────────────
  static const List<String> captureGuidelines = [
    'Capture the entire leaf within the frame.',
    'Keep the leaf clearly visible and in focus.',
    'Avoid excessive blur or camera shake.',
    'Avoid heavy shadows or uneven lighting.',
    'Use sufficient, even lighting.',
    'Avoid objects covering or overlapping the leaf.',
    'Place the leaf against a relatively neutral background.',
    'Ensure the leaf is facing the camera directly.',
  ];
}
