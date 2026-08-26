import 'package:dsp_base/convenience_imports.dart';
import 'package:get/get.dart';
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
    final stored = PrefAssist.getString(
      PrefConst.selectedAvatar,
      defaultValue: PrefDefaults.selectedAvatar,
    );
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

  void save() {
    PrefAssist.setString(PrefConst.selectedAvatar, selectedAvatarId.value);
    savedAvatarId.value = selectedAvatarId.value;
  }
}
