import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/configs/pref_defaults.dart';
import 'package:waternudge/models/ui_models/avatar_option.dart';

class AvatarController extends GetxController {
  /// Avatar persisted in preferences — what the rest of the app renders.
  final RxString savedAvatarId = AvatarOption.defaultId.obs;

  /// Avatar highlighted on screen; only committed by [save].
  final RxString selectedAvatarId = AvatarOption.defaultId.obs;

  final Rx<AvatarCategory> category = AvatarCategory.humanFigure.obs;

  bool get hasChanges => selectedAvatarId.value != savedAvatarId.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getString(PrefConst.selectedAvatar) ??
        PrefDefaults.selectedAvatar;
    final id = stored.isEmpty ? AvatarOption.defaultId : stored;
    savedAvatarId.value = id;
    selectedAvatarId.value = id;

    for (final option in [
      ...AvatarOption.humanFigures,
      ...AvatarOption.bodyModels,
    ]) {
      if (option.id == id) {
        category.value = option.category;
        break;
      }
    }
  }

  void select(String id) => selectedAvatarId.value = id;

  void setCategory(AvatarCategory value) => category.value = value;

  Future<void> save() async {
    // Update the reactive value synchronously so the UI (and a screen that
    // navigates away right after calling this) sees it immediately; the
    // pref write finishes in the background.
    savedAvatarId.value = selectedAvatarId.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefConst.selectedAvatar, selectedAvatarId.value);
  }
}
