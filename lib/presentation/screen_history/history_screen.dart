import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/controller/settings_controller.dart';
import 'package:smartdrinkai/controller/today_controller.dart';
import 'package:smartdrinkai/utils/unit_converter.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/models/ui_models/drink_type.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/presentation/common_components/primary_button.dart';
import 'package:smartdrinkai/values/app_colors.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter/services.dart';
import 'package:smartdrinkai/presentation/common_components/primary_dialog.dart';
import 'package:smartdrinkai/utils/toast_utils.dart';
import 'package:get/get.dart';
import 'history_bar_chart.dart';
import 'components/history_drink_list.dart';
import 'components/history_period_selector.dart';
import 'components/history_date_picker.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    final controller = Get.find<HistoryController>();
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation:
              0, // Quan trọng: tắt hiệu ứng đổi màu Material 3 khi scroll
          centerTitle: true,
          title: AppText(
            'history'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: AppColumn(
                children: [
                  // Segment control
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Obx(() => _buildSegmentControl(context, controller)),
                  ),
                  AppSpacerH20,

                  Obx(
                    () => controller.canGoNext
                        ? Column(
                            children: [
                              PrimaryButton(
                                text: 'back_to_today'.tr,
                                width: 140, // Small width instead of expanded
                                height: 36, // Slender height
                                onPressed: controller.backToToday,
                                outlined: true, // Uses transparent bg, borders
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                                textStyle: TextStyle(
                                  color: ob.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              AppSpacerH12,
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  HistoryPeriodSelector(
                    controller: controller,
                    onTitleTap: () {
                      if (controller.viewMode.value == HistoryViewMode.day) {
                        HistoryDatePicker.show(
                          context,
                          initialDate: controller.selectedDate.value,
                          lastDate: DateTime.now(),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            controller.selectedDate.value = pickedDate;
                          }
                        });
                      }
                    },
                  ),
                  AppSpacerH12,
                  // Chart card with total
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppColumn(
                      modifier: Modifier.background(
                        color: ob.bgReminderOption,
                        radius: 16,
                      ).padding(horizontal: 8, vertical: 8),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total label
                        AppText(
                          'total'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                            color: ob.textPrimary,
                          ),
                        ),
                        Obx(() {
                          final volumeUnit =
                              Get.find<SettingsController>().volumeUnit.value;
                          return AppRow(
                            children: [
                              AppText(
                                UnitConverter.formatVolumeValue(
                                  controller.computedTotal.toDouble(),
                                  volumeUnit,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: ob.switchActive,
                                ),
                              ),
                              AppText(
                                ' / ${UnitConverter.formatVolume(controller.goalMl.value.toDouble(), volumeUnit)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: ob.textPrimary,
                                ),
                              ),
                            ],
                          );
                        }),
                        AppSpacerH24,
                        // Bar chart
                        const SizedBox(height: 180, child: HistoryBarChart()),
                      ],
                    ),
                  ),

                  // Day view: drink history list, Week/Month: summary stats
                  HistoryDrinkList(
                    controller: controller,
                    onEdit: (record) =>
                        _showEditDialog(context, controller, record),
                    onDelete: (record) =>
                        _showDeleteConfirm(context, controller, record),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentControl(
    BuildContext context,
    HistoryController controller,
  ) {
    final ob = OnboardingTheme.of(context);
    return AppRow(
      modifier: Modifier.background(
        color: ob.bgOption,
        radius: 100,
      ).border(color: ob.borderTabHistory, width: 1, radius: 100).paddingAll(4),
      children: HistoryViewMode.values.map((mode) {
        final isSelected = controller.viewMode.value == mode;
        final translated = mode.name.tr;
        final label = translated[0].toUpperCase() + translated.substring(1);
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => controller.viewMode.value = mode,
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: isSelected ? ob.accent : Colors.transparent,
                ),
                child: AppText(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ob.textToggleActive : ob.textPrimary,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    HistoryController controller,
    DrinkRecord record,
  ) {
    final ob = OnboardingTheme.of(context);
    PrimaryDialog.show(
      context: context,
      title: 'delete_drink'.tr,
      content: AppColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            'do_you_want_to_delete'.tr,
            style: TextStyle(
              color: ob.textPercentDrinkItem,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const AppSpacerH(32),
          AppRow(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'cancel'.tr,
                  outlined: true,
                  onPressed: () => Navigator.pop(context),
                  height: 44,
                ),
              ),
              const AppSpacerW(12),
              Expanded(
                child: PrimaryButton(
                  text: 'delete'.tr,
                  useGradient: false,
                  solidColor: AppColors.danger300,
                  onPressed: () {
                    Navigator.pop(context);
                    controller.deleteRecord(record);
                  },
                  height: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    HistoryController controller,
    DrinkRecord record,
  ) {
    final volumeUnit = Get.find<SettingsController>().volumeUnit.value;
    final isOz = volumeUnit == 'oz';

    // Giá trị gốc (ml) để hiển thị
    final displayMl = record.originalAmountMl > 0
        ? record.originalAmountMl
        : record.amountMl;
    // Convert sang oz nếu cần để hiển thị trong TextField
    // Sử dụng formatVolumeValue để lấy chuỗi hiển thị chuẩn (xử lý được cả oz lẻ và xóa số 0 thừa)
    final initialValueStr = UnitConverter.formatVolumeValue(
      displayMl.toDouble(),
      volumeUnit,
    );
    final textController = TextEditingController(text: initialValueStr);
    final focusNode = FocusNode();

    // Đợi hiệu ứng mở Dialog hoàn tất (khoảng 300ms) rồi mới mở bàn phím
    // để tránh bị giật lag layout
    Future.delayed(const Duration(milliseconds: 150), () {
      focusNode.requestFocus();
    });

    PrimaryDialog.show(
      context: context,
      title: 'edit_drink'.tr,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          final ob = OnboardingTheme.of(ctx);
          return AppColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppRow(
                modifier: Modifier.background(
                  color: ob.bgToggle,
                  radius: 12,
                ).padding(horizontal: 16),
                children: [
                  AppIcon(
                    'assets/images/webp/img_measuring_cup.webp',
                    size: 24,
                    tint: ob.switchActive,
                  ),
                  const AppSpacerW(8),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      keyboardType: isOz
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.number,
                      inputFormatters: [
                        isOz
                            ? FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              )
                            : FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(color: ob.textPrimary, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '',
                      ),
                      autofocus: false, // Tắt autofocus mặc định
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  AppText(
                    volumeUnit,
                    style: TextStyle(
                      color: ob.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const AppSpacerH(32),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'cancel'.tr,
                      outlined: true,
                      onPressed: () => Navigator.pop(ctx),
                      height: 44,
                    ),
                  ),
                  const AppSpacerW(12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'save'.tr,
                      useGradient: true,
                      height: 44,
                      enabled: textController.text.trim().isNotEmpty,
                      onPressed: () {
                        final val = double.tryParse(textController.text);
                        if (val != null && val > 0) {
                          Navigator.pop(ctx);
                          final type = DrinkType.values.firstWhere(
                            (t) => t.name == record.drinkType,
                            orElse: () => DrinkType.water,
                          );
                          final double valInMl = isOz
                              ? UnitConverter.ozToMl(val)
                              : val;
                          final effectiveWater =
                              (valInMl * type.waterPercent / 100).round();
                          final todayController = Get.find<TodayController>();

                          final intakeWithoutThisRecord =
                              todayController.currentIntakeMl.value -
                              record.amountMl;
                          if (intakeWithoutThisRecord + effectiveWater > 8000) {
                            ToastUtils.showLimitToast(context);
                            return;
                          }
                          controller.updateRecord(
                            record.copyWith(
                              amountMl: effectiveWater,
                              originalAmountMl: valInMl,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

