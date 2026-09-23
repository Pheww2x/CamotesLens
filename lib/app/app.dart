// lib/app/app.dart
// ---------------------------------------------------------------------------
// Root application widget.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../screens/main_navigation_screen.dart';
import '../utils/constants.dart';
import 'theme.dart';

class CamotesLensApp extends StatelessWidget {
  const CamotesLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigationScreen(),
    );
  }
}
