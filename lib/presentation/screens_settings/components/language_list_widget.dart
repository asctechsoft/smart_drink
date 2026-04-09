import 'package:dsp_base/app_localize.dart';
import 'package:dsp_base/app_material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:smartdrinkai/controller/languages_controller.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageListWidget extends StatelessWidget {
  final String searchQuery;

  const LanguageListWidget({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final LanguagesController controller = Get.find<LanguagesController>();
    final ob = OnboardingTheme.of(context);

    return Obx(() {
      // Force Obx to track the language change
      final _ = controller.currentAppLocale.value;

      final suggestedLanguages = controller.getSuggestedLocales();
      const allLanguages = CommLocalize.supportedLocales;
      final query = searchQuery.toLowerCase();

      final filteredSuggested = query.isEmpty
          ? suggestedLanguages
          : suggestedLanguages
                .where((l) => _localeMatchesQuery(l, query))
                .toList();
      final filteredAll = query.isEmpty
          ? allLanguages
          : allLanguages.where((l) => _localeMatchesQuery(l, query)).toList();

      final hasNoResults =
          query.isNotEmpty && filteredSuggested.isEmpty && filteredAll.isEmpty;

      if (hasNoResults) {
        return Center(
          child: AppText(
            modifier: Modifier.paddingAll(24),
            'no_matching_language_found'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: ob.textrReminderCountdown, fontSize: 15),
          ),
        );
      }

      final List<Widget Function(BuildContext)> builders = [];

      if (filteredSuggested.isNotEmpty) {
        builders.add(
          (context) => AppText(
            'recent_languages'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: ob.textPrimary,
            ),
          ),
        );
        builders.add((context) => AppSpacerH(12));
        for (int i = 0; i < filteredSuggested.length; i++) {
          final locale = filteredSuggested[i];
          builders.add(
            (context) => _buildLanguageItem(
              context,
              locale,
              controller: controller,
              ob: ob,
            ),
          );
          if (i < filteredSuggested.length - 1) {
            builders.add(
              (context) => Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Divider(height: 1, color: ob.bgOnboarding),
              ),
            );
          }
        }
        builders.add((context) => const SizedBox(height: 16));
      }

      if (filteredAll.isNotEmpty) {
        builders.add(
          (context) => AppText(
            'all_languages'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: ob.textPrimary,
            ),
          ),
        );
        builders.add((context) => AppSpacerH(12));
        for (int i = 0; i < filteredAll.length; i++) {
          final locale = filteredAll[i];
          builders.add(
            (context) => _buildLanguageItem(
              context,
              locale,
              controller: controller,
              ob: ob,
              hideCheckmark: true,
            ),
          );
          if (i < filteredAll.length - 1) {
            builders.add(
              (context) => Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Divider(height: 1, color: ob.bgOnboarding),
              ),
            );
          }
        }
        builders.add((context) => const SizedBox(height: 8));
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: builders.length,
        itemBuilder: (context, index) => builders[index](context),
      );
    });
  }

  bool _localeMatchesQuery(Locale l, String query) {
    if (query.isEmpty) return true;
    return CommLocalize.getLocaleName(l).toLowerCase().contains(query);
  }

  Widget _buildLanguageItem(
    BuildContext context,
    Locale locale, {
    required LanguagesController controller,
    required OnboardingTheme ob,
    bool hideCheckmark = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          controller.changeLanguage(locale);
        },
        child: Obx(() {
          final isSelected = locale == controller.currentAppLocale.value;
          return AppRow(
            modifier: Modifier.padding(horizontal: 16, vertical: 14),
            children: [
              CountryFlag.fromCountryCode(
                locale.countryCode ?? '',
                width: 28,
                height: 28,
                shape: const Circle(),
              ),
              AppSpacerW(16),
              Expanded(
                child: AppText(
                  CommLocalize.getLocaleName(locale),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ob.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected && !hideCheckmark)
                AppIcon('assets/images/svg/ic_check_circle.svg', size: 24),
            ],
          );
        }),
      ),
    );
  }
}

