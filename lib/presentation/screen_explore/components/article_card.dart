import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/models/ui_models/article.dart';

import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/values/route_name.dart';
import 'package:get/get.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  static const double _cardWidth = 128;
  static const double _imageHeight = 140;
  static const double _borderRadius = 12;

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return GestureDetector(
      onTap: () => Get.toNamed(RouteName.articleDetail, arguments: article),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: ob.bgReminderPill,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Container(
          width: _cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(
              color: AppColors.basic500.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(4),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                // ── Image ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: _cardWidth,
                    height: _imageHeight,
                    child: article.thumbnailAsset.isNotEmpty
                        ? Image.asset(
                            article.thumbnailAsset,
                            width: _cardWidth,
                            height: _imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                // ── Title ──
                Expanded(
                  child: Center(
                    child: AppText(
                      modifier: Modifier.padding(horizontal: 4, vertical: 2),
                      article.title.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ob.textPrimary,
                        letterSpacing: 0.3,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A3070),
      child: const Icon(Icons.article, size: 40, color: Colors.white38),
    );
  }
}

