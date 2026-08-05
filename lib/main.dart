import 'package:flutter/material.dart';

void main() {
  runApp(const FitStartApp());
}

class FitStartApp extends StatelessWidget {
  const FitStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FitStart',
      home: Scaffold(
        body: Center(
          child: Text('FitStart — project structure ready'),
        ),
      ),
    );
  }
}
