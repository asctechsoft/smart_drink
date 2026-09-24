import 'package:flutter/widgets.dart';
import 'package:waternudge/presentation/screen_today/components/drink_action_bar.dart';

/// Anchor ids the guided tour highlights. Screens wrap the matching widget in
/// a [TourAnchor] with one of these ids.
class TourAnchors {
  TourAnchors._();

  static const String todayDrinkBar = 'today_drink_bar';
  static const String todayDrinkType = 'today_drink_type';
  static const String todayChat = 'today_chat';
}

/// Screen-local groups. A group starts only when its screen is opened. Today
/// has one group; the shape is kept so a second screen's tour can be added
/// the same way — see `docs/guided-tour-ab-logging.md` for the pattern this
/// was ported from.
enum TourGroup { today }

class TourStep {
  TourStep({
    required this.id,
    required this.anchorId,
    required this.textKey,
    required this.group,
    required this.groupIndex,
    required this.groupSize,
    this.titleKey,
    this.radius = 18,
    this.spotlightBuilder,
  });

  final String id;
  final String anchorId;

  /// Localization key for the callout body.
  final String textKey;

  /// Localization key for the callout title, or null for a body-only card.
  final String? titleKey;
  final TourGroup group;

  /// 1-based position inside the screen group ("2/3" in the card footer).
  final int groupIndex;
  final int groupSize;

  /// Corner radius of the spotlight cutout. Use a large value for pill buttons.
  final double radius;

  /// Optional: a fresh copy of the target widget. When set (and the variant
  /// is [TourController.variantPulse]), the overlay paints it scaled-up
  /// (pulsing) in place instead of a plain hole, so the button itself appears
  /// to grow.
  final Widget Function()? spotlightBuilder;

  bool get isFirstInGroup => groupIndex == 1;
  bool get isLastInGroup => groupIndex == groupSize;
}

/// The Today tour: drink pill → drink-type card → AI chat shortcut. Ported
/// from the ad-hoc `showCoachMarks` walkthrough that used to live directly in
/// `TodayScreen`.
final List<TourStep> tourSteps = [
  TourStep(
    id: 'today_drink',
    anchorId: TourAnchors.todayDrinkBar,
    textKey: 'coach_drink',
    group: TourGroup.today,
    groupIndex: 1,
    groupSize: 3,
    radius: 999, // pill
    spotlightBuilder: () => const DrinkActionBar(),
  ),
  TourStep(
    id: 'today_drink_type',
    anchorId: TourAnchors.todayDrinkType,
    textKey: 'coach_menu',
    group: TourGroup.today,
    groupIndex: 2,
    groupSize: 3,
    radius: 16,
  ),
  TourStep(
    id: 'today_chat',
    anchorId: TourAnchors.todayChat,
    textKey: 'coach_chat',
    group: TourGroup.today,
    groupIndex: 3,
    groupSize: 3,
    radius: 12,
  ),
];
