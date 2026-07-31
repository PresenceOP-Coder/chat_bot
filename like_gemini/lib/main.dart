import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/chat/screens/chat_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Canvas — Editorial AI Workspace',
      debugShowCheckedModeBanner: false,
      // Default to light (paper) mode — the user can toggle inside the app
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const ChatScreen(),
    );
  }
}
