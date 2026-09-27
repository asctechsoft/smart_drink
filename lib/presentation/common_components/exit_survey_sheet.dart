import 'package:asc_common/asc_common.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/configs/ads_config.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/selectable_option_tile.dart'
    show RadioMark;
import 'package:waternudge/utils/analytics.dart';

/// Shown when the user backs out of Home (see `HomeScreen`'s `PopScope`) —
/// a short "why are you leaving?" survey with a Native Ad, gating the actual
/// app exit behind an explicit choice instead of exiting immediately.
///
/// Returns `true` if the user chose to exit anyway, `false` if they picked
/// "Stay" or dismissed the sheet (swipe-down/tap-outside) — either way,
/// caller decides what "true" means (typically `SystemNavigator.pop()`).
Future<bool> showExitSurveySheet(BuildContext context) async {
  Analytics.exitSurveyShown();
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ExitSurveySheetContent(),
  );
  return result ?? false;
}

class _ExitSurveySheetContent extends StatefulWidget {
  const _ExitSurveySheetContent();

  @override
  State<_ExitSurveySheetContent> createState() =>
      _ExitSurveySheetContentState();
}

class _ExitSurveySheetContentState extends State<_ExitSurveySheetContent> {
  static const _reasons = [
    'exit_survey_reason_ads',
    'exit_survey_reason_not_useful',
    'exit_survey_reason_bug',
    'exit_survey_reason_other',
  ];

  String? _selectedReason;

  void _selectReason(String reason) {
    setState(() => _selectedReason = reason);
    Analytics.exitSurveyReasonSelect(reason);
  }

  void _onStay() {
    Analytics.exitSurveyStay();
    Navigator.of(context).pop(false);
  }

  void _onExit() {
    Analytics.exitSurveyExit();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A2556),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'exit_survey_title'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          AppSpacerH8,
          AppText(
            'exit_survey_subtitle'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          AppSpacerH16,
          for (final reason in _reasons) ...[
            _ReasonRow(
              label: reason.tr,
              isSelected: _selectedReason == reason,
              onTap: () => _selectReason(reason),
            ),
            AppSpacerH8,
          ],
          AppSpacerH8,
          AscNativeAdView.factory(
            adUnitId: AdsConfig.exitSurveyNativeAdUnitId,
            factoryId: AdsConfig.nativeAdFactoryId,
            height: 150,
          ),
          AppSpacerH16,
          PrimaryButton(
            text: 'exit_survey_stay'.tr,
            useGradient: true,
            width: double.infinity,
            height: 48,
            onPressed: _onStay,
          ),
          AppSpacerH12,
          PrimaryButton(
            text: 'exit_survey_exit'.tr,
            outlined: true,
            width: double.infinity,
            height: 48,
            onPressed: _onExit,
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: isSelected ? 0.12 : 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              RadioMark(isSelected: isSelected, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
