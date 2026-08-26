import 'package:dsp_base/app_material.dart';
import 'package:waternudge/controller/history_controller.dart';
import 'package:waternudge/presentation/screen_history/history_screen.dart';
import 'package:waternudge/presentation/screen_today/today_screen.dart';
import 'package:waternudge/presentation/screens_settings/settings_screen.dart';
import 'package:waternudge/presentation/screens_reminder/reminder_settings_screen.dart';
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

    return Container(
      height: systemPadding + _pillH,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1575CE), Color(0xFF0B58D6)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              48,
              44,
              111,
            ).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: systemPadding),
      child: Row(
        children: [
          _PillNavItem(
            index: 0,
            icon: 'assets/images/svg/ic_cup_water_bar.svg',
            label: 'today'.tr,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          _PillNavItem(
            index: 1,
            icon: 'assets/images/svg/ic_history_tabbar.svg',
            label: 'history'.tr,
            currentIndex: _currentIndex,
            onTap: () {
              setState(() => _currentIndex = 1);
              if (Get.isRegistered<HistoryController>()) {
                final h = Get.find<HistoryController>();
                // Always land on the Day tab at the current date on entry.
                h.viewMode.value = HistoryViewMode.day;
                h.backToToday();
                h.loadData();
              }
            },
          ),
          _PillNavItem(
            index: 2,
            icon: 'assets/images/svg/ic_ring_tabbar.svg',
            label: 'reminders'.tr,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 2),
          ),
          _PillNavItem(
            index: 3,
            icon: 'assets/images/svg/ic_setting_tabbar.svg',
            label: 'settings'.tr,
            currentIndex: _currentIndex,
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ],
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
  final VoidCallback onTap;

  static const _activeColor = Color(0xFF2EF6F6);
  static const _inactiveColor = Color(0xFF97BEE9);

  const _PillNavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final color = isActive ? _activeColor : _inactiveColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              if (isActive)
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF20C4FA), Color(0xFF31DFF2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF25D7F4).withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
