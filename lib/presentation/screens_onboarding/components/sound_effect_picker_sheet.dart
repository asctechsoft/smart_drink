import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/onboarding_controller.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/presentation/common_components/primary_bottom_sheet.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundEffectPickerSheet extends StatefulWidget {
  final OnboardingController controller;

  const SoundEffectPickerSheet({super.key, required this.controller});

  static void show(BuildContext context, OnboardingController controller) {
    PrimaryBottomSheet.show(
      context: context,
      title: 'sound_effect'.tr,
      showSubmitButton: false,
      content: SoundEffectPickerSheet(controller: controller),
    );
  }

  @override
  State<SoundEffectPickerSheet> createState() => _SoundEffectPickerSheetState();
}

class _SoundEffectPickerSheetState extends State<SoundEffectPickerSheet> {
  final AudioPlayer _player = AudioPlayer();

  final sounds = [
    {'name': 'golden_bell'.tr, 'file': 'dragon_studio_correct'},
    {
      'name': 'dragon_bloom'.tr,
      'file': 'dragon_studio_notification_sound_effect',
    },
    {'name': 'sparkle_pop'.tr, 'file': 'universfield_new_notification'},
    {'name': 'modern_chime'.tr, 'file': 'universfield_notification'},
    {'name': 'system_soft'.tr, 'file': 'universfield_system_notification'},
  ];

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _buildRadio(bool selected) {
    final ob = OnboardingTheme.of(context);
    return AppBoxCentered(
      modifier: Modifier.width(
        20,
      ).height(20).border(width: 1, color: ob.switchActive, radius: 100),
      children: [
        if (selected)
          AppBox(
            modifier: Modifier.width(
              8,
            ).height(8).background(color: ob.switchActive, radius: 100),
            children: const [],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);

    return AppColumn(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => AppColumn(
            mainAxisSize: MainAxisSize.min,
            children: sounds.asMap().entries.map((entry) {
              final index = entry.key;
              final sound = entry.value;
              final isSelected =
                  widget.controller.soundEffect.value == sound['file'];
              return AppColumn(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0)
                    Divider(height: 1, thickness: 1, color: ob.divider),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        widget.controller.soundEffect.value = sound['file']!;
                        _player.play(AssetSource('audio/${sound['file']}.mp3'));
                      },
                      child: AppRow(
                        modifier: Modifier.padding(
                          horizontal: 12,
                          vertical: 20,
                        ),
                        children: [
                          Expanded(
                            child: AppText(
                              sound['name']!,
                              style: TextStyle(
                                color: ob.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _buildRadio(isSelected),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const AppSpacerH(24),
        PrimaryButton(
          text: 'save'.tr,
          width: double.infinity,
          useGradient: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

