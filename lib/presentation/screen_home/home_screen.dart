import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/presentation/screen_history/history_screen.dart';
import 'package:smartdrinkai/presentation/screen_today/today_screen.dart';
import 'package:smartdrinkai/presentation/screens_settings/settings_screen.dart';
import 'package:smartdrinkai/presentation/screens_reminder/reminder_settings_screen.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    TodayScreen(),
    HistoryScreen(),
    ReminderSettingsPage(),
    SettingsScreen(),
  ];

  static const _pillH = 68.0;
  static const _sideMargin = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final systemPadding = MediaQuery.of(context).padding.bottom;
    final ob = OnboardingTheme.of(context);

    return SizedBox(
      height: systemPadding + _pillH + 8,
      child: Container(
        // The system inset sits below the pill, not inside it, so the pill keeps
        // its own height instead of stretching behind the navigation buttons.
        margin: EdgeInsets.only(
          left: _sideMargin,
          right: _sideMargin,
          bottom: 8 + systemPadding,
        ),
        decoration: BoxDecoration(
          color: ob.bgBottomNavBar,
          borderRadius: BorderRadius.circular(_pillH / 2),
          border: Border.all(color: ob.borderTabHistory, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            _PillNavItem(
              index: 0,
              icon: 'assets/images/svg/ic_today_nav.svg',
              label: 'today'.tr,
              currentIndex: _currentIndex,
              ob: ob,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _PillNavItem(
              index: 1,
              icon: 'assets/images/svg/ic_history_nav.svg',
              label: 'history'.tr,
              currentIndex: _currentIndex,
              ob: ob,
              onTap: () {
                setState(() => _currentIndex = 1);
                if (Get.isRegistered<HistoryController>()) {
                  Get.find<HistoryController>().loadData();
                }
              },
            ),
            _PillNavItem(
              index: 2,
              icon: 'assets/images/svg/ic_ring.svg',
              label: 'reminders'.tr,
              currentIndex: _currentIndex,
              ob: ob,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _PillNavItem(
              index: 3,
              icon: 'assets/images/svg/ic_setting_nav.svg',
              label: 'settings'.tr,
              currentIndex: _currentIndex,
              ob: ob,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pill Nav Item ────────────────────────────────────────────────────────────

class _PillNavItem extends StatelessWidget {
  final int index;
  final String icon;
  final String label;
  final int currentIndex;
  final OnboardingTheme ob;
  final VoidCallback onTap;

  const _PillNavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.currentIndex,
    required this.ob,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final color = isActive ? ob.textActiveBottomNavBar : ob.textBottomNavBar;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: isActive ? _activeItem(color) : _inactiveItem(color),
        ),
      ),
    );
  }

  Widget _activeItem(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(color, BlendMode.modulate),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ],
    );
  }

  Widget _inactiveItem(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(color, BlendMode.modulate),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
