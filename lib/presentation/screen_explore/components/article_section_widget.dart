import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/models/ui_models/article.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'article_card.dart';

class ArticleSectionWidget extends StatelessWidget {
  final ArticleSection section;

  const ArticleSectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacerH8,
        AppText(
          modifier: Modifier.padding(horizontal: 16, vertical: 12),
          section.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ob.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: section.articles.length,
            itemBuilder: (ctx, i) => ArticleCard(article: section.articles[i]),
          ),
        ),
      ],
    );
  }
}

