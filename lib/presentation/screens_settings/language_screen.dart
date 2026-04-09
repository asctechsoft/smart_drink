import 'package:dsp_base/app_material.dart';
import 'package:smartdrinkai/controller/languages_controller.dart';
import 'package:smartdrinkai/presentation/common_components/onboarding_background.dart';
import 'package:smartdrinkai/values/onboarding_theme.dart';
import 'package:smartdrinkai/utils/loading_utils.dart';
import 'package:get/get.dart';
import 'components/language_list_widget.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final LanguagesController controller = Get.find<LanguagesController>();
  final TextEditingController _searchController = TextEditingController();
  final Rx<String> _searchQuery = ''.obs;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ob = OnboardingTheme.of(context);
    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: AppIcon(
              'assets/images/svg/ic_back_left.svg',
              size: 24,
              tint: ob.textPrimary,
              autoMirror: true,
            ),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: AppText(
            'language'.tr,
            style: TextStyle(
              color: ob.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              _buildSearchBar(),
              AppSpacerH(24),
              Expanded(
                child: _isReady
                    ? Obx(() {
                        return LanguageListWidget(
                          searchQuery: _searchQuery.value,
                        );
                      })
                    : LoadingUtils.widget(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final ob = OnboardingTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _searchController,
        cursorColor: ob.textSecondary,
        style: TextStyle(
          color: ob.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'search'.tr,
          hintStyle: TextStyle(
            color: ob.textrReminderCountdown,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12, // Taps height
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ob.bgOnboarding, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: ob.textPrimary.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

