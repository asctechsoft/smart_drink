import 'package:flutter/material.dart';
import 'presentation/screen_splash/screen_splash.dart';
import 'presentation/screens_onboarding/screens_onboarding.dart';
import 'presentation/screen_home/screen_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Drink Water',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const ScreenSplash(),
        '/onboarding': (context) => const ScreensOnboarding(),
        '/home': (context) => const ScreenHome(),
      },
    );
  }
}
