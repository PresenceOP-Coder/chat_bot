import 'package:flutter/material.dart';
import 'package:like_gemini/core/responsive.dart';
import 'package:like_gemini/core/theme.dart';
import 'package:like_gemini/features/landing/widgets/interactive_background.dart';
import 'package:like_gemini/features/chat/models/chat_message.dart';
import 'package:like_gemini/features/chat/services/gemini_service.dart';
import 'package:like_gemini/features/chat/widgets/sidebar.dart';
import 'package:like_gemini/features/chat/widgets/chat_viewport.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GeminiService _geminiService = GeminiService();

  // ── Chat state ────────────────────────────────────────────
  final List<String> _chatSessions = ['Main Session'];
  int _activeSessionIndex = 0;
  final Map<int, List<ChatMessage>> _sessionMessages = {0: []};

  bool _isLoading = false;
  bool _isSidebarOpen = true;

  // ── API key (user can override baked-in key via Settings) ─
  String _apiKey = '';
  bool _isDemoMode = false;

  // ── Theme state ───────────────────────────────────────────
  // true = dark mode (matches "Daily paper mode" OFF)
  // false = light mode / warm paper (matches "Daily paper mode" ON)
  bool _isDark = false;

  // ── Session handlers ──────────────────────────────────────
  void _handleNewChat() {
    setState(() {
      final title = 'Session ${_chatSessions.length + 1}';
      _chatSessions.add(title);
      _activeSessionIndex = _chatSessions.length - 1;
      _sessionMessages[_activeSessionIndex] = [];
    });
    if (context.isMobile) Navigator.of(context).pop();
  }

  void _handleSessionSelected(int index) {
    setState(() => _activeSessionIndex = index);
    if (context.isMobile) Navigator.of(context).pop();
  }

  void _handleApiKeyChanged(String key) => setState(() => _apiKey = key);
  void _handleDemoModeChanged(bool val) => setState(() => _isDemoMode = val);

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  void _toggleSidebar() {
    if (context.isMobile) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      setState(() => _isSidebarOpen = !_isSidebarOpen);
    }
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> _handleSendMessage(String text) async {
    final int session = _activeSessionIndex;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _sessionMessages[session]!.add(userMsg);
      _isLoading = true;
    });

    try {
      final responseText = await _geminiService.getResponse(
        text,
        overrideKey: _apiKey.isNotEmpty ? _apiKey : null,
        useDemoMode: _isDemoMode,
      );

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (mounted && _activeSessionIndex == session) {
        setState(() {
          _sessionMessages[session]!.add(botMsg);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _activeSessionIndex == session) {
        setState(() {
          _sessionMessages[session]!.add(ChatMessage(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            text: 'System Error: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final List<ChatMessage> currentMessages =
        _sessionMessages[_activeSessionIndex] ?? [];

    final sidebarWidget = Sidebar(
      chatSessions: _chatSessions,
      activeSessionIndex: _activeSessionIndex,
      onSessionSelected: _handleSessionSelected,
      onNewChat: _handleNewChat,
      isDark: _isDark,
      onToggleTheme: _toggleTheme,
      apiKey: _apiKey,
      onApiKeyChanged: _handleApiKeyChanged,
      isDemoMode: _isDemoMode,
      onDemoModeChanged: _handleDemoModeChanged,
    );

    return Theme(
      // Apply the correct ThemeData branch for child Material widgets
      data: _isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            _isDark ? AppTheme.bgDark : AppTheme.bgLight,
        drawer: isMobile
            ? Sidebar(
                chatSessions: _chatSessions,
                activeSessionIndex: _activeSessionIndex,
                onSessionSelected: _handleSessionSelected,
                onNewChat: _handleNewChat,
                isDark: _isDark,
                onToggleTheme: _toggleTheme,
                apiKey: _apiKey,
                onApiKeyChanged: _handleApiKeyChanged,
                isDemoMode: _isDemoMode,
                onDemoModeChanged: _handleDemoModeChanged,
                isMobile: true,
              )
            : null,
        body: Stack(
          children: [
            // Particle network background (very subtle in paper mode)
            Positioned.fill(
              child: Opacity(
                // Dim the cyber-looking particles in light mode for the
                // editorial look; keep visible in dark mode.
                opacity: _isDark ? 1.0 : 0.06,
                child: const InteractiveBackground(),
              ),
            ),

            // Main UI
            Positioned.fill(
              child: Row(
                children: [
                  // Sidebar (desktop)
                  if (!isMobile)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: _isSidebarOpen ? 240.0 : 0.0,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                          width: 240.0,
                          child: sidebarWidget,
                        ),
                      ),
                    ),

                  // Chat + right panel
                  Expanded(
                    child: ChatViewport(
                      messages: currentMessages,
                      isLoading: _isLoading,
                      isDark: _isDark,
                      onSendMessage: _handleSendMessage,
                      onToggleSidebar: _toggleSidebar,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
