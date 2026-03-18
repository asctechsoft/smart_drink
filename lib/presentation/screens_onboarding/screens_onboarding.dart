import 'package:flutter/material.dart';

class ScreensOnboarding extends StatelessWidget {
  const ScreensOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Onboarding Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
