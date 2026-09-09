import 'package:dsp_base/app_material.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/values/onboarding_theme.dart';
import 'package:get/get.dart';

// Same circular back-button styling as the feedback screen's sticky top bar.
const _kIconBg = Color(0x1FFFFFFF); // white 12%
const _kIconBorder = Color(0x33FFFFFF); // white 20%

/// One section of the policy: a bold sub-heading and its paragraph body.
class _PolicySection {
  final String titleKey;
  final String bodyKey;
  const _PolicySection(this.titleKey, this.bodyKey);
}

const _kSections = [
  _PolicySection('privacy_section_info_title', 'privacy_section_info_body'),
  _PolicySection('privacy_section_use_title', 'privacy_section_use_body'),
  _PolicySection(
    'privacy_section_storage_title',
    'privacy_section_storage_body',
  ),
  _PolicySection('privacy_section_ads_title', 'privacy_section_ads_body'),
  _PolicySection(
    'privacy_section_children_title',
    'privacy_section_children_body',
  ),
  _PolicySection('privacy_section_rights_title', 'privacy_section_rights_body'),
  _PolicySection(
    'privacy_section_changes_title',
    'privacy_section_changes_body',
  ),
  _PolicySection(
    'privacy_section_contact_title',
    'privacy_section_contact_body',
  ),
];

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: Material(
              color: _kIconBg,
              shape: CircleBorder(side: BorderSide(color: _kIconBorder)),
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
          centerTitle: true,
          title: AppText(
            'privacy_policy_nav_title'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              AppText(
                'privacy_policy_title'.tr,
                style: TextStyle(
                  color: ob.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacerH(8),
              AppText(
                'privacy_last_updated'.tr,
                style: TextStyle(
                  color: ob.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacerH(20),
              AppText(
                'privacy_intro'.tr,
                style: TextStyle(
                  color: ob.textSecondary,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
              AppSpacerH(28),
              for (final section in _kSections) ...[
                AppText(
                  section.titleKey.tr,
                  style: TextStyle(
                    color: ob.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacerH(8),
                AppText(
                  section.bodyKey.tr,
                  style: TextStyle(
                    color: ob.textSecondary,
                    fontSize: 14.5,
                    height: 1.55,
                  ),
                ),
                AppSpacerH(24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
