import "dart:async";
import "dart:math";

import "package:dsp_base/convenience_imports.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:waternudge/configs/pref_const.dart";
import "package:waternudge/tour/tour_steps.dart";
import "package:waternudge/utils/analytics.dart";

/// Drives the guided tour: which screen-local step is showing and which
/// anchors are mounted. Screens explicitly start their own group when opened;
/// `TourOverlay` renders whatever this permanent GetX controller exposes.
///
/// Ported from `docs/guided-tour-ab-logging.md` (Money Management's guided
/// tour). One deliberate change from that reference: events there encode the
/// A/B branch *in the event name* (`report_variant2_step1_view`); here the
/// branch is a `variant` parameter on one event name instead
/// (`tour_today_step1_view` + `{variant: plain}`), which is the GA4-idiomatic
/// shape and halves the distinct-event-name cost against the 500/project cap.
class TourController extends GetxController {
  TourController({String Function()? readVariant})
    : _readVariant = readVariant ?? _readVariantFromRemoteConfig;

  static const String rcVariantKey = "TOUR_VARIANT";

  /// Current visuals: the target clone scales up in place (pulsing) on the
  /// step that supplies a `spotlightBuilder`.
  static const String variantPulse = "pulse";

  /// Lighter-weight alternative: every step gets a plain highlight hole, no
  /// clone/pulse animation. Worth A/B testing on weaker devices — see
  /// `CommFigs.IS_WEAK_DEVICE`.
  static const String variantPlain = "plain";

  final String Function() _readVariant;

  final RxBool active = false.obs;
  final RxInt index = 0.obs;
  final RxString variant = variantPulse.obs;

  /// Anchor keys by id; screens register through `TourAnchor`.
  final Map<String, GlobalKey> anchors = <String, GlobalKey>{};

  /// Bumped whenever an anchor registers so the overlay re-measures.
  final RxInt anchorGeneration = 0.obs;

  TourStep get step => tourSteps[index.value];
  List<TourStep> get steps => tourSteps;

  /// Today's tour has not been seen yet. Reuses the pref key the previous
  /// ad-hoc `showCoachMarks` walkthrough used, so an install that already
  /// dismissed it does not see it again.
  Future<bool> get shouldStart async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(PrefConst.coachMarkHomeSeen) ?? false);
  }

  Future<bool> shouldStartGroup(TourGroup group) => shouldStart;

  /// Anchors register from `initState`, i.e. mid-build; the Rx bump is
  /// deferred to the end of the frame so the overlay's Obx never gets a
  /// setState-during-build.
  void registerAnchor(String id, GlobalKey key) {
    anchors[id] = key;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => anchorGeneration.value++,
    );
  }

  /// Resolves once [id] is registered, or after [timeout].
  Future<bool> waitForAnchor(
    String id, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!anchors.containsKey(id)) {
      if (DateTime.now().isAfter(deadline)) return false;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return true;
  }

  void unregisterAnchor(String id, GlobalKey key) {
    if (anchors[id] == key) anchors.remove(id);
  }

  /// Global rect of the anchor, or null while it is not laid out.
  Rect? anchorRect(String id) {
    final context = anchors[id]?.currentContext;
    final box = context?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<bool> start() => startGroup(TourGroup.today);

  /// Starts only the guide belonging to [group]. Other screens (once this
  /// tour grows a second group) remain pending until opened explicitly.
  Future<bool> startGroup(TourGroup group) async {
    if (active.value || !(await shouldStartGroup(group))) return false;
    final firstIndex = tourSteps.indexWhere(
      (candidate) => candidate.group == group,
    );
    if (firstIndex < 0) return false;
    final configured = _readVariant().trim().toLowerCase();
    variant.value = configured == variantPlain ? variantPlain : variantPulse;
    Analytics.userTourVariant(variant.value);
    if (!await waitForAnchor(tourSteps[firstIndex].anchorId)) return false;
    index.value = firstIndex;
    active.value = true;
    _logStepView();
    return true;
  }

  Future<void> next() async {
    if (!active.value) return;
    _logStepAction(step.isLastInGroup ? "gotit_tap" : "next_tap");
    if (step.isLastInGroup) {
      await complete();
      return;
    }
    index.value++;
    _logStepView();
  }

  Future<void> previous() async {
    if (!active.value || step.isFirstInGroup) return;
    _logStepAction("previous_tap");
    index.value = index.value - 1;
    _logStepView();
  }

  Future<void> skip() async {
    if (!active.value) return;
    _logStepAction("close_tap");
    await _finish();
  }

  Future<void> complete() async {
    if (!active.value) return;
    await _finish();
  }

  Future<void> _finish() async {
    active.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConst.coachMarkHomeSeen, true);
  }

  void _logStepView() => _logStepAction("view");

  /// Every caller funnels through here and supplies only its own action
  /// suffix — never the screen or step index, which come from `step` itself.
  /// One event name per step/action; the A/B branch rides as a parameter.
  void _logStepAction(String action) {
    Analytics.track("tour_today_step${step.groupIndex}_$action", {
      "variant": variant.value,
    });
  }

  static String _readVariantFromRemoteConfig() =>
      RconfAssist.getString(rcVariantKey);

  /// Local A/B split until the Remote Config experiment exists: picks
  /// [variantPulse] or [variantPlain] once per install and pins it through
  /// `RconfAssist`'s test override. That override is itself gated on
  /// `CommFigs.IS_SHOW_TEST_OPTION`, so this is a no-op on the Product
  /// release build — shipping it cannot overwrite a real experiment.
  static Future<void> assignLocalVariant({Random? random}) async {
    final prefs = await SharedPreferences.getInstance();
    var assigned = prefs.getString(PrefConst.tourAbVariant) ?? '';
    if (assigned.isEmpty) {
      assigned = (random ?? Random()).nextBool() ? variantPlain : variantPulse;
      await prefs.setString(PrefConst.tourAbVariant, assigned);
    }
    RconfAssist.setTestString(rcVariantKey, assigned);
  }
}
