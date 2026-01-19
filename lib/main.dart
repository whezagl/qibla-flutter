import 'package:flutter/material.dart';
import 'pages/compass_page.dart';

void main() {
  runApp(const QiblaCompassApp());
}

/// The main application widget for the Qibla Compass app.
class QiblaCompassApp extends StatelessWidget {
  /// Creates the main app widget.
  const QiblaCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qibla Compass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CompassPage(),
    );
  }
}
