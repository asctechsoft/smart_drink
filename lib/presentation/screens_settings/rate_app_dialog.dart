import 'dart:math' as math;

import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/settings_controller.dart';
import 'package:waternudge/presentation/common_components/primary_button.dart';
import 'package:waternudge/presentation/common_components/primary_dialog.dart';
import 'package:waternudge/utils/toast_utils.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:waternudge/values/onboarding_theme.dart';
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

class _RateAppDialogContentState extends State<_RateAppDialogContent>
    with SingleTickerProviderStateMixin {
  /// 0 = chưa chọn sao nào. Mặc định hiển thị 5 sao sáng như thiết kế.
  int _rating = 0;

  late final AnimationController _fillController;

  /// Drives the intro sweep that lights the five stars one after another.
  ///
  /// The [Interval] holds it at 0 for the first fifth, which lets the dialog
  /// finish animating in before the first star lights — starting on frame one
  /// hides the sweep behind the dialog's own entrance.
  late final Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fill = CurvedAnimation(
      parent: _fillController,
      curve: const Interval(0.2, 1),
    );
    _fillController.forward();
  }

  @override
  void dispose() {
    _fillController.dispose();
    super.dispose();
  }

  void _onStarTapped(int value) {
    // Freeze the sweep the moment the user takes over, so their choice isn't
    // fighting the animation for the same stars.
    _fillController.stop();
    setState(() => _rating = value);
  }

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
            _StarRow(rating: _rating, sweep: _fill, onChanged: _onStarTapped),
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
              text: _rating > 0 && _rating < 5
                  ? 'send'.tr
                  : 'rate_us_5_stars'.tr,
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
  const _StarRow({
    required this.rating,
    required this.sweep,
    required this.onChanged,
  });

  /// The user's pick, or 0 while the intro sweep still owns the row.
  final int rating;

  /// 0–1 across the whole five-star sweep.
  final Animation<double> sweep;

  final ValueChanged<int> onChanged;

  static const _starCount = 5;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sweep,
      builder: (context, _) => AppRow(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_starCount, (index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(index + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _Star(fill: _fillFor(index)),
            ),
          );
        }),
      ),
    );
  }

  /// How lit star [index] is, 0–1.
  ///
  /// Once the user has picked, their rating wins outright; until then each star
  /// owns one fifth of the sweep, so they light strictly one after another
  /// instead of fading up together.
  double _fillFor(int index) {
    if (rating > 0) return index < rating ? 1 : 0;
    return (sweep.value * _starCount - index).clamp(0.0, 1.0);
  }
}

/// One star, cross-fading from outline to solid as [fill] goes 0 to 1, with a
/// scale pop peaking mid-fill so it reads as lighting up rather than just
/// changing colour.
class _Star extends StatelessWidget {
  const _Star({required this.fill});

  final double fill;

  static const _size = 44.0;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + 0.3 * math.sin(math.pi * fill),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: _size,
            color: _kStarColor.withValues(alpha: 0.35 * (1 - fill)),
          ),
          Opacity(
            opacity: fill,
            child: const Icon(
              Icons.star_rounded,
              size: _size,
              color: _kStarColor,
            ),
          ),
        ],
      ),
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
