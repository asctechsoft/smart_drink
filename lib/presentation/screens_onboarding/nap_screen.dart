import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/onboarding_controller.dart';
import 'package:waternudge/presentation/common_components/custom_switch.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/onboarding_progress_bar.dart';
import 'package:waternudge/presentation/common_components/onboarding_step_header.dart';
import 'package:waternudge/presentation/common_components/primary_bottom_sheet.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/presentation/common_components/wheel_time_picker.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/route_name.dart';

/// Onboarding step 6/7 — nap (siesta) window. When enabled, drink reminders are
/// paused during the nap time range. UI mirrors wakeup/bedtime styling.
class NapScreen extends StatelessWidget {
  const NapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: AppColumn(
            children: [
              OnboardingProgressBar(
                currentStep: 6,
                totalSteps: 7,
                onBack: () => Get.back(),
              ),
              Expanded(
                child: StaggerColumn(
                  padding: const EdgeInsets.all(24),
                  children: [
                    OnboardingStepHeader(
                      title: 'nap_question'.tr,
                      subtitle: 'nap_subtitle'.tr,
                    ),
                    AppSpacerH24,
                    _buildToggleCard(controller),
                    AppSpacerH16,
                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: controller.napEnabled.value ? 1 : 0.4,
                        child: IgnorePointer(
                          ignoring: !controller.napEnabled.value,
                          child: _buildRangeCard(context, controller),
                        ),
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      text: 'next'.tr,
                      width: double.infinity,
                      useGradient: true,
                      onPressed: () {
                        controller.nextStep();
                        Get.toNamed(RouteName.onboardingBedtime);
                      },
                    ),
                    AppSpacerH20,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Toggle card ────────────────────────────────────────────────────────────
  Widget _buildToggleCard(OnboardingController controller) {
    return _card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'nap_title'.tr,
                  style: const TextStyle(
                    color: AppColors.basic500,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'nap_toggle_desc'.tr,
                  style: TextStyle(
                    color: AppColors.basic500.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => CustomSwitch(
              value: controller.napEnabled.value,
              onChanged: (v) => controller.napEnabled.value = v,
              activeColor: AppColors.accentTeal,
              trackColor: AppColors.basic500.withValues(alpha: 0.2),
              width: 46,
              height: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ── Time range + duration chips + info ───────────────────────────────────────
  Widget _buildRangeCard(BuildContext context, OnboardingController controller) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'nap_time_range'.tr,
            style: const TextStyle(
              color: AppColors.basic500,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _TimeField(
                    time: controller.napStart.value,
                    onTap: () => _pickTime(
                      context,
                      initial: controller.napStart.value,
                      onSubmit: (t) {
                        controller.napStart.value = t;
                        // Keep the chosen duration: shift end to start + duration.
                        controller.napEnd.value = OnboardingController.addMinutes(
                          t,
                          controller.napDurationMinutes.value,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '—',
                  style: TextStyle(color: AppColors.basic500, fontSize: 18),
                ),
              ),
              Expanded(
                child: Obx(
                  () => _TimeField(
                    time: controller.napEnd.value,
                    onTap: () => _pickTime(
                      context,
                      initial: controller.napEnd.value,
                      onSubmit: (t) {
                        controller.napEnd.value = t;
                        controller.napDurationMinutes.value =
                            OnboardingController.diffMinutes(
                          controller.napStart.value,
                          t,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfo(),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.basic500.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.basic500.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 22,
            color: AppColors.accentTeal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'nap_info'.tr,
              style: TextStyle(
                color: AppColors.basic500.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  void _pickTime(
    BuildContext context, {
    required String initial,
    required ValueChanged<String> onSubmit,
  }) {
    var picked = initial;
    PrimaryBottomSheet.show(
      context: context,
      title: 'nap_time_range'.tr,
      buttonText: 'save'.tr,
      content: WheelTimePicker(
        initialTime: initial,
        onChanged: (t) => picked = t,
      ),
      onButtonPressed: () {
        onSubmit(picked);
        Get.back();
      },
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral500.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.basic500.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}

// ─── Time field (clock + time + chevron) ─────────────────────────────────────
class _TimeField extends StatelessWidget {
  final String time;
  final VoidCallback onTap;
  const _TimeField({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.basic500.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.basic500.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 18,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.basic500,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.basic500.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
