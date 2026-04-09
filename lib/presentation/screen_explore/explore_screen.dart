import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'components/article_section_widget.dart';
import 'components/explore_data.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
          centerTitle: true,
          title: AppText(
            'explore'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 0 + 10,
          ),
          child: SafeArea(
            bottom: false,
            child: AppColumn(
              children: [
                Expanded(
                  child: Builder(builder: (context) {
                    final sections = getArticleSections();
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: sections.length,
                      itemBuilder: (ctx, i) =>
                          ArticleSectionWidget(section: sections[i]),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

