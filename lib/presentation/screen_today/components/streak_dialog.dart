import 'package:dsp_base/app_material.dart';
import 'package:flutter/material.dart';

/// Shows the +1 Streak celebration dialog.
///
/// [previousStreak] — streak count yesterday.
/// [currentStreak] — streak count today (previousStreak + 1).
Future<void> showStreakDialog(
  BuildContext context, {
  required int previousStreak,
  required int currentStreak,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (_) => _StreakDialog(
      previousStreak: previousStreak,
      currentStreak: currentStreak,
    ),
  );
}

class _StreakDialog extends StatelessWidget {
  const _StreakDialog({
    required this.previousStreak,
    required this.currentStreak,
  });

  final int previousStreak;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/webp/img_bg_streak.webp',
                fit: BoxFit.cover,
              ),
            ),
            // Dark overlay to deepen the bg
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF000E2E).withValues(alpha: 0.55),
                      const Color(0xFF001060).withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flame logo at top — sits above the card a bit
                  _buildLogo(),
                  const SizedBox(height: 8),
                  // "Streak đã tăng" pill
                  _buildStreakPill(),
                  const SizedBox(height: 20),
                  // Yesterday → Today cards
                  _buildCountCards(),
                  const SizedBox(height: 20),
                  // "Tuyệt vời! +1 Streak"
                  _buildHeadline(),
                  const SizedBox(height: 10),
                  // Subtitle lines
                  _buildSubtitle(),
                  const SizedBox(height: 24),
                  // "Tiếp tục" button
                  _buildContinueButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00CFFF).withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: Image.asset(
            'assets/images/webp/img_logo_streak.webp',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF001A5E).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFF00CFFF).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/webp/img_left_streak.webp',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          const Text(
            'Streak đã tăng',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/webp/img_right_streak.webp',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildCountCards() {
    if (previousStreak == 0) {
      return Center(
        child: SizedBox(
          width: 160,
          child: _DayCard(label: 'Hôm nay', count: currentStreak, highlight: true),
        ),
      );
    }
    return Row(
      children: [
        Expanded(child: _DayCard(label: 'Hôm qua', count: previousStreak)),
        const SizedBox(width: 12),
        _ArrowBetween(),
        const SizedBox(width: 12),
        Expanded(child: _DayCard(label: 'Hôm nay', count: currentStreak, highlight: true)),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '≺ ',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5FD9FF),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Tuyệt vời!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              ' ≻',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5FD9FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '✦ ',
              style: TextStyle(fontSize: 12, color: Color(0xFF5FD9FF)),
            ),
            Text(
              '+1 Streak',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5FD9FF),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              ' ✦',
              style: TextStyle(fontSize: 12, color: Color(0xFF5FD9FF)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    const descStyle = TextStyle(
      fontSize: 13,
      color: Colors.white70,
      height: 1.5,
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/webp/img_drink_streak.webp',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              errorBuilder: (_, e, s) => const Icon(
                Icons.water_drop,
                size: 14,
                color: Color(0xFF5FD9FF),
              ),
            ),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                'Bạn đã hoàn thành mục tiêu nước hôm nay',
                style: descStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Tiếp tục duy trì thói quen tốt mỗi ngày',
          style: descStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0094FF), Color(0xFF00D4FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00AAFF).withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/webp/img_drink_streak.webp',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (_, e, s) => const Icon(
                Icons.water_drop,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tiếp tục',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Day count card ─────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.label,
    required this.count,
    this.highlight = false,
  });

  final String label;
  final int count;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlight
        ? const Color(0xFF00CFFF).withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.15);
    final countColor = highlight ? const Color(0xFF5FD9FF) : Colors.white;
    final bgColor = highlight
        ? const Color(0xFF002060).withValues(alpha: 0.6)
        : const Color(0xFF001040).withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: const Color(0xFF00CFFF).withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 52,
              height: 1,
              fontWeight: FontWeight.w900,
              color: countColor,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            Icons.water_drop,
            size: 16,
            color: countColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

// ─── Arrow widget ────────────────────────────────────────────────────────────

class _ArrowBetween extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0060CC).withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00CFFF).withValues(alpha: 0.4),
        ),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Color(0xFF5FD9FF),
        size: 22,
      ),
    );
  }
}
