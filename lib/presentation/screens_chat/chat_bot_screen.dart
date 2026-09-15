import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/configs/ai_gateway_config.dart';
import 'package:waternudge/controller/chat_controller.dart';
import 'package:waternudge/models/ui_models/chat_card.dart';
import 'package:waternudge/models/ui_models/chat_message.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';

/// AI chat assistant screen ("Hỏi AI").
///
/// Every message goes to `server_gateway_ai`, which holds the provider key and
/// the system prompt; [ChatController] owns the transcript and the in-flight
/// state, so this file is only the presentation of it.
class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

// ── Palette ──────────────────────────────────────────────────────────────────
// Screen sits on the app's shared dark gradient (OnboardingBackground). Message
// cards stay light (matching the design); text on the dark background is white.
const _kBlue = Color(0xFF2E7DF0);
const _kBlueDeep = Color(0xFF1E63D0);
const _kInk = Color(0xFF2A3A4D); // text inside light cards
const _kInkSoft = Color(0xFF6B7A8D); // secondary text inside light cards
const _kOnBg = Colors.white; // text on the dark background
const _kOnBgSoft = Colors.white70;
const _kCardBorder = Color(0x14243A5E);
const _kError = Color(0xFFD14343);

// On-gradient surfaces (suggestion chips, header buttons, user avatar): a wash
// of white over the blue background rather than an opaque card.
const _kChipBg = Color(0x1FFFFFFF); // ~12% white
const _kChipBorder = Color(0x2EFFFFFF); // ~18% white
const _kChipIconBg = Color(0x333B8CFF); // soft blue tile behind the icon
const _kChevron = Color(0x8AFFFFFF); // white54

