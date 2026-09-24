import 'dart:async';

import 'package:dsp_base/advertisements.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/configs/ads_config.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/controller/history_controller.dart';
import 'package:waternudge/presentation/screen_history/history_screen.dart';
import 'package:waternudge/presentation/screen_today/today_screen.dart';
import 'package:waternudge/presentation/screens_settings/rate_app_dialog.dart';
import 'package:waternudge/presentation/screens_settings/settings_screen.dart';
import 'package:waternudge/presentation/screens_reminder/reminder_settings_screen.dart';
import 'package:waternudge/tour/tour_controller.dart';
import 'package:waternudge/utils/analytics.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// Tabs built so far. Only Today is built on entry; the others are deferred
  /// until first visited, so arriving from the splash paints one screen, not
  /// four — the rest were the jank on the way in.
  final Set<int> _built = {0};

  final _screens = const [
    TodayScreen(),
    HistoryScreen(),
    ReminderSettingsPage(),
    SettingsScreen(),
  ];

  static const _pillH = 68.0;

  /// Tab slug order matches `_screens`/`_currentIndex`, used for both the
  /// nav-tap and the screen-view event so the two always agree on naming.
  static const _tabs = ['today', 'history', 'reminders', 'settings'];

  static void _logTabView(int index) {
    switch (_tabs[index]) {
      case 'today':
        Analytics.todayView();
      case 'history':
        Analytics.historyView();
      case 'reminders':
        Analytics.reminderView();
      case 'settings':
        Analytics.settingsView();
    }
  }

  /// Anchored banner above the bottom nav, shared across every tab so it
  /// doesn't reload on each tab switch. Not requested until
  /// [_runFirstVisitFlowThenLoadAds] clears the tour/rate-sheet gate below.
  late final BannerAdController _bannerAdController;

  @override
  void initState() {
    super.initState();
    _logTabView(_currentIndex);
    _bannerAdController = BannerAdController.newInstance(
      adUnitId: AdsConfig.bannerAdUnitId,
      tag: 'home_bottom',
    );
    _runFirstVisitFlowThenLoadAds();
  }

  /// Sequences the one-time first-visit experience — guided tour, then the
  /// rate prompt — before the banner ad ever requests a slot, so a
  /// first-time user's attention isn't split between the intro and an ad. A
  /// returning visitor has both gates return immediately (already seen), so
  /// for them the ad loads right away.
  Future<void> _runFirstVisitFlowThenLoadAds() async {
    await _maybeShowFirstRateSheet();
    if (!mounted) return;
    await _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    await _bannerAdController.setupAdsSizeOnScreenBottom();
    if (!mounted) return;
    _bannerAdController.requestBannerAd();
  }

  /// Prompts for a rating once, the very first time the user lands on Home —
  /// i.e. right after finishing onboarding. Gated by a persisted flag so it
  /// never fires again on later app opens, regardless of how Home was
  /// reached.
  ///
  /// Held back until the Today guided tour (Cup type / Menu intro) is done —
  /// it starts from `TodayScreen`'s own `initState`, racing this one, so
  /// showing the rate sheet on a fixed delay could pop it up on top of, or
  /// even before, the tour. Awaits the sheet's own dismissal too, so
  /// [_runFirstVisitFlowThenLoadAds] doesn't load the banner ad underneath it.
  Future<void> _maybeShowFirstRateSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown =
        prefs.getBool(PrefConst.firstRateSheetShown) ?? false;
    final alreadyRated = prefs.getBool(PrefConst.isRated) ?? false;
    if (alreadyShown || alreadyRated) return;

    await _waitForTourToFinish();
    if (!mounted) return;

    await prefs.setBool(PrefConst.firstRateSheetShown, true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await showRateAppSheet(context);
  }

  /// Waits out the guided tour: gives it a moment to start (it needs its
  /// anchors to mount first), then — if it does start — waits for the user to
  /// step through or skip it. If it never starts at all (already seen before,
  /// or its anchors failed to mount), gives up after a short grace window
  /// instead of blocking the rate prompt forever.
  Future<void> _waitForTourToFinish() async {
    if (!Get.isRegistered<TourController>()) return;
    final tour = Get.find<TourController>();

    if (!tour.active.value) {
      final started = Completer<void>();
      final startWorker = ever<bool>(tour.active, (isActive) {
        if (isActive && !started.isCompleted) started.complete();
      });
      await Future.any([
        started.future,
        Future.delayed(const Duration(seconds: 5)),
      ]);
      startWorker.dispose();
      if (!mounted) return;
    }

    if (tour.active.value) {
      final finished = Completer<void>();
      final finishWorker = ever<bool>(tour.active, (isActive) {
        if (!isActive && !finished.isCompleted) finished.complete();
      });
      await finished.future;
      finishWorker.dispose();
    }
  }

  void _select(int index) {
    if (index == _currentIndex) return;
    Analytics.navTap(_tabs[index]);
    setState(() {
      _currentIndex = index;
      _built.add(index);
    });
    _logTabView(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each tab paints its own gradient via OnboardingBackground, but the
      // nav pill's rounded top corners leave slivers uncovered by that — this
      // backdrop (the gradient's own tail colour) is what shows through them,
      // instead of the Scaffold's default black.
      backgroundColor: const Color.fromARGB(255, 34, 24, 109),
      // A crossfade, not IndexedStack directly — each tab keeps a stable key
      // so switching never disposes/recreates its state (scroll position,
      // the tour's post-frame callback, preloaded ads, etc.), only its
      // opacity and hit-testing change.
      body: Stack(
        children: [
          for (var i = 0; i < _screens.length; i++)
            if (_built.contains(i))
              AnimatedOpacity(
                key: ValueKey('tab_$i'),
                opacity: i == _currentIndex ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: i != _currentIndex,
                  child: _screens[i],
                ),
              ),
        ],
      ),
      // Nav pill on top, banner ad below it, flush against the true bottom
      // edge — the system nav bar is hidden, so that space is ours.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomNavBar(context),
          _bannerAdController.renderBannerAd(),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    // Fixed height, independent of MediaQuery's bottom inset: the system nav
    // bar is kept hidden (see main.dart), but a swipe-up briefly reveals it
    // and changes that inset — reacting to it made this pill visibly jump
    // for the ~2s until it re-hides. The banner ad below it absorbs that
    // inset instead when it's temporarily nonzero.
    return Container(
      height: _pillH,
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
      child: Row(
        children: [
          _PillNavItem(
            index: 0,
            icon: 'assets/images/svg/ic_cup_water_bar.svg',
            label: 'today'.tr,
            currentIndex: _currentIndex,
            onTap: () => _select(0),
          ),
          _PillNavItem(
            index: 1,
            icon: 'assets/images/svg/ic_history_tabbar.svg',
            label: 'history'.tr,
            currentIndex: _currentIndex,
            onTap: () {
              _select(1);
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
            onTap: () => _select(2),
          ),
          _PillNavItem(
            index: 3,
            icon: 'assets/images/svg/ic_setting_tabbar.svg',
            label: 'settings'.tr,
            currentIndex: _currentIndex,
            onTap: () => _select(3),
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
