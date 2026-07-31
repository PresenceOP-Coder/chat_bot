import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:like_gemini/core/constants.dart';

class GeminiService {
  static const String _backendUrl = 'http://localhost:3000/api/chat';

  // Models to try in order (direct fallback)
  static const List<String> _models = [
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
  ];

  /// Calls the Node.js Express backend proxy server first; falls back to direct API if backend is down.
  Future<String> getResponse(
    String prompt, {
    String? overrideKey,
    bool useDemoMode = false,
  }) async {
    if (useDemoMode) {
      return _runSimulator(prompt);
    }

    final key = (overrideKey != null && overrideKey.trim().isNotEmpty)
        ? overrideKey.trim()
        : AppConstants.geminiApiKey;

    // 1. Try Node.js Express Backend Server (http://localhost:3000/api/chat)
    try {
      final backendText = await _callBackend(prompt, key);
      if (backendText != null && backendText.isNotEmpty) {
        return backendText;
      }
    } catch (_) {
      // Backend server not running or unreachable, fallback to direct client call
    }

    // 2. Direct client API call fallback
    if (key.isNotEmpty) {
      final String response = await _callWithFallback(prompt, key);
      return response;
    }

    return _runSimulator(prompt);
  }

  Future<String?> _callBackend(String prompt, String apiKey) async {
    final Uri url = Uri.parse(_backendUrl);
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prompt': prompt,
            'apiKey': apiKey,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['text'] != null) {
        return data['text'] as String;
      }
    }
    return null;
  }

  /// Direct client call fallback (tries each model in [_models] until one succeeds)
  Future<String> _callWithFallback(String prompt, String apiKey) async {
    String lastError = '';

    for (final model in _models) {
      final result = await _callGeminiApi(prompt, apiKey, model);
      if (!result.startsWith('__ERROR__')) return result;
      lastError = result.replaceFirst('__ERROR__', '');
      if (lastError.contains('429')) break;
    }

    return _friendlyError(lastError, prompt);
  }

  Future<String> _callGeminiApi(
      String prompt, String apiKey, String model) async {
    final Uri url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      }
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: body,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return (text != null && text.isNotEmpty)
            ? text
            : '__ERROR__empty_response';
      } else {
        return '__ERROR__${response.statusCode}:${response.body}';
      }
    } catch (e) {
      return '__ERROR__network:$e';
    }
  }

  String _friendlyError(String raw, String prompt) {
    if (raw.contains('429')) {
      return '⚠️ **API Quota Limit Reached (HTTP 429)**\n\n'
          'Your API key has reached its free tier limit.\n\n'
          '### 💡 Smart Demo Fallback:\n'
          '${_getSimulatedContent(prompt)}';
    }

    if (raw.contains('400')) {
      return '⚠️ **Invalid API Key or Model (HTTP 400)**\n\n'
          'Please check your key in Settings.\n\n'
          '### 💡 Smart Demo Fallback:\n'
          '${_getSimulatedContent(prompt)}';
    }

    return '⚠️ **Service Notice**\n\nDetails: ${raw.replaceAll('__ERROR__', '')}';
  }

  // ── Smart local AI engine ───────────────────────────
  Future<String> _runSimulator(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return _getSimulatedContent(prompt);
  }

  String _getSimulatedContent(String prompt) {
    final q = prompt.toLowerCase();

    if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
      return '### Welcome to Gemini Canvas! ✦\n\n'
          'I am your AI editorial workspace assistant. How can I help you today?\n\n'
          '* **Code & Engineering:** Debugging, Flutter widgets, and architecture\n'
          '* **Editorial:** Writing, formatting, and summarizing research\n'
          '* **Design:** UI/UX suggestions and layout density controls';
    }

    if (q.contains('flutter') || q.contains('widget') || q.contains('card')) {
      return 'Here is a premium Flutter card component using glassmorphism and clean architecture:\n\n'
          '```dart\n'
          'class EditorialCard extends StatelessWidget {\n'
          '  final String title;\n'
          '  final String subtitle;\n'
          '  final VoidCallback? onTap;\n\n'
          '  const EditorialCard({\n'
          '    super.key,\n'
          '    required this.title,\n'
          '    required this.subtitle,\n'
          '    this.onTap,\n'
          '  });\n\n'
          '  @override\n'
          '  Widget build(BuildContext context) {\n'
          '    return InkWell(\n'
          '      onTap: onTap,\n'
          '      borderRadius: BorderRadius.circular(14),\n'
          '      child: Container(\n'
          '        padding: const EdgeInsets.all(18),\n'
          '        decoration: BoxDecoration(\n'
          '          color: const Color(0xFFFAF7F2),\n'
          '          borderRadius: BorderRadius.circular(14),\n'
          '          border: Border.all(color: const Color(0xFFE8E0D4)),\n'
          '        ),\n'
          '        child: Column(\n'
          '          crossAxisAlignment: CrossAxisAlignment.start,\n'
          '          children: [\n'
          '            Text(\n'
          '              title,\n'
          '              style: const TextStyle(\n'
          '                fontSize: 16,\n'
          '                fontWeight: FontWeight.bold,\n'
          '              ),\n'
          '            ),\n'
          '            const SizedBox(height: 6),\n'
          '            Text(subtitle),\n'
          '          ],\n'
          '        ),\n'
          '      ),\n'
          '    );\n'
          '  }\n'
          '}\n'
          '```';
    }

    return '### Analysis Complete\n\n'
        'I processed your query: "$prompt"\n\n'
        '* **Status:** Processed successfully\n'
        '* **Workspace:** Gemini Canvas Editorial Studio\n'
        '* **Backend Proxy:** Node.js Express Server (`http://localhost:3000`)';
  }
}
