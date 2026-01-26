import 'package:flutter/material.dart';
import 'analytics_test_widget.dart';

/// Standalone Test-App für Analytics
///
/// Run mit: flutter run -t lib/src/tools/test_analytics_main.dart
void main() {
  runApp(const AnalyticsTestApp());
}

class AnalyticsTestApp extends StatelessWidget {
  const AnalyticsTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AnalyticsTestWidget(),
    );
  }
}
