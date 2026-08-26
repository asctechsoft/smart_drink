import 'package:dsp_base/app_material.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/controller/user_profile_controller.dart';
import 'package:waternudge/presentation/common_components/onboarding_background.dart';
import 'package:waternudge/values/route_name.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for both the minimum splash duration and profile loading to finish
    final profileCtrl = Get.find<UserProfileController>();
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _waitForProfile(profileCtrl),
    ]);
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool(PrefConst.onboardingCompleted) ?? false;
    if (onboarded) {
      Get.offAllNamed(RouteName.home);
    } else {
      Get.offAllNamed(RouteName.onboardingLanguage);
    }
  }

  Future<void> _waitForProfile(UserProfileController ctrl) async {
    // Wait until profile loading is done (max 5 seconds)
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (ctrl.isLoading.value && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon('assets/images/png/logo_app_v3.png', size: 100),
                AppSpacerH16,
                AppText(
                  "Aquvia",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

