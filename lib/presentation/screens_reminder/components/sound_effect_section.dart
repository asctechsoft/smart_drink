import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/reminder_controller.dart';
import 'package:smartdrinkai/presentation/common_components/custom_switch.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundEffectSection extends StatefulWidget {
  final ReminderController controller;

  const SoundEffectSection({super.key, required this.controller});

  @override
  State<SoundEffectSection> createState() => _SoundEffectSectionState();
}

class _SoundEffectSectionState extends State<SoundEffectSection> {
  bool _expanded = false;
  final AudioPlayer _player = AudioPlayer();

  final List<Map<String, String>> _sounds = [
    {'name': 'golden_bell', 'file': 'dragon_studio_correct'},
    {'name': 'dragon_bloom', 'file': 'dragon_studio_notification_sound_effect'},
    {'name': 'sparkle_pop', 'file': 'universfield_new_notification'},
    {'name': 'modern_chime', 'file': 'universfield_notification'},
    {'name': 'system_soft', 'file': 'universfield_system_notification'},
  ];

  String _getDisplayName(String fileName) {
    if (fileName.isEmpty) return 'None';
    final sound = _sounds.firstWhere(
      (s) => s['file'] == fileName,
      orElse: () => {'name': fileName},
    );
    return sound['name']!.tr;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return AppColumn(
      children: [
        AppRow(
          modifier: Modifier.appClickable(
            onTap: () => setState(() => _expanded = !_expanded),
            radius: 16,
          ).padding(all: 12),
          children: [
            Expanded(
              child: AppColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'sound_effect'.tr,
                    style: TextStyle(
                      color: ob.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppSpacerH(2),
                  Obx(
                    () => AppText(
                      _getDisplayName(widget.controller.soundEffect.value),
                      style: TextStyle(
                        color: ob.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppIcon(
              _expanded
                  ? 'assets/images/svg/ic_arrow_up.svg'
                  : 'assets/images/svg/ic_arrow_down.svg',
              tint: ob.textPrimary,
            ),
          ],
        ),
        if (_expanded)
          Obx(() {
            return AppColumn(
              modifier: Modifier.background(
                color: ob.bgReminderOption,
                radius: 16,
              ).padding(vertical: 8),
              children: [
                // Sound effect toggle
                AppRow(
                  modifier: Modifier.paddingLR(
                    left: 24,
                    right: 12,
                  ).padding(vertical: 16),
                  children: [
                    AppIcon(
                      'assets/images/svg/ic_volume_up.svg',
                      size: 20,
                      tint: ob.textPrimary,
                    ),
                    AppSpacerW8,
                    Expanded(
                      child: AppText(
                        'sound_effect'.tr,
                        style: TextStyle(
                          color: ob.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildSwitch(
                      value: widget.controller.soundEffectEnabled.value,
                      onChanged: (v) {
                        widget.controller.soundEffectEnabled.value = v;
                        widget.controller.saveSettings();
                      },
                      context: context,
                    ),
                  ],
                ),
                if (widget.controller.soundEffectEnabled.value) ...[
                  ..._sounds.map((sound) {
                    final name = sound['name']!;
                    final file = sound['file']!;
                    return AppRow(
                      modifier: Modifier.appClickable(
                        onTap: () {
                          widget.controller.soundEffect.value = file;
                          widget.controller.saveSettings();
                          _player.play(AssetSource('audio/$file.mp3'));
                        },
                        radius: 16,
                      ).paddingLR(left: 50, right: 12).padding(vertical: 16),
                      children: [
                        Expanded(
                          child: AppText(
                            name.tr,
                            style: TextStyle(
                              color: ob.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildRadio(
                          widget.controller.soundEffect.value == file,
                        ),
                      ],
                    );
                  }),
                ],

                // Vibrate toggle
                AppRow(
                  modifier: Modifier.paddingLR(
                    left: 24,
                    right: 12,
                  ).padding(vertical: 16),
                  children: [
                    AppIcon(
                      'assets/images/svg/ic_vibration.svg',
                      size: 20,
                      tint: ob.textPrimary,
                    ),
                    AppSpacerW8,
                    Expanded(
                      child: AppText(
                        'vibrate'.tr,
                        style: TextStyle(
                          color: ob.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildSwitch(
                      value: widget.controller.vibrate.value,
                      onChanged: (v) {
                        widget.controller.vibrate.value = v;
                        widget.controller.saveSettings();
                      },
                      context: context,
                    ),
                  ],
                ),
                const AppSpacerH(4),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    final ob = OnboardingTheme.of(context);
    return CustomSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: ob.switchActive,
      trackColor: ob.switchTrack,
    );
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
}

