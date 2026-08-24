import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

/// Star color used for both the filled and (dimmed) empty state.
const Color _kStarColor = Color(0xFFFFC53D);

Future<void> showRateAppDialog(BuildContext context) {
  return PrimaryDialog.show(
    context: context,
    padding: EdgeInsets.zero,
    content: const _RateAppDialogContent(),
  );
}

class _RateAppDialogContent extends StatefulWidget {
  const _RateAppDialogContent();

  @override
  State<_RateAppDialogContent> createState() => _RateAppDialogContentState();
}

class _RateAppDialogContentState extends State<_RateAppDialogContent> {
  /// 0 = chưa chọn sao nào. Mặc định hiển thị 5 sao sáng như thiết kế.
  int _rating = 0;

  int get _effectiveRating => _rating == 0 ? 5 : _rating;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Stack(
      children: [
        AppColumn(
          modifier: Modifier.padding(horizontal: 20, vertical: 28),
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/webp/img_rate_success.webp',
              height: 88,
              width: 88,
              fit: BoxFit.contain,
            ),
            const AppSpacerH(20),
            AppText(
              'rate_dialog_title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: ob.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const AppSpacerH(10),
            AppText(
              'rate_dialog_subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: ob.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const AppSpacerH(20),
            _StarRow(
              rating: _effectiveRating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const AppSpacerH(14),
            AppText(
              'rate_dialog_tap_star'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: ob.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const AppSpacerH(24),
            PrimaryButton(
              text: _rating > 0 && _rating < 5 ? 'send'.tr : 'rate_us_5_stars'.tr,
              useGradient: true,
              autoSizeText: true,
              width: double.infinity,
              height: 48,
              onPressed: _onSubmit,
            ),
            const AppSpacerH(12),
            PrimaryButton(
              text: 'later'.tr,
              outlined: true,
              width: double.infinity,
              height: 48,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        // Nút đóng góc phải trên
        Positioned(
          top: 12,
          right: 12,
          child: _CloseButton(onTap: () => Navigator.of(context).pop()),
        ),
      ],
    );
  }

  void _onSubmit() {
    Get.find<SettingsController>().setRated();
    Navigator.of(context).pop();

    // Dưới 5 sao: đưa người dùng sang màn góp ý thay vì mở store.
    if (_rating > 0 && _rating < 5) {
      Get.toNamed(RouteName.feedback);
      return;
    }

    ToastUtils.showSuccessRatingToast(context);
    _requestReview();
  }

  static Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }
}

// ─── Hàng 5 ngôi sao ────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppRow(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final filled = starIndex <= rating;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 44,
              color: filled
                  ? _kStarColor
                  : _kStarColor.withValues(alpha: 0.35),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Nút đóng ───────────────────────────────────────────────────────────────

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close_rounded, size: 20, color: ob.textSecondary),
      ),
    );
  }
}
