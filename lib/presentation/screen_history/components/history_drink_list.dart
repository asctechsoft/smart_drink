import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/models/data_models/drink_record.dart';
import 'package:smartdrinkai/presentation/screen_history/components/drink_history_item.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:get/get.dart';

class HistoryDrinkList extends StatelessWidget {
  final HistoryController controller;
  final Function(DrinkRecord) onEdit;
  final Function(DrinkRecord) onDelete;

  const HistoryDrinkList({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Obx(() {
      if (controller.viewMode.value != HistoryViewMode.day) {
        return const SizedBox.shrink();
      }

      if (controller.dayRecords.isEmpty) {
        return _buildEmptyState(ob);
      }

      return AppColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            modifier: Modifier.paddingAll(16),
            'drink_history'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: ob.textPrimary,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: controller.dayRecords.length,
            itemBuilder: (ctx, i) {
              final record = controller.dayRecords[i];
              return DrinkHistoryItem(
                record: record,
                onEdit: () => onEdit(record),
                onDelete: () => onDelete(record),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState(OnboardingTheme ob) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: AppColumnCentered(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon('assets/images/svg/ic_no_record.svg', size: 120),
          AppSpacerW12,
          AppText(
            'no_records_found'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ob.bgDrag,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

