import 'dart:ui';
import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/history_controller.dart';
import 'package:smartdrinkai/presentation/screen_explore/explore_screen.dart';
import 'package:smartdrinkai/presentation/screen_history/history_screen.dart';
import 'package:smartdrinkai/presentation/screen_today/today_screen.dart';
import 'package:smartdrinkai/presentation/screens_settings/settings_screen.dart';
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
    ExploreScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final ob = OnboardingTheme.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          height: 80 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: ob.bgBottomNavBar,
            // boxShadow: [
            //   BoxShadow(
            //     color: Color(0xFF3E8DFD).withValues(alpha: 0.15),
            //     blurRadius: 24,
            //   ),
            // ],
          ),
          child: AppRowCentered(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildNavItem(
                0,
                'assets/images/svg/ic_today_nav.svg',
                'today',
                context,
              ),
              _buildNavItem(
                1,
                'assets/images/svg/ic_history_nav.svg',
                'history',
                context,
              ),
              _buildNavItem(
                2,
                'assets/images/svg/ic_explore_nav.svg',
                'explore',
                context,
              ),
              _buildNavItem(
                3,
                'assets/images/svg/ic_setting_nav.svg',
                'settings',
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String icon,
    String label,
    BuildContext context,
  ) {
    final ob = OnboardingTheme.of(context);
    final isActive = _currentIndex == index;
    final color = isActive ? ob.textActiveBottomNavBar : ob.textBottomNavBar;

    return Expanded(
      child: Center(
        child: AppColumnCentered(
          modifier:
              Modifier //
                  .appClickable(
                    onTap: () {
                      setState(() => _currentIndex = index);
                      if (index == 1 && Get.isRegistered<HistoryController>()) {
                        Get.find<HistoryController>().loadData();
                      }
                    },
                    radius: 100,
                  )
                  .size(68),
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.modulate),
            ),
            AppSpacerH4,
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AppText(
                label.tr,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

