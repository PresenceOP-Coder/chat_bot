import 'package:flutter/material.dart';
import '../widgets/interactive_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveBackground(),
          ),
          Center(
            child: Text('Nova AI Landing Page'),
          ),
        ],
      ),
    );
  }
}
