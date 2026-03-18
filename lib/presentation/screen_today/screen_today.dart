import 'package:flutter/material.dart';

class ScreenToday extends StatelessWidget {
  const ScreenToday({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Today Tab', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
