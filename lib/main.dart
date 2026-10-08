import 'package:flutter/material.dart';

import 'app_root.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SlaTrackerApp());
}

class SlaTrackerApp extends StatelessWidget {
  const SlaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project & SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AppRoot(),
    );
  }
}
