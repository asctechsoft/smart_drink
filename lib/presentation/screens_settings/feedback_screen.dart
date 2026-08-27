import 'dart:io';

import 'package:dsp_base/app_material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/services/feedback_service.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:get/get.dart';

// Design tokens matching settings_screen.dart
const _kTeal = Color(0xFF57DCC0);
const _kGreen = Color(0xFF96D2A8);
const _kCardBg = Color(0x12FFFFFF); // white 7%
const _kCardBorder = Color(0x1AFFFFFF); // white 10%
const _kIconBg = Color(0x1FFFFFFF); // white 12%
const _kIconBorder = Color(0x33FFFFFF); // white 20%

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // ── Category ──────────────────────────────────────────────────────────────
  int _selectedCategory = -1; // none selected by default

  static const _categories = [
    (icon: Icons.bug_report_outlined, key: 'fb_cat_bug'),
    (icon: Icons.lightbulb_outline_rounded, key: 'fb_cat_suggestion'),
    (icon: Icons.star_outline_rounded, key: 'fb_cat_experience'),
    (icon: Icons.notifications_outlined, key: 'fb_cat_reminder'),
    (icon: Icons.more_horiz_rounded, key: 'fb_cat_other'),
  ];

  // ── Fields ────────────────────────────────────────────────────────────────
  final _subjectCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();
  int _charCount = 0;
  bool _submitted = false; // show required error after first attempt

  // ── Attachments ─────────────────────────────────────────────────────────
  final _picker = ImagePicker();
  final List<XFile> _attachments = [];
  static const _maxAttachments = 3;

  final _scrollCtrl = ScrollController();
  bool _atBottom = false; // true when scrolled to the very end

  bool get _canSend => _feedbackCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl.addListener(() {
      setState(() => _charCount = _feedbackCtrl.text.length);
    });
    _scrollCtrl.addListener(_onScroll);
    // Set initial state once layout is measured (content may fit without scroll).
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final atBottom =
        _scrollCtrl.offset >= _scrollCtrl.position.maxScrollExtent - 4;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _feedbackCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSend() {
    setState(() => _submitted = true);
    if (!_canSend) return;

    final category = _selectedCategory >= 0
        ? _categories[_selectedCategory].key.replaceFirst('fb_cat_', '')
        : 'other';
    // Fire-and-forget — do NOT await; the write is local-first and durable.
    FeedbackService.instance.submit(
      category: category,
      subject: _subjectCtrl.text,
      message: _feedbackCtrl.text,
      attachmentPaths: _attachments.map((e) => e.path).toList(),
    );
    // Pop first, THEN toast. Get.showSnackbar is route-based (pushes a
    // SnackRoute); if we showed it before Get.back(), Get.back() would pop the
    // snackbar route instead of this screen — leaving the screen open and the
    // toast flashing away instantly. Toast resolves Get.context, so it renders
    // correctly over the previous screen after the pop.
    Get.back();
    ToastUtils.showSuccessFeedbackToast(context);
  }

  Future<void> _pickImages() async {
    if (_attachments.length >= _maxAttachments) return;
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      setState(() {
        final room = _maxAttachments - _attachments.length;
        _attachments.addAll(picked.take(room));
      });
      // Scroll so the attach card (last item) clears the sticky send button
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (_) {
      // permission denied / cancelled — ignore
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safeBottom = mq.viewPadding.bottom;
    final keyboardInset = mq.viewInsets.bottom;
    final keyboardUp = keyboardInset > 0;

    const btnHeight = 52.0;
    const topFade = 14.0;
    // Button sits above keyboard when visible, otherwise above safe area
    final btnPaddingBottom = keyboardUp ? 12.0 : safeBottom + 12;
    final containerBottom = keyboardUp ? keyboardInset : 0.0;
    // Total space the sticky button block occupies (gradient fade + btn + pad)
    final buttonBlock = topFade + btnHeight + btnPaddingBottom;

    return OnboardingBackground(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Body shrinks by keyboard height only (like resizeToAvoidBottomInset).
            // ListView reserves the button block as bottom padding so the LAST
            // item can over-scroll clear of the sticky button.
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: Column(
                children: [
                  _buildStickyTop(context),
                  Expanded(
                    child: ListView(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(16, 0, 16, buttonBlock + 16),
                      children: [
                        _buildHero(),
                        const SizedBox(height: 20),
                        _buildCategorySection(),
                        const SizedBox(height: 16),
                        _buildSubjectSection(),
                        const SizedBox(height: 16),
                        _buildFeedbackSection(),
                        const SizedBox(height: 16),
                        _buildAttachSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Sticky button — floats above keyboard when visible
            Positioned(
              bottom: containerBottom,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, topFade, 16, btnPaddingBottom),
                // Solid bar while mid-scroll (or keyboard up) so content can't
                // bleed through behind the button. Only at the very bottom do we
                // switch to the soft transparent gradient fade.
                decoration: (keyboardUp || !_atBottom)
                    // Mid-scroll / keyboard up: opaque gradient in app tones so
                    // content can't bleed through but it still blends with the bg.
                    ? const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF191F71), Color(0xFF0B0921)],
                        ),
                      )
                    // At the very bottom: soft transparent fade.
                    : const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE60B1E3A)],
                        ),
                      ),
                child: _buildSendButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky top bar (back button + title only) ────────────────────────────
  Widget _buildStickyTop(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 12,
              child: Material(
                color: _kIconBg,
                shape: CircleBorder(
                  side: BorderSide(color: _kIconBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.back(),
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  'feedback'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero section (scrolls with list) ─────────────────────────────────────
  Widget _buildHero() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 160,
            top: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'feedback_subtitle'.tr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/webp/img_feed_back.webp',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Category ───────────────────────────────────────────────────────────
  Widget _buildCategorySection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(label: 'fb_question_category'.tr),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_categories.length, (i) {
              final cat = _categories[i];
              final selected = _selectedCategory == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? _kTeal.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: selected
                          ? _kTeal.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 16,
                        color: selected ? _kTeal : _kGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.key.tr,
                        style: TextStyle(
                          color: selected ? _kTeal : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: _kTeal,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 2. Subject ────────────────────────────────────────────────────────────
  Widget _buildSubjectSection() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(label: 'fb_subject'.tr),
          const SizedBox(height: 12),
          _InputField(
            controller: _subjectCtrl,
            hintText: 'fb_subject_hint'.tr,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // ── 3. Feedback body ──────────────────────────────────────────────────────
  Widget _buildFeedbackSection() {
    final showRequired = _submitted && !_canSend;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'fb_your_feedback'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFEF5350),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showRequired
                    ? const Color(0xFFEF5350).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: TextField(
              controller: _feedbackCtrl,
              maxLines: 5,
              maxLength: 1000,
              cursorColor: Colors.white,
              scrollPadding: const EdgeInsets.only(
                left: 20,
                top: 20,
                right: 20,
                bottom: 90,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'fb_feedback_hint'.tr,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showRequired)
                Text(
                  'required'.tr,
                  style: const TextStyle(
                    color: Color(0xFFEF5350),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                '$_charCount/1000',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. Attach screenshot ──────────────────────────────────────────────────
  Widget _buildAttachSection() {
    final canAdd = _attachments.length < _maxAttachments;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'fb_attach'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'fb_attach_optional'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: canAdd ? _pickImages : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kIconBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kIconBorder),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 20,
                    color: canAdd
                        ? _kGreen
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                _attachments.length,
                (i) => _buildThumbnail(i),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_attachments[index].path),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => _removeAttachment(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFEF5350),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Send button ───────────────────────────────────────────────────────────
  Widget _buildSendButton() {
    return PrimaryButton(
      text: 'fb_send'.tr,
      width: double.infinity,
      height: 52,
      useGradient: true,
      enabled: _canSend,
      leading: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
      onPressed: _onSend,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
}

// ─── Shared card container (same style as settings _SectionCard) ─────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
      ),
      child: child,
    );
  }
}

// ─── Card section title row ───────────────────────────────────────────────────

class _CardTitle extends StatelessWidget {
  final String label;
  const _CardTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Text input field ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: Colors.white,
        scrollPadding: const EdgeInsets.only(
          left: 20,
          top: 20,
          right: 20,
          bottom: 90,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
