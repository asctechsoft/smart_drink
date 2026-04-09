import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/models/ui_models/article.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final article = Get.arguments as Article?;
    final ob = OnboardingTheme.of(context);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Article not found')),
      );
    }

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation:
              0, // Quan trọng: tắt hiệu ứng đổi màu Material 3 khi scroll
          elevation: 0,
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: AppText(
            article.category,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          article.title.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: ob.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (article.blocks.isNotEmpty)
                        ...article.blocks.map((b) => _buildBlock(context, b))
                      else
                        AppText(
                          article.body,
                          style: TextStyle(
                            fontSize: 15,
                            color: ob.textPrimary,
                            height: 1.7,
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ArticleBlock block) {
    final ob = OnboardingTheme.of(context);
    switch (block.type) {
      // ── Heading ──
      case ArticleBlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                block.text ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ob.textPrimary,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );

      // ── Standalone description paragraph ──
      case ArticleBlockType.descriptionItem:
        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: AppText(
            block.text ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ob.textPrimary.withValues(alpha: 0.7),
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        );

      // ── Full-width image ──
      case ArticleBlockType.image:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              block.imageAsset ?? '',
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: ob.bgToggle,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.image, color: Colors.white38, size: 48),
              ),
            ),
          ),
        );

      // ── Two images side by side ──
      case ArticleBlockType.twoImages:
        Widget imgWidget(String asset) => Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 150,
                decoration: BoxDecoration(
                  color: ob.bgToggle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, color: Colors.white38, size: 36),
              ),
            ),
          ),
        );
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imgWidget(block.imageAsset ?? ''),
              const SizedBox(width: 8),
              imgWidget(block.imageAsset2 ?? ''),
            ],
          ),
        );

      // ── Text left + image right ──
      case ArticleBlockType.textWithImage:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  block.text ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: ob.textPrimary.withValues(alpha: 0.7),
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    block.imageAsset ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 100,
                      color: ob.bgToggle,
                      child: const Icon(Icons.image, color: Colors.white38),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      // ── Bullet list left + image right (image optional) ──
      case ArticleBlockType.bulletsWithImage:
        final hasImage = (block.imageAsset ?? '').isNotEmpty;
        final bulletsColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((block.text ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 4),
                child: Text(
                  block.text!.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ob.textPrimary.withValues(alpha: 0.7),
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ...(block.bulletItems ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Icon(Icons.circle, size: 6, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        item.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: ob.textPrimary.withValues(alpha: 0.7),
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: hasImage
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: bulletsColumn),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          block.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 120,
                            color: ob.bgToggle,
                            child: const Icon(
                              Icons.image,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : bulletsColumn,
        );

      // ── Nested / indented bullet list (child items of a parent bullet) ──
      case ArticleBlockType.nestedBullets:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (block.bulletItems ?? []).map((item) {
            return Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle_outlined,
                      size: 5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      item.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: ob.textPrimary.withValues(alpha: 0.7),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
    }
  }
}

