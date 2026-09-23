// lib/main.dart
// ---------------------------------------------------------------------------
// Application entry point.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent field-use experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CamotesLensApp());
}
