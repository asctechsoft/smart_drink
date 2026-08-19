import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/bottom_safe_area.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    'water_tracking',
    'unlimited_drink_types',
    'edit_history',
    'advanced_statistics',
    'no_ads',
  ];

  // PRO has all features, BASIC only has index 0
  static const _basicIncluded = {0};

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              AppColumn(
                modifier: Modifier.padding(horizontal: 16),
                children: [
                  // Top bar
                  AppRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppIcon(
                        'assets/images/svg/ic_close.svg',
                        size: 24,
                        onClick: () => Get.back(),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: initiate purchase
                        },
                        child: AppText(
                          'restore'.tr,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacerH16,
                  // Title
                  AppText(
                    'no_limits_access'.tr.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.basic500,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacerH8,
                  AppText(
                    "days_free_then".trParams({"args1": "66.666"}),
                    style: TextStyle(color: AppColors.basic400, fontSize: 15),
                  ),
                  // Comparison table
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: _ComparisonTable(
                          features: _features,
                          basicIncluded: _basicIncluded,
                        ),
                      ),
                    ),
                  ),

                  // Try for Free button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: PrimaryButton(
                      text: 'try_for_free'.tr,
                      useGradient: true,
                      width: double.infinity,
                      onPressed: () {
                        ToastUtils.showToast(context, 'coming_soon'.tr);
                      },
                    ),
                  ),
                  AppSpacerH8,

                  // Caption
                  AppRow(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        'assets/images/svg/ic_check.svg',
                        size: 18,
                        tint: AppColors.basic300,
                      ),
                      AppSpacerW4,
                      AppText(
                        'no_payment_due_now_cancel_anytime'.tr,
                        style: TextStyle(
                          color: AppColors.basic400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  AppSpacerH24,

                  BottomSafeArea(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Comparison Table ────────────────────────────────────────────────────────

class _ComparisonTable extends StatefulWidget {
  final List<String> features;
  final Set<int> basicIncluded;

  const _ComparisonTable({required this.features, required this.basicIncluded});

  @override
  State<_ComparisonTable> createState() => _ComparisonTableState();
}

class _ComparisonTableState extends State<_ComparisonTable> {
  bool isProSelected = true;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          // Column Highlight Overlay
          Positioned.fill(
            child: AppRow(
              children: [
                const Expanded(flex: 5, child: SizedBox.shrink()),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () => setState(() => isProSelected = true),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(top: 28),
                      decoration: BoxDecoration(
                        color: isProSelected
                            ? ob.bgCardIAP
                            : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () => setState(() => isProSelected = false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(top: 28),
                      decoration: BoxDecoration(
                        color: !isProSelected
                            ? ob.bgCardIAP
                            : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tab header row
              _buildHeader(),
              // Feature rows
              ...List.generate(widget.features.length, (i) {
                return _buildFeatureRow(
                  label: widget.features[i],
                  proIncluded: true,
                  basicIncluded: widget.basicIncluded.contains(i),
                  isLast: i == widget.features.length - 1,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final ob = OnboardingTheme.of(context);
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background Bar
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ob.bgHeaderIAP,
            ),
            child: AppRow(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: AppText(
                      'your_benefits'.tr,
                      style: TextStyle(
                        color: ob.textPercentDrinkItem,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const Expanded(flex: 3, child: SizedBox.shrink()),
                const Expanded(flex: 3, child: SizedBox.shrink()),
              ],
            ),
          ),
          // Tabs
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(flex: 5, child: SizedBox.shrink()),
              // PRO Tab
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => setState(() => isProSelected = true),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: isProSelected ? 64 : 56,
                    decoration: isProSelected
                        ? BoxDecoration(
                            gradient: ob.gradientIAP,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          )
                        : null,
                    alignment: Alignment.center,
                    child: AppText(
                      'pro'.tr,
                      style: TextStyle(
                        color: isProSelected
                            ? Colors.white
                            : ob.textPercentDrinkItem,
                        fontSize: isProSelected ? 20 : 14,
                        fontWeight: isProSelected
                            ? FontWeight.w900
                            : FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // BASIC tab
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => setState(() => isProSelected = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: !isProSelected ? 64 : 56,
                    decoration: !isProSelected
                        ? BoxDecoration(
                            gradient: ob.gradientIAP,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          )
                        : null,
                    alignment: Alignment.center,
                    child: AppText(
                      'basic'.tr,
                      style: TextStyle(
                        color: !isProSelected
                            ? Colors.white
                            : ob.textPercentDrinkItem,
                        fontSize: !isProSelected ? 20 : 14,
                        fontWeight: !isProSelected
                            ? FontWeight.w900
                            : FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required String label,
    required bool proIncluded,
    required bool basicIncluded,
    required bool isLast,
  }) {
    final ob = OnboardingTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: const Color.fromARGB(
                    255,
                    34,
                    13,
                    13,
                  ).withValues(alpha: 0.08),
                ),
              ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Feature name
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 24, bottom: 24),
                child: AppText(
                  label.tr,
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
            // PRO column
            Expanded(
              flex: 3,
              child: Center(
                child: AppIcon(
                  proIncluded
                      ? 'assets/images/svg/ic_check_circle.svg'
                      : 'assets/images/svg/ic_cancel.svg',
                  size: 24,
                  onClick: () => setState(() => isProSelected = true),
                ),
              ),
            ),
            // BASIC column
            Expanded(
              flex: 3,
              child: Center(
                child: AppIcon(
                  basicIncluded
                      ? 'assets/images/svg/ic_check_circle.svg'
                      : 'assets/images/svg/ic_cancel.svg',
                  size: 24,
                  onClick: () => setState(() => isProSelected = false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

