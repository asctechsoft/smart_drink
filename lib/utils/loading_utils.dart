import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';

class LoadingUtils {
  static void show() {
    if (Get.isDialogOpen ?? false) return;
    
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;
    final ob = OnboardingTheme.of(context);
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator(color: ob.textPrimary)),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
    );
  }

  /// Hides the currently visible loading overlay.
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static Widget widget(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return Center(child: CircularProgressIndicator(color: ob.textPrimary));
  }

  /// Shows an instant fireworks / confetti effect falling from the top.
  static void showConfetti([BuildContext? context]) {
    OverlayState? overlayState;
    if (context != null && context.mounted) {
      overlayState = Overlay.maybeOf(context);
    }
    // Fallback an toàn hơn qua GetX
    overlayState ??= Get.overlayContext != null ? Overlay.maybeOf(Get.overlayContext!) : null;
    overlayState ??= Get.key.currentState?.overlay;

    if (overlayState == null) return;

    // Nổ 1 lần nên duration để thật ngắn
    final controller = ConfettiController(
      duration: const Duration(milliseconds: 250),
    );

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        const colors = [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.purple,
        ];

        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                // Điểm giữa màn hình: Nổ tung hình pháo hoa tỏa ra mọi phía
                Align(
                  alignment: const Alignment(
                    0,
                    0.2,
                  ), // Hơi lệch xuống dưới tâm một chút
                  child: ConfettiWidget(
                    confettiController: controller,
                    blastDirectionality: BlastDirectionality
                        .explosive, // Tung tóe mọi ngóc ngách
                    maxBlastForce: 45, // Lực đẩy nổ mạnh tỏa ra
                    minBlastForce: 15,
                    emissionFrequency: 1.0, // Đảm bảo chỉ nổ 1 luồng duy nhất
                    numberOfParticles: 60, // Số vụn giấy nhả ra căng hơn
                    gravity: 0.05, // Trọng lực cực nhẹ để pháo lơ lửng lâu
                    colors: colors,
                    minimumSize: const Size(8, 4),
                    maximumSize: const Size(16, 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Quan trọng: Đợi Overlay được gắn xong vào Widget Tree rồi mới bấm nút "Bắn"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.play();
    });

    // Auto clear memory and remove from screen after finish
    // Cho thêm thời gian để vụn rơi xuống hết màn hình mới gỡ
    Future.delayed(const Duration(seconds: 6), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
      controller.dispose();
    });
  }
}

