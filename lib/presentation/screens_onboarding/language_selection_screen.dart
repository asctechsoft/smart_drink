import 'dart:async';

import 'package:asc_common/asc_common.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:waternudge/configs/ads_config.dart';
import 'package:waternudge/controller/languages_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/selectable_option_tile.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
import 'package:waternudge/services/app_localize.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:waternudge/utils/language_names.dart';
import 'package:waternudge/values/app_colors.dart';
import 'package:waternudge/values/route_name.dart';

/// First-run language picker, shown between the splash and the welcome screen.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguagesController controller = Get.find<LanguagesController>();

  /// Ordered once so picking a language never reshuffles the list under the
  /// user's finger.
  late final List<Locale> _locales = _orderedLocales();

  /// Gates the "Next" link. `currentAppLocale` already defaults to the
  /// system/current locale (never null), so this can't just be "a locale is
  /// selected" — it only flips once the pick-to-reveal delay below elapses,
  /// giving the native ad a moment to load before Next appears next to it.
  bool _canContinue = false;
  Timer? _continueDelay;

  /// Native ad docked below the list — always occupies [_adHeight], loaded
  /// or not, so the layout never jumps once it comes in. Snug to the actual
  /// card's own (compact, `wrap_content`) natural height — a taller box just
  /// leaves dead space below the card, the card itself never stretches.
  static const double _adHeight = 160;

  /// Two separate ad units for the same slot — "lan1" before a language is
  /// picked, "lan2" the instant one is. Both preloaded up front so the swap
  /// on pick is immediate, not another cold load.
  late final AscNativeAdService _lan1;
  late final AscNativeAdService _lan2;
  bool _lan1Loaded = false;
  bool _lan2Loaded = false;

  /// Flips instantly on pick — swaps which ad renders. Separate from
  /// [_canContinue], which only flips after the 3s reveal delay below.
  bool _hasPickedOnce = false;

  @override
  void initState() {
    super.initState();
    _lan1 = AscNativeAdService(
      adUnitId: AdsConfig.languageBeforePickNativeAdUnitId,
      factoryId: AdsConfig.nativeAdFactoryId,
    );
    _lan2 = AscNativeAdService(
      adUnitId: AdsConfig.languageAfterPickNativeAdUnitId,
      factoryId: AdsConfig.nativeAdFactoryId,
    );
    _loadNativeAd(_lan1, onLoaded: () => setState(() => _lan1Loaded = true));
    _loadNativeAd(_lan2, onLoaded: () => setState(() => _lan2Loaded = true));
  }

  Future<void> _loadNativeAd(
    AscNativeAdService service, {
    required VoidCallback onLoaded,
  }) async {
    if (AscAdsConfig.isHideAd) return;
    await service.load();
    if (mounted && service.isLoaded) onLoaded();
  }

  @override
  void dispose() {
    _continueDelay?.cancel();
    _lan1.dispose();
    _lan2.dispose();
    super.dispose();
  }

  void _pickLocale(Locale locale) {
    controller.changeLanguage(locale);
    _onPicked();
  }

  void _pickSystemDefault() {
    controller.useSystemDefault();
    _onPicked();
  }

  void _onPicked() {
    if (!_hasPickedOnce) setState(() => _hasPickedOnce = true);
    // Restarts on every pick — matches "reveal Next a few seconds after the
    // most recent choice", not "a few seconds after first ever touching
    // the list".
    _continueDelay?.cancel();
    _continueDelay = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _canContinue = true);
    });
  }

  void _onNextTap() {
    Analytics.onboardingNext('language');
    Get.offNamed(RouteName.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StaggerColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "Next" floats over the list (bottom-right), never over the
              // ad below — a separate Column sibling, so there's no chance
              // of it sitting near/on the ad's own tap area.
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: Obx(() {
                            final current = controller.currentAppLocale.value;
                            final isSystemDefault =
                                controller.isSystemDefault.value;
                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                4,
                                20,
                                24,
                              ),
                              itemCount: _locales.length + 1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _SystemDefaultTile(
                                    isSelected: isSystemDefault,
                                    onTap: _pickSystemDefault,
                                  );
                                }
                                final locale = _locales[index - 1];
                                return _LanguageTile(
                                  locale: locale,
                                  isSelected:
                                      !isSystemDefault && locale == current,
                                  onTap: () => _pickLocale(locale),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _canContinue
                            ? GestureDetector(
                                key: const ValueKey('next'),
                                behavior: HitTestBehavior.opaque,
                                onTap: _onNextTap,
                                child: Text(
                                  'next'.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.basic500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                    ),
                  ],
                ),
              ),
              // Reserves _adHeight regardless of load state — the ad card
              // fades in once ready, but the layout never jumps.
              Container(
                height: _adHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.basic500.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: _hasPickedOnce
                    ? (_lan2Loaded
                          ? _lan2.render(height: _adHeight - 24)
                          : const SizedBox.shrink())
                    : (_lan1Loaded
                          ? _lan1.render(height: _adHeight - 24)
                          : const SizedBox.shrink()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Suggested locales (device, region, history) float to the top so the most
  /// likely pick is the first row.
  List<Locale> _orderedLocales() {
    final suggested = controller.getSuggestedLocales();
    final seen = suggested.map((l) => l.toString()).toSet();
    return [
      ...suggested,
      ...AppLocalize.supportedLocales.where(
        (l) => !seen.contains(l.toString()),
      ),
    ];
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 20, 20),
      child: Text(
        'language'.tr,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.basic500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SystemDefaultTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _SystemDefaultTile({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final resolved = AppLocalize.bestSupportedMatchFor(
      AppLocalize.getSystemLocale(),
    );
    const radius = BorderRadius.all(Radius.circular(16));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutral500.withValues(alpha: isSelected ? 0.3 : 0.22),
        borderRadius: radius,
        border: Border.all(
          color: isSelected
              ? AppColors.primary500Dark
              : AppColors.basic500.withValues(alpha: 0.14),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary500Dark.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.primary500Dark.withValues(alpha: 0.22),
          highlightColor: AppColors.basic500.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.basic500.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: AppColors.basic500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'system_default_language'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.basic500,
                        ),
                      ),
                      Text(
                        AppLocalize.getLocaleName(resolved),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.basic500.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                RadioMark(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutral500.withValues(alpha: isSelected ? 0.3 : 0.22),
        borderRadius: radius,
        border: Border.all(
          color: isSelected
              ? AppColors.primary500Dark
              : AppColors.basic500.withValues(alpha: 0.14),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary500Dark.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      // The decoration (incl. the selected glow) stays on the DecoratedBox;
      // the Material only carries the ink, clipped to the same radius so the
      // ripple follows the rounded corners. The whole row is the tap target,
      // radio mark included.
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.primary500Dark.withValues(alpha: 0.22),
          highlightColor: AppColors.basic500.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CountryFlag.fromCountryCode(
                    locale.countryCode ?? '',
                    width: 42,
                    height: 30,
                    shape: const RoundedRectangle(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LanguageNames.nativeName(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.basic500,
                        ),
                      ),
                      Text(
                        AppLocalize.getLocaleName(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.basic500.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                RadioMark(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
