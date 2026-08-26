import 'package:country_flags/country_flags.dart';
import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/app_material.dart';
import 'package:get/get.dart';
import 'package:waternudge/controller/languages_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/presentation/common_components/selectable_option_tile.dart';
import 'package:waternudge/presentation/common_components/stagger_reveal.dart';
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

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StaggerColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(() {
                  final current = controller.currentAppLocale.value;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: _locales.length,
                    separatorBuilder: (_, _) => AppSpacerH12,
                    itemBuilder: (context, index) {
                      final locale = _locales[index];
                      return _LanguageTile(
                        locale: locale,
                        isSelected: locale == current,
                        onTap: () => controller.changeLanguage(locale),
                      );
                    },
                  );
                }),
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
      ...CommLocalize.supportedLocales.where(
        (l) => !seen.contains(l.toString()),
      ),
    ];
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 20, 20),
      child: AppRow(
        children: [
          Expanded(
            child: AppText(
              'language'.tr,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.basic500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          _ConfirmButton(onTap: () => Get.offNamed(RouteName.welcome)),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.basic500.withValues(alpha: 0.12),
          border: Border.all(
            color: AppColors.basic500.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: const Icon(Icons.check, size: 20, color: AppColors.basic500),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.neutral500.withValues(alpha: isSelected ? 0.3 : 0.22),
          borderRadius: BorderRadius.circular(16),
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
        child: AppRow(
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
            AppSpacerW16,
            Expanded(
              child: AppColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    LanguageNames.nativeName(locale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.basic500,
                    ),
                  ),
                  AppText(
                    CommLocalize.getLocaleName(locale),
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
            AppSpacerW12,
            RadioMark(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
