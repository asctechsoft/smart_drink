import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/bottom_safe_area.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _titleController = TextEditingController();
  final _feedbackController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _feedbackController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _charCount = _feedbackController.text.length;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _feedbackController.removeListener(_onFormChanged);
    _titleController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  bool get _canSend => _feedbackController.text.trim().isNotEmpty;

  void _onSend() {
    if (!_canSend) return;
    // final title = _titleController.text.trim();
    // final body = _feedbackController.text.trim();
    // SharePlus.instance.share(ShareParams(text: '$title\n\n$body'));
    ToastUtils.showSuccessFeedbackToast(context);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: AppText(
            'feedback'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: AppColumn(
            modifier: Modifier.paddingAll(24),
            children: [
              // Header
              Expanded(
                child: SingleChildScrollView(
                  child: AppColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & subtitle
                      AppText(
                        'please_share_your_feedback'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ob.textPrimary,
                          letterSpacing: 0.9,
                        ),
                      ),
                      AppSpacerH4,
                      AppText(
                        'we_read_your_feedback_carefully'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: ob.textPrimary.withValues(alpha: 0.75),
                          letterSpacing: 0.7,
                        ),
                      ),
                      AppSpacerH28,

                      // Title field
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: ob.bgOption,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 14,
                            color: ob.textPercentDrinkItem,
                            letterSpacing: 0.7,
                          ),
                          decoration: InputDecoration(
                            hintText: 'title'.tr,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: ob.textPercentDrinkItem,
                              letterSpacing: 0.7,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      AppSpacerH16,

                      // Feedback field
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: ob.bgOption,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _feedbackController,
                              maxLines: null,
                              expands: true,
                              maxLength: 500,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(
                                fontSize: 14,
                                color: ob.textPercentDrinkItem,
                                letterSpacing: 0.7,
                              ),
                              decoration: const InputDecoration(
                                hintText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 32),
                                counterText: '',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            if (_feedbackController.text.isEmpty)
                              Positioned(
                                left: 12,
                                top: 12,
                                child: IgnorePointer(
                                  child: AppRow(
                                    children: [
                                      AppText(
                                        'feedback_content'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ob.textPercentDrinkItem,
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                      const AppText(
                                        '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 12,
                              bottom: 8,
                              child: AppText(
                                '$_charCount/500',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ob.textSecondary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Send button
              AppSpacerH12,
              PrimaryButton(
                text: 'send'.tr,
                width: double.infinity,
                useGradient: true,
                enabled: _canSend,
                onPressed: _onSend,
              ),
              BottomSafeArea(),
            ],
          ),
        ),
      ),
    );
  }
}

