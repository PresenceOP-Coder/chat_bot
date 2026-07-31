
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_gemini/core/theme.dart';
import 'package:like_gemini/core/responsive.dart';
import 'package:like_gemini/features/chat/models/chat_message.dart';
import 'typing_indicator.dart';

class ChatViewport extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isDark;
  final Function(String) onSendMessage;
  final VoidCallback onToggleSidebar;

  const ChatViewport({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.isDark,
    required this.onSendMessage,
    required this.onToggleSidebar,
  });

  @override
  State<ChatViewport> createState() => _ChatViewportState();
}

class _ChatViewportState extends State<ChatViewport> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll    = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    widget.onSendMessage(t);
    _ctrl.clear();
    _scrollBottom();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isNotEmpty) _scrollBottom();

    final bool isDesktop = context.isDesktop;
    final bg = widget.isDark ? AppTheme.bgDark : AppTheme.bgLight;

    return Container(
      color: bg,
      child: Row(
        children: [
          // ── Main chat area ──────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(isDark: widget.isDark, onMenu: widget.onToggleSidebar,
                  isEmpty: widget.messages.isEmpty),
                Expanded(
                  child: widget.messages.isEmpty
                    ? _WelcomeView(isDark: widget.isDark, onSend: widget.onSendMessage)
                    : _MessageList(
                        messages: widget.messages,
                        isLoading: widget.isLoading,
                        isDark: widget.isDark,
                        scrollController: _scroll,
                      ),
                ),
                _InputBar(
                  ctrl: _ctrl,
                  hasText: _hasText,
                  isDark: widget.isDark,
                  onSend: _send,
                ),
              ],
            ),
          ),

          // ── Right workspace panel (desktop only) ────────
          if (isDesktop)
            _RightPanel(isDark: widget.isDark),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final bool isEmpty;
  final VoidCallback onMenu;
  const _TopBar({required this.isDark, required this.isEmpty, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      child: Row(
        children: [
          _IconBtn(icon: Icons.menu_rounded, isDark: isDark, onTap: onMenu),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface2Dark : AppTheme.amberLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.amberAccent.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.amberAccent),
              const SizedBox(width: 6),
              Text('Editorial AI workspace',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppTheme.amberAccent)),
            ]),
          ),
          const Spacer(),
          if (!isEmpty) ...[
            _ChipBtn(label: 'Focus', isDark: isDark),
            const SizedBox(width: 8),
            _ChipBtn(label: 'Review', isDark: isDark),
          ],
        ],
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  final String label;
  final bool isDark;
  const _ChipBtn({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final prim   = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: prim)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Welcome view
// ─────────────────────────────────────────────────────────────
class _WelcomeView extends StatelessWidget {
  final bool isDark;
  final Function(String) onSend;
  const _WelcomeView({required this.isDark, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final prim = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec  = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ask like a reader,\nanswer like a magazine.',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: context.isMobile ? 30 : 44,
                  height: 1.15, color: prim)),
              const SizedBox(height: 16),
              Text('A Gemini-inspired chat interface — warm tones, ink-like contrast, '
                  'and layered cards that feel precise.',
                style: GoogleFonts.inter(fontSize: 15, color: sec, height: 1.55)),
              const SizedBox(height: 40),

              // Conversation preview card
              _EditorialCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Conversation',
                            style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700, color: prim)),
                          const SizedBox(height: 2),
                          Text('Start your editorial session below.',
                            style: GoogleFonts.inter(fontSize: 12, color: sec)),
                        ]),
                        Row(children: [
                          _ChipBtn(label: 'Focus', isDark: isDark),
                          const SizedBox(width: 8),
                          _ChipBtn(label: 'Review', isDark: isDark),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Suggested prompts section
                    Text('✦  SUGGESTED PROMPTS',
                      style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: sec, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _PromptChip(label: 'Help me debug code', isDark: isDark, onTap: () => onSend('Help me debug code')),
                      _PromptChip(label: 'Summarize research', isDark: isDark, onTap: () => onSend('Summarize research')),
                      _PromptChip(label: 'Write a Flutter widget', isDark: isDark, onTap: () => onSend('Write a Flutter widget')),
                      _PromptChip(label: 'Explain Dart streams', isDark: isDark, onTap: () => onSend('Explain Dart streams')),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Message list
// ─────────────────────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isDark;
  final ScrollController scrollController;

  const _MessageList({
    required this.messages, required this.isLoading,
    required this.isDark, required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == messages.length) return _BotBubble(isDark: isDark, isLoading: true);
        final m = messages[i];
        return m.isUser
          ? _UserBubble(text: m.text, isDark: isDark)
          : _BotBubble(text: m.text, isDark: isDark, isLoading: false);
      },
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final bool isDark;
  const _UserBubble({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg   = isDark ? AppTheme.userBubbleDk : AppTheme.userBubbleL;
    final border = isDark ? AppTheme.borderDark  : AppTheme.borderLight;
    final prim = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec  = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
            ),
            child: Icon(Icons.person_outline_rounded, size: 14, color: sec),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: sec, letterSpacing: 0.3)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: SelectableText(text,
                    style: GoogleFonts.inter(fontSize: 14, color: prim, height: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotBubble extends StatelessWidget {
  final String? text;
  final bool isDark;
  final bool isLoading;
  const _BotBubble({this.text, required this.isDark, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppTheme.botBubbleDk : AppTheme.botBubbleL;
    final border  = isDark ? AppTheme.borderDark  : AppTheme.borderLight;
    final prim   = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppTheme.amberLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.amberAccent.withOpacity(0.4)),
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 13, color: AppTheme.amberAccent))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gemini Canvas',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppTheme.amberAccent, letterSpacing: 0.3)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: isLoading
                    ? const TypingIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _parseText(text ?? '', prim, isDark),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _parseText(String text, Color prim, bool isDark) {
    final parts = text.split('```');
    final result = <Widget>[];
    final codeBg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAF7F2);
    final codeBorder = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final accentColor = AppTheme.amberAccent;

    for (int i = 0; i < parts.length; i++) {
      if (i.isOdd) {
        // ── Code block ──────────────────────────────────
        String code = parts[i];
        String lang = '';
        final nl = code.indexOf('\n');
        if (nl != -1) {
          final l = code.substring(0, nl).trim();
          if (l.isNotEmpty && l.length < 15) {
            lang = l.toUpperCase();
            code = code.substring(nl + 1);
          }
        }
        result.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: codeBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: codeBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lang.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                    border: Border(bottom: BorderSide(color: codeBorder)),
                  ),
                  child: Text(
                    lang,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  code.trim(),
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    color: prim,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (parts[i].trim().isNotEmpty) {
        // ── Text block (split line by line for Markdown formatting) ─
        final lines = parts[i].split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) {
            result.add(const SizedBox(height: 6));
            continue;
          }

          // Header line (### or ## or #)
          if (trimmed.startsWith('### ')) {
            result.add(Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: SelectableText.rich(
                TextSpan(
                  children: _parseInlineMarkdown(
                    trimmed.substring(4),
                    GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: prim,
                    ),
                    accentColor,
                  ),
                ),
              ),
            ));
          } else if (trimmed.startsWith('## ') || trimmed.startsWith('# ')) {
            final content = trimmed.startsWith('## ')
                ? trimmed.substring(3)
                : trimmed.substring(2);
            result.add(Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: SelectableText.rich(
                TextSpan(
                  children: _parseInlineMarkdown(
                    content,
                    GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: prim,
                    ),
                    accentColor,
                  ),
                ),
              ),
            ));
          } else if (trimmed.startsWith('* ') || trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
            // Bullet list item
            final content = trimmed.substring(2);
            result.add(Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✦ ',
                    style: TextStyle(
                      fontSize: 12,
                      color: accentColor,
                      height: 1.5,
                    ),
                  ),
                  Expanded(
                    child: SelectableText.rich(
                      TextSpan(
                        children: _parseInlineMarkdown(
                          content,
                          GoogleFonts.inter(
                            fontSize: 14,
                            color: prim,
                            height: 1.55,
                          ),
                          accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
          } else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
            // Numbered list item (e.g. 1. , 2. )
            final match = RegExp(r'^(\d+\.)\s*(.*)$').firstMatch(trimmed);
            final number = match?.group(1) ?? '1.';
            final content = match?.group(2) ?? trimmed;
            result.add(Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$number ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      height: 1.55,
                    ),
                  ),
                  Expanded(
                    child: SelectableText.rich(
                      TextSpan(
                        children: _parseInlineMarkdown(
                          content,
                          GoogleFonts.inter(
                            fontSize: 14,
                            color: prim,
                            height: 1.55,
                          ),
                          accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
          } else {
            // Standard paragraph line
            result.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SelectableText.rich(
                TextSpan(
                  children: _parseInlineMarkdown(
                    trimmed,
                    GoogleFonts.inter(
                      fontSize: 14,
                      color: prim,
                      height: 1.55,
                    ),
                    accentColor,
                  ),
                ),
              ),
            ));
          }
        }
      }
    }
    return result;
  }

  static List<InlineSpan> _parseInlineMarkdown(
    String text,
    TextStyle baseStyle,
    Color accentColor,
  ) {
    final List<InlineSpan> spans = [];
    final RegExp exp = RegExp(r'(\*\*(.*?)\*\*|\[(.*?)\]\((.*?)\)|\*(.*?)\*|`([^`]+)`)');
    int lastMatchEnd = 0;

    for (final Match match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final String fullMatch = match.group(0) ?? '';
      if (fullMatch.startsWith('**') && fullMatch.endsWith('**')) {
        final String content = match.group(2) ?? '';
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (fullMatch.startsWith('[') && fullMatch.contains('](')) {
        final String label = match.group(3) ?? '';
        spans.add(TextSpan(
          text: label,
          style: baseStyle.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ));
      } else if (fullMatch.startsWith('`') && fullMatch.endsWith('`')) {
        final String codeText = match.group(6) ?? '';
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              codeText,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: baseStyle.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
      } else if (fullMatch.startsWith('*') && fullMatch.endsWith('*')) {
        final String content = match.group(5) ?? '';
        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }
}

// ─────────────────────────────────────────────────────────────
// Input bar
// ─────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool hasText;
  final bool isDark;
  final VoidCallback onSend;

  const _InputBar({
    required this.ctrl, required this.hasText,
    required this.isDark, required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppTheme.surfaceDark  : AppTheme.surfaceLight;
    final border = isDark ? AppTheme.borderDark   : AppTheme.borderLight;
    final sec    = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    final prim   = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              // "+" icon
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.add, size: 18, color: sec),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  onSubmitted: (_) => onSend(),
                  style: GoogleFonts.inter(fontSize: 14, color: prim),
                  decoration: InputDecoration(
                    hintText: 'Sketch a prompt here...',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: sec),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              // Send button
              Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: hasText ? AppTheme.amberAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: hasText ? null : Border.all(color: border),
                  ),
                  child: IconButton(
                    onPressed: hasText ? onSend : null,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    icon: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.send_rounded, size: 14,
                        color: hasText ? Colors.black : sec),
                      const SizedBox(width: 6),
                      Text('Send',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                          color: hasText ? Colors.black : sec)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Right panel (desktop only)
// ─────────────────────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final bool isDark;
  const _RightPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final prim   = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec    = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    final bg     = isDark ? AppTheme.bgDark : AppTheme.bgLight;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: bg,
        border: Border(left: BorderSide(color: border)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Quick access cards
          _RightCard(title: 'Drafts', subtitle: '12 saved prompts',
            icon: Icons.edit_outlined, isDark: isDark),
          const SizedBox(height: 12),
          _RightCard(title: 'Sections', subtitle: 'Research, writing, review',
            icon: Icons.grid_view_rounded, isDark: isDark),
          const SizedBox(height: 20),

          // Workspace notes card
          _EditorialCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workspace notes',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: prim)),
                const SizedBox(height: 4),
                Text('Quick editorial controls.',
                  style: GoogleFonts.inter(fontSize: 11, color: sec)),
                const SizedBox(height: 16),
                _WorkspaceSetting(label: 'Tone', value: 'Warm, calm', tag: 'Beige',
                  isDark: isDark, isAmber: true),
                const SizedBox(height: 10),
                _WorkspaceSetting(label: 'Layout density', value: 'Comfortable spacing',
                  tag: 'Medium', isDark: isDark),
                const SizedBox(height: 10),
                _WorkspaceSetting(label: 'Reading mode', value: 'Paper-like contrast',
                  tag: 'On', isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent sections
          _EditorialCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent sections',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: prim)),
                const SizedBox(height: 4),
                Text('Saved fragments from this session.',
                  style: GoogleFonts.inter(fontSize: 11, color: sec)),
                const SizedBox(height: 14),
                _RecentItem(icon: Icons.article_outlined, title: 'Editorial prompt system',
                  sub: 'Updated 2 minutes ago', isDark: isDark),
                const SizedBox(height: 10),
                _RecentItem(icon: Icons.bookmark_border_rounded, title: 'Paper UI references',
                  sub: 'Saved for later', isDark: isDark),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _RightCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final bool isDark;
  const _RightCard({required this.title, required this.subtitle,
      required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final prim   = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec    = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final bg     = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: sec),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: prim)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: sec)),
        ]),
      ]),
    );
  }
}

