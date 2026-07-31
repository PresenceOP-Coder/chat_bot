class AppConstants {
  AppConstants._(); // prevent instantiation

  /// Gemini API key — injected via --dart-define=GEMINI_API_KEY=your_key or empty by default.
  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // Layout constants
  static const double sidebarWidth = 240.0;
  static const double rightPanelWidth = 260.0;
  static const double maxChatWidth = 760.0;
}
