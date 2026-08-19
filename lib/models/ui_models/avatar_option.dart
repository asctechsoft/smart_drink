/// The two families of figures shown on the avatar picker.
enum AvatarCategory {
  /// Stylised human silhouette (the outlined figure used by the water gauge).
  humanFigure,

  /// Illustrated body types wearing clothes.
  bodyModel,
}

/// One selectable figure on the avatar picker.
///
/// [asset] is intentionally nullable: the artwork is still being produced, so
/// an option without one renders as an empty placeholder card.
class AvatarOption {
  final String id;
  final AvatarCategory category;
  final String? asset;

  const AvatarOption({required this.id, required this.category, this.asset});

  static const List<AvatarOption> humanFigures = [
    AvatarOption(id: 'human_1', category: AvatarCategory.humanFigure),
    AvatarOption(id: 'human_2', category: AvatarCategory.humanFigure),
    AvatarOption(id: 'human_3', category: AvatarCategory.humanFigure),
    AvatarOption(id: 'human_4', category: AvatarCategory.humanFigure),
    AvatarOption(id: 'human_5', category: AvatarCategory.humanFigure),
    AvatarOption(id: 'human_6', category: AvatarCategory.humanFigure),
  ];

  static const List<AvatarOption> bodyModels = [
    AvatarOption(id: 'body_1', category: AvatarCategory.bodyModel),
    AvatarOption(id: 'body_2', category: AvatarCategory.bodyModel),
    AvatarOption(id: 'body_3', category: AvatarCategory.bodyModel),
    AvatarOption(id: 'body_4', category: AvatarCategory.bodyModel),
    AvatarOption(id: 'body_5', category: AvatarCategory.bodyModel),
    AvatarOption(id: 'body_6', category: AvatarCategory.bodyModel),
  ];

  static List<AvatarOption> byCategory(AvatarCategory category) =>
      category == AvatarCategory.humanFigure ? humanFigures : bodyModels;

  /// Artwork for [id], or `null` while that figure has none yet.
  static String? assetFor(String id) {
    for (final option in [...humanFigures, ...bodyModels]) {
      if (option.id == id) return option.asset;
    }
    return null;
  }

  static const String defaultId = 'human_1';
}