class _WorkspaceSetting extends StatelessWidget {
  final String label, value, tag;
  final bool isDark, isAmber;
  const _WorkspaceSetting({required this.label, required this.value,
      required this.tag, required this.isDark, this.isAmber = false});

  @override
  Widget build(BuildContext context) {
    final prim = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec  = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: prim)),
          Text(value,  style: GoogleFonts.inter(fontSize: 11, color: sec)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAmber ? AppTheme.amberAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isAmber ? null : Border.all(color: border),
          ),
          child: Text(tag,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
              color: isAmber ? Colors.black : prim)),
        ),
      ],
    );
  }
}

class _RecentItem extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final bool isDark;
  const _RecentItem({required this.icon, required this.title,
      required this.sub, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final prim = isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec  = isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    return Row(children: [
      Icon(icon, size: 16, color: sec),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: prim)),
        Text(sub, style: GoogleFonts.inter(fontSize: 10, color: sec)),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────
class _EditorialCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _EditorialCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _PromptChip extends StatefulWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _PromptChip({required this.label, required this.isDark, required this.onTap});

  @override
  State<_PromptChip> createState() => _PromptChipState();
}

class _PromptChipState extends State<_PromptChip> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final prim   = widget.isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final hoverBg = widget.isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.04);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hov ? hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Text(widget.label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: prim)),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20,
        color: isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL),
      onPressed: onTap,
      splashRadius: 20,
    );
  }
}