class _ChatBotScreenState extends State<ChatBotScreen>
    with WidgetsBindingObserver {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final ChatController _chat = ChatController.to;

  // Starter prompts: converted to getter so .tr can be called at runtime.
  static List<({IconData icon, String label, Color tint})> get _suggestions => [
    (icon: Icons.water_drop_rounded, label: 'suggest_how_much_water'.tr, tint: _kOnBg),
    (icon: Icons.bedtime_rounded, label: 'suggest_water_before_sleep'.tr, tint: _kOnBg),
    (icon: Icons.bar_chart_rounded, label: 'suggest_water_benefits'.tr, tint: _kOnBg),
    (icon: Icons.favorite_rounded, label: 'suggest_dehydration_signs'.tr, tint: const Color(0xFFFF6B8A)),
  ];

  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Every append should land in view, including the assistant's reply, which
    // arrives long after the send.
    _workers
      ..add(ever(_chat.messages, (_) => _scrollToBottom()))
      ..add(ever(_chat.isSending, (_) => _scrollToBottom()));
  }

  // The keyboard opening changes the bottom inset; keep the last message in view
  // above it instead of leaving it hidden behind the input bar.
  @override
  void didChangeMetrics() => _scrollToBottom();

  // Coming back to the screen may mean a new day — re-read the free allowance
  // rather than leaving yesterday's "out of questions" state on screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _chat.refreshQuota();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final worker in _workers) {
      worker.dispose();
    }
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(String raw) {
    if (_chat.isSending.value) return;
    if (raw.trim().isEmpty) return;
    _inputCtrl.clear();
    FocusScope.of(context).unfocus();
    _chat.send(raw);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(
                  () => ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 4, 12, 16),
                    children: _chat.messages.isEmpty
                        ? [
                            StaggerReveal(index: 0, child: _buildIntro()),
                            const SizedBox(height: 16),
                            StaggerReveal(
                              index: 1,
                              child: _buildSuggestionsGrid(),
                            ),
                            const SizedBox(height: 16),
                            StaggerReveal(index: 2, child: _buildEmptyState()),
                          ]
                        : [
                            for (final message in _chat.messages) ...[
                              _buildMessage(message),
                              const SizedBox(height: 14),
                            ],
                            if (_chat.isSending.value &&
                                !_chat.isStreaming.value)
                              _buildTyping(),
                          ],
                  ),
                ),
              ),
              // Suggestions pinned above the input bar during a conversation.
              // They send on tap, so they go away once today's quota is spent.
              Obx(
                () => _chat.messages.isEmpty || !_chat.hasFreeQuestions
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _buildSuggestions(),
                      ),
              ),
              Obx(
                () => _chat.hasFreeQuestions
                    ? _buildQuotaLine()
                    : _buildQuotaExhausted(),
              ),
              _buildInputBar(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _circleBtn(
            child: const Icon(Icons.chevron_left_rounded, color: _kOnBg, size: 26),
            onTap: () => Get.back(),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: _kBlue, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'chat_screen_title'.tr,
                      style: const TextStyle(
                        color: _kOnBg,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'chat_screen_subtitle'.tr,
                  style: const TextStyle(color: _kOnBgSoft, fontSize: 12.5),
                ),
              ],
            ),
          ),
          _circleBtn(
            child: const Icon(Icons.add_rounded, color: _kOnBg, size: 24),
            onTap: _chat.newChat,
          ),
        ],
      ),
    );
  }

  // ── Intro (mascot + welcome bubble) ──────────────────────────────────────────
  Widget _buildIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/png/ic_chat_bot.png',
          width: 96,
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat_greeting_title'.tr,
                  style: const TextStyle(
                    color: _kInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'chat_greeting_body'.tr,
                  style: const TextStyle(color: _kInkSoft, fontSize: 13.5, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Message bubble ────────────────────────────────────────────────────────────
  Widget _buildMessage(ChatMessage m) {
    if (m.isUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kBlue, _kBlueDeep],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    m.text,
                    style: const TextStyle(
                      color: _kOnBg,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m.timeLabel,
                      style: const TextStyle(color: _kOnBgSoft, fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all_rounded, color: _kOnBgSoft, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Bot message
    final suggestions = m.card?.suggestions ?? const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/png/ic_bot.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(child: _cardBox(child: _botContent(m))),
          ],
        ),
        // Follow-up questions the user can tap, laid out under the bubble and
        // indented to line up with the card (bot avatar + gap = 48).
        if (!m.isError && suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 10),
            child: _buildFollowUps(suggestions),
          ),
      ],
    );
  }

  /// The inner content of a bot bubble: a rich card when the reply parsed, else
  /// plain text. Both close with the disclaimer/retry footer.
  Widget _botContent(ChatMessage m) {
    if (m.isError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.text,
            style: const TextStyle(color: _kError, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 10),
          _buildErrorFooter(m),
        ],
      );
    }

    final card = m.card;
    if (card == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.text,
            style: const TextStyle(color: _kInk, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 10),
          _buildReplyFooter(m),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.intro.isNotEmpty)
          Text(
            card.intro,
            style: const TextStyle(
              color: _kInk,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (card.points.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (var i = 0; i < card.points.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _pointRow(card.points[i]),
          ],
        ],
        if (card.hasOutro) ...[
          const SizedBox(height: 12),
          Text(
            card.outro,
            style: const TextStyle(color: _kInkSoft, fontSize: 13.5, height: 1.45),
          ),
        ],
        const SizedBox(height: 12),
        _buildReplyFooter(m),
      ],
    );
  }

  /// One bullet: a colour-tinted icon, a bold title and a soft body.
  Widget _pointRow(ChatCardPoint p) {
    final (icon, color) = _iconFor(p.icon);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.title.isNotEmpty)
                Text(
                  p.title,
                  style: const TextStyle(
                    color: _kInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              if (p.title.isNotEmpty && p.body.isNotEmpty)
                const SizedBox(height: 3),
              if (p.body.isNotEmpty)
                Text(
                  p.body,
                  style: const TextStyle(
                    color: _kInkSoft,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Maps a gateway icon keyword to a Material icon and its accent colour. An
  /// unknown keyword falls back to a neutral info icon.
  (IconData, Color) _iconFor(String key) {
    return switch (key) {
      'water' => (Icons.water_drop_rounded, _kBlue),
      'heart' => (Icons.favorite_rounded, const Color(0xFFF2547D)),
      'moon' || 'sleep' => (Icons.bedtime_rounded, const Color(0xFF6C63FF)),
      'sun' => (Icons.wb_sunny_rounded, const Color(0xFFF5A623)),
      'warning' => (Icons.warning_amber_rounded, const Color(0xFFE8833A)),
      'timer' => (Icons.timer_rounded, const Color(0xFF3AA0E8)),
      'exercise' => (Icons.fitness_center_rounded, const Color(0xFF2FB57A)),
      'food' => (Icons.restaurant_rounded, const Color(0xFF2FA6A0)),
      'brain' => (Icons.psychology_rounded, const Color(0xFF9B59B6)),
      'energy' => (Icons.bolt_rounded, const Color(0xFFF5A623)),
      'coffee' => (Icons.local_cafe_rounded, const Color(0xFF8D6E63)),
      'check' => (Icons.check_circle_rounded, const Color(0xFF2FB57A)),
      _ => (Icons.info_rounded, _kInkSoft),
    };
  }

  /// Tappable follow-up questions under a bot answer.
  Widget _buildFollowUps(List<String> suggestions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final q in suggestions) _followUpChip(q)],
    );
  }

  Widget _followUpChip(String question) {
    return Material(
      color: _kChipBg,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _chat.isSending.value ? null : () => _send(question),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kChipBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: _kOnBgSoft, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  question,
                  style: const TextStyle(
                    color: _kOnBg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Answers carry the medical disclaimer — the server prompt tells the model
  /// to defer to a professional, and this repeats it where the user reads.
  Widget _buildReplyFooter(ChatMessage m) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: _kInkSoft, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'chat_disclaimer'.tr,
            style: const TextStyle(color: _kInkSoft, fontSize: 11.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          m.timeLabel,
          style: const TextStyle(color: _kInkSoft, fontSize: 11),
        ),
      ],
    );
  }

  /// A retry button only when the controller kept the message — a rejected
  /// request would fail the same way and spend another call from the quota.
  Widget _buildErrorFooter(ChatMessage m) {
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: _kError, size: 15),
        const SizedBox(width: 6),
        if (_chat.canRetry)
          GestureDetector(
            onTap: _chat.retry,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, color: _kBlue, size: 16),
                const SizedBox(width: 4),
                Text(
                  'chat_retry'.tr,
                  style: const TextStyle(
                    color: _kBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        Text(
          m.timeLabel,
          style: const TextStyle(color: _kInkSoft, fontSize: 11),
        ),
      ],
    );
  }

  // ── Typing indicator ────────────────────────────────────────────────────────
  Widget _buildTyping() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/png/ic_bot.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        _cardBox(
          width: null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_kBlue),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'chat_typing'.tr,
                style: const TextStyle(color: _kInkSoft, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Suggestion chips ────────────────────────────────────────────────────────
  /// The starter prompts under the intro, in a single horizontally-scrolling
  /// row so more can be added without stacking.
  Widget _buildSuggestions() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) =>
            SizedBox(width: 230, child: _suggestionChip(_suggestions[i])),
      ),
    );
  }

  Widget _suggestionChip(({IconData icon, String label, Color tint}) s) {
    return Material(
      color: _kChipBg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _send(s.label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kChipBorder),
          ),
          child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _kChipIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(s.icon, color: s.tint, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _kOnBg,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: _kChevron, size: 20),
          ],
          ),
        ),
      ),
    );
  }

  /// The 2×2 starter grid shown on the empty screen.
  Widget _buildSuggestionsGrid() {
    const gap = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final chipWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in _suggestions)
              SizedBox(width: chipWidth, height: 58, child: _suggestionChip(s)),
          ],
        );
      },
    );
  }

  // ── Empty state (before the first message) ──────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: _kChipBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kChipBorder),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/png/ic_chat_bot.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'chat_empty_title'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kOnBg,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'chat_empty_body'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kOnBgSoft, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: _kChevron, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'chat_disclaimer'.tr,
                  style: const TextStyle(color: _kChevron, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────────
  // ── Free quota ───────────────────────────────────────────────────────────────

  /// "Còn 3/5 câu hỏi miễn phí hôm nay" — shown while the device still has
  /// questions left today.
  Widget _buildQuotaLine() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt_rounded, color: _kOnBgSoft, size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'chat_free_remaining'.trParams({
                'args1': '${_chat.freeRemaining.value}',
                'args2': '${_chat.freePerDay}',
              }),
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kOnBgSoft, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Replaces the quota line once today's questions are spent. The input bar
  /// below it locks until the device's next calendar day.
  Widget _buildQuotaExhausted() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kChipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kChipBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: _kChipIconBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_bottom_rounded,
                color: _kOnBg,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'chat_free_exhausted_title'.trParams({
                      'args1': '${_chat.freePerDay}',
                    }),
                    style: const TextStyle(
                      color: _kOnBg,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'chat_free_exhausted_desc'.tr,
                    style: const TextStyle(color: _kOnBgSoft, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Obx(() {
      final sending = _chat.isSending.value;
      // Out of free questions: the field and the send button go inert until the
      // allowance resets, so a tap cannot spend a call that would be refused.
      final locked = !_chat.hasFreeQuestions;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          // As the field grows to several lines, keep the icon and the send
          // button pinned to the bottom line, like ChatGPT.
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _kCardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // The sparkle only decorates the empty field; once the user
                    // types it gets out of the way.
                    ValueListenableBuilder(
                      valueListenable: _inputCtrl,
                      builder: (_, value, _) {
                        if (value.text.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return const Padding(
                          padding: EdgeInsets.only(right: 8, bottom: 14),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: _kBlue,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        enabled: !sending && !locked,
                        // Enter inserts a newline; sending is the button's job,
                        // so a long question can grow to several lines.
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 5,
                        // The gateway rejects anything longer, so stop the
                        // keyboard rather than the server.
                        maxLength: AiGatewayConfig.maxPromptChars,
                        buildCounter:
                            (
                              _, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        cursorColor: _kBlue,
                        style: const TextStyle(
                          color: _kInk,
                          fontSize: 14.5,
                          height: 1.35,
                        ),
                        decoration: InputDecoration(
                          hintText: locked
                              ? 'chat_input_hint_locked'.tr
                              : 'chat_input_hint'.tr,
                          hintStyle: const TextStyle(color: _kInkSoft, fontSize: 14.5),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Opacity(
              opacity: sending || locked ? 0.5 : 1,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kBlue, _kBlueDeep],
                    ),
                  ),
                  child: InkWell(
                    onTap: sending || locked ? null : () => _send(_inputCtrl.text),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Small helpers ────────────────────────────────────────────────────────────
  Widget _cardBox({required Widget child, double? width = double.infinity}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _circleBtn({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: _kChipBg,
      shape: const CircleBorder(side: BorderSide(color: _kChipBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(child: child),
        ),
      ),
    );
  }
}
