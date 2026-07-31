import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_gemini/core/theme.dart';

class Sidebar extends StatefulWidget {
  final List<String> chatSessions;
  final int activeSessionIndex;
  final Function(int) onSessionSelected;
  final VoidCallback onNewChat;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final String apiKey;
  final Function(String) onApiKeyChanged;
  final bool isDemoMode;
  final Function(bool) onDemoModeChanged;
  final bool isMobile;

  const Sidebar({
    super.key,
    required this.chatSessions,
    required this.activeSessionIndex,
    required this.onSessionSelected,
    required this.onNewChat,
    required this.isDark,
    required this.onToggleTheme,
    required this.apiKey,
    required this.onApiKeyChanged,
    required this.isDemoMode,
    required this.onDemoModeChanged,
    this.isMobile = false,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  void _openApiKeyModal() {
    showDialog(
      context: context,
      builder: (_) => _ApiKeyDialog(
        isDark: widget.isDark,
        currentKey: widget.apiKey,
        onSaveKey: widget.onApiKeyChanged,
        isDemoMode: widget.isDemoMode,
        onToggleDemo: widget.onDemoModeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg     = widget.isDark ? AppTheme.surfaceDark  : AppTheme.surfaceLight;
    final border = widget.isDark ? AppTheme.borderDark   : AppTheme.borderLight;
    final prim   = widget.isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec    = widget.isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;

    return Container(
      width: widget.isMobile ? MediaQuery.of(context).size.width * 0.78 : 240,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.amberLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.amberAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Center(
                    child: Text('✦',
                      style: TextStyle(fontSize: 18, color: AppTheme.amberAccent)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gemini Canvas',
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700, color: prim)),
                    Text('AI workspace',
                      style: GoogleFonts.inter(fontSize: 11, color: sec)),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(color: border, height: 1),
          ),
          const SizedBox(height: 12),

          // ── Nav items ─────────────────────────────────────
          _NavItem(icon: Icons.add, label: 'New Chat',
              isDark: widget.isDark, onTap: widget.onNewChat),
          _NavItem(icon: Icons.history_rounded, label: 'History',
              isDark: widget.isDark, onTap: () {}),
          _NavItem(icon: Icons.bookmark_border_rounded, label: 'Saved',
              isDark: widget.isDark, onTap: () {}),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isDark: widget.isDark,
            onTap: _openApiKeyModal,
            trailing: widget.isDemoMode
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.amberAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('DEMO',
                    style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: AppTheme.amberAccent)),
                )
              : (widget.apiKey.isNotEmpty
                  ? Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), shape: BoxShape.circle),
                    )
                  : Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400, shape: BoxShape.circle),
                    )),
          ),

          const SizedBox(height: 16),

          // Demo Mode active banner or API key alert
          if (widget.isDemoMode)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.amberAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.amberAccent.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.amberAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Smart Demo Mode (Offline)',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppTheme.amberAccent,
                      fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

          if (widget.chatSessions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('RECENT',
                style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: sec, letterSpacing: 1.2)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: widget.chatSessions.length,
                itemBuilder: (_, i) => _SessionTile(
                  title: widget.chatSessions[i],
                  isActive: widget.activeSessionIndex == i,
                  isDark: widget.isDark,
                  onTap: () => widget.onSessionSelected(i),
                ),
              ),
            ),
          ] else
            const Spacer(),

          // ── Theme Toggle ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: border, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Daily paper mode',
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600, color: prim)),
                      Text('Warm beige, soft ink',
                        style: GoogleFonts.inter(fontSize: 10, color: sec)),
                    ]),
                    GestureDetector(
                      onTap: widget.onToggleTheme,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 44, height: 24,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppTheme.borderDark
                              : AppTheme.amberAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Align(
                          alignment: widget.isDark
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            width: 18, height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// API Key & Demo Mode Dialog
// ─────────────────────────────────────────────────────────────
class _ApiKeyDialog extends StatefulWidget {
  final bool isDark;
  final String currentKey;
  final Function(String) onSaveKey;
  final bool isDemoMode;
  final Function(bool) onToggleDemo;

  const _ApiKeyDialog({
    required this.isDark,
    required this.currentKey,
    required this.onSaveKey,
    required this.isDemoMode,
    required this.onToggleDemo,
  });

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  late final TextEditingController _ctrl;
  late bool _demoActive;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentKey);
    _demoActive = widget.isDemoMode;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg     = widget.isDark ? AppTheme.surfaceDark  : AppTheme.surfaceLight;
    final border = widget.isDark ? AppTheme.borderDark   : AppTheme.borderLight;
    final prim   = widget.isDark ? AppTheme.textPrimaryD : AppTheme.textPrimaryL;
    final sec    = widget.isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    final inputBg = widget.isDark ? AppTheme.surface2Dark : AppTheme.surface2Light;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.amberLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.amberAccent.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.tune_rounded,
                  size: 18, color: AppTheme.amberAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Workspace AI Settings',
                    style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700, color: prim)),
                  Text('Configure Gemini API or switch to offline Demo mode.',
                    style: GoogleFonts.inter(fontSize: 11, color: sec)),
                ]),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: sec),
                onPressed: () => Navigator.pop(context),
              ),
            ]),

            const SizedBox(height: 20),

            // Demo Mode Switch
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _demoActive
                    ? AppTheme.amberAccent.withValues(alpha: 0.1)
                    : (widget.isDark ? AppTheme.surface2Dark : AppTheme.surface2Light),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _demoActive ? AppTheme.amberAccent : border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Smart Demo AI Mode',
                              style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w700, color: prim)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.amberAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('OFFLINE',
                                style: GoogleFonts.inter(
                                  fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bypasses API quota limits. Responds instantly to Flutter, code & research questions.',
                          style: GoogleFonts.inter(fontSize: 11, color: sec),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _demoActive,
                    activeColor: AppTheme.amberAccent,
                    onChanged: (val) {
                      setState(() => _demoActive = val);
                      widget.onToggleDemo(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: border, height: 1),
            const SizedBox(height: 16),

            // API key input section
            Text('Custom Gemini API Key', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: prim)),
            const SizedBox(height: 6),
            TextField(
              controller: _ctrl,
              obscureText: _obscure,
              enabled: !_demoActive,
              style: GoogleFonts.robotoMono(fontSize: 13, color: prim),
              decoration: InputDecoration(
                hintText: 'AIza...',
                hintStyle: GoogleFonts.robotoMono(fontSize: 13, color: sec),
                filled: true,
                fillColor: _demoActive ? border.withValues(alpha: 0.3) : inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppTheme.amberAccent, width: 1.5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                    size: 16, color: sec),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              'Get a free API key at aistudio.google.com → Create API key.',
              style: GoogleFonts.inter(fontSize: 11, color: sec),
            ),

            const SizedBox(height: 20),

            // Actions
            Row(children: [
              if (_ctrl.text.isNotEmpty)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _ctrl.clear();
                      widget.onSaveKey('');
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: sec,
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Clear Key',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
              if (_ctrl.text.isNotEmpty) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSaveKey(_ctrl.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.amberAccent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Save Settings',
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: Colors.black)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Nav item
// ─────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  const _NavItem({
    required this.icon, required this.label,
    required this.isDark, required this.onTap,
    this.trailing,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final prim = widget.isDark ? AppTheme.textPrimaryD  : AppTheme.textPrimaryL;
    final sec  = widget.isDark ? AppTheme.textSecondaryD : AppTheme.textSecondaryL;
    final hoverBg = widget.isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hov ? hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(widget.icon, size: 18, color: _hov ? prim : sec),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: _hov ? prim : sec)),
            ),
            if (widget.trailing != null) widget.trailing!,
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Session tile
// ─────────────────────────────────────────────────────────────
class _SessionTile extends StatefulWidget {
  final String title;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _SessionTile({required this.title, required this.isActive,
      required this.isDark, required this.onTap});

  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final isLight = !widget.isDark;
    final prim  = isLight ? AppTheme.textPrimaryL  : AppTheme.textPrimaryD;
    final sec   = isLight ? AppTheme.textSecondaryL : AppTheme.textSecondaryD;
    final activeBg = isLight
        ? AppTheme.amberLight
        : AppTheme.amberAccent.withValues(alpha: 0.12);
    final hoverBg = isLight
        ? Colors.black.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.05);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isActive
                ? activeBg
                : (_hov ? hoverBg : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 14,
              color: widget.isActive ? AppTheme.amberAccent : sec),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: widget.isActive
                      ? FontWeight.w600 : FontWeight.w400,
                  color: widget.isActive ? prim : sec)),
            ),
          ]),
        ),
      ),
    );
  }
}
