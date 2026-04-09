// Types of content blocks in an article
enum ArticleBlockType {
  heading,
  image,
  twoImages, // two images side by side
  textWithImage,
  bulletsWithImage,
  nestedBullets, // sub-bullet list, indented 16px extra (child of previous bullet)
  descriptionItem,
}

class ArticleBlock {
  final ArticleBlockType type;
  final String? text;
  final String? description; // optional subtitle below heading
  final List<String>?
  descriptionItems; // description as list (each item = one line)
  final String? imageAsset;
  final String? imageAsset2; // second image (used by twoImages block)
  final List<String>? bulletItems;

  const ArticleBlock._({
    required this.type,
    this.text,
    this.description,
    this.descriptionItems,
    this.imageAsset,
    this.imageAsset2,
    this.bulletItems,
  });

  /// Bold section heading with optional description below.
  /// Use [description] for a plain string or [descriptionItems] for a list (each item = one line).
  const ArticleBlock.heading(
    String t, {
    String? description,
    List<String>? descriptionItems,
  }) : this._(
         type: ArticleBlockType.heading,
         text: t,
         description: description,
         descriptionItems: descriptionItems,
       );

  /// Full-width image
  const ArticleBlock.image(String asset)
    : this._(type: ArticleBlockType.image, imageAsset: asset);

  /// Two images side by side (equal width, rounded corners)
  const ArticleBlock.twoImages(String asset1, String asset2)
    : this._(
        type: ArticleBlockType.twoImages,
        imageAsset: asset1,
        imageAsset2: asset2,
      );

  /// Text on the left, small image on the right.
  /// [asset] is optional — if omitted, the text fills full width.
  const ArticleBlock.textWithImage(String t, {String? asset})
    : this._(type: ArticleBlockType.textWithImage, text: t, imageAsset: asset);

  /// Label text + bullet list on the left, image on the right
  /// [t] = label above bullets (e.g. "Best options:")
  const ArticleBlock.bulletsWithImage(
    String t,
    List<String> items, {
    String? asset,
  }) : this._(
         type: ArticleBlockType.bulletsWithImage,
         text: t,
         bulletItems: items,
         imageAsset: asset,
       );

  /// Nested / indented bullet list — child items of a previous bullet.
  /// Renders with extra 16px left indent compared to [bulletsWithImage].
  const ArticleBlock.nestedBullets(List<String> items)
    : this._(type: ArticleBlockType.nestedBullets, bulletItems: items);

  /// A standalone descriptive text paragraph (e.g. notes, tips, warnings).
  const ArticleBlock.descriptionItem(String t)
    : this._(type: ArticleBlockType.descriptionItem, text: t);
}

class Article {
  final String id;
  final String title;
  final String body;
  final String category;
  final String thumbnailAsset;
  final List<ArticleBlock> blocks;

  const Article({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.thumbnailAsset = '',
    this.blocks = const [],
  });
}

class ArticleSection {
  final String title;
  final List<Article> articles;

  const ArticleSection({required this.title, required this.articles});
}

