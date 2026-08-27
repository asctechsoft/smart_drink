import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';

/// AI chat assistant screen ("Hỏi AI"). UI-first: the input appends the user's
/// message and a canned assistant reply — no live backend yet.
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
const _kUserBubble = Color(0xFFDCEAFB);
const _kCardBorder = Color(0x14243A5E);

class _ChatMessage {
  final bool isUser;
  final String text;
  final String time;
  const _ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
  });
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Suggestion chips.
  static const _topChips = [
    (icon: Icons.water_drop_outlined, label: 'Uống bao nhiêu nước là đủ?'),
    (icon: Icons.bedtime_outlined, label: 'Uống nước trước khi ngủ có tốt không?'),
    (icon: Icons.directions_run_rounded, label: 'Uống nước khi vận động thế nào?'),
  ];
  static const _bottomChips = [
    (icon: Icons.water_drop_outlined, label: 'Uống nước đúng cách'),
    (icon: Icons.bedtime_outlined, label: 'Lợi ích của việc uống nước'),
    (icon: Icons.directions_run_rounded, label: 'Uống nước khi tập luyện'),
  ];

  late List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _seed();
  }

  List<_ChatMessage> _seed() => const [
        _ChatMessage(
          isUser: true,
          text: 'Uống bao nhiêu nước là đủ?',
          time: '09:41',
        ),
      ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _now() {
    final t = TimeOfDay.fromDateTime(DateTime.now());
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text, time: _now()));
      _messages.add(
        _ChatMessage(
          isUser: false,
          time: _now(),
          text: 'Mình đã ghi nhận câu hỏi của bạn. Trợ lý AI sẽ trả lời chi '
              'tiết về "$text" ở đây.',
        ),
      );
    });
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _newChat() {
    setState(() => _messages = _seed());
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
                child: ListView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 16),
                    _buildChipRow(_topChips),
                    const SizedBox(height: 18),
                    for (var i = 0; i < _messages.length; i++) ...[
                      _buildMessage(_messages[i]),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
              _buildChipRow(_bottomChips),
              const SizedBox(height: 10),
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
            child: const Icon(Icons.chevron_left_rounded, color: _kInk, size: 26),
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
                      'Hỏi AI',
                      style: const TextStyle(
                        color: _kOnBg,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Trợ lý sức khỏe & uống nước',
                  style: TextStyle(color: _kOnBgSoft, fontSize: 12.5),
                ),
              ],
            ),
          ),
          _circleBtn(
            child: const Icon(Icons.add_rounded, color: _kInk, size: 24),
            onTap: _newChat,
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
                const Text(
                  'Chào bạn! 👋',
                  style: TextStyle(
                    color: _kInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mình là trợ lý AI của Drink Water.\n'
                  'Hỏi mình mọi thắc mắc về uống nước và sức khỏe nhé!',
                  style: TextStyle(color: _kInkSoft, fontSize: 13.5, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Message bubble ────────────────────────────────────────────────────────────
  Widget _buildMessage(_ChatMessage m) {
    if (m.isUser) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kUserBubble,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    m.text,
                    style: const TextStyle(
                      color: _kInk,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(m.time, style: const TextStyle(color: _kOnBgSoft, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _avatarCircle(
            child: const Icon(Icons.person_rounded, color: _kBlue, size: 20),
          ),
        ],
      );
    }

    // Bot message
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
        Flexible(
          flex: 6,
          child: _cardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.text,
                  style: const TextStyle(color: _kInk, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: _kInkSoft, size: 15),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Thông tin mang tính tham khảo, không thay thế tư vấn y tế.',
                        style: TextStyle(color: _kInkSoft, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(m.time,
                        style: const TextStyle(color: _kInkSoft, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Suggestion chips ────────────────────────────────────────────────────────
  Widget _buildChipRow(List<({IconData icon, String label})> chips) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = chips[i];
          return GestureDetector(
            onTap: () => _send(c.label),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 210),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kCardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.icon, color: _kBlue, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      c.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kInk,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _kCardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: _kBlue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      cursorColor: _kBlue,
                      style: const TextStyle(color: _kInk, fontSize: 14.5),
                      decoration: const InputDecoration(
                        hintText: 'Hỏi AI...',
                        hintStyle: TextStyle(color: _kInkSoft, fontSize: 14.5),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.mic_none_rounded, color: _kInkSoft, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(_inputCtrl.text),
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kBlue, _kBlueDeep],
                ),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── Small helpers ────────────────────────────────────────────────────────────
  Widget _cardBox({required Widget child}) {
    return Container(
      width: double.infinity,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: _kCardBorder),
        ),
        child: child,
      ),
    );
  }

  Widget _avatarCircle({required Widget child}) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _kBlue.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
