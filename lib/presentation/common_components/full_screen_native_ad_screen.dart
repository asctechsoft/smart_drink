import 'dart:async';

import 'package:asc_common/asc_common.dart';
import 'package:flutter/material.dart';
import 'package:waternudge/configs/ads_config.dart';

/// Full-screen Native Ad shown between two onboarding steps — the ad content
/// itself fills the screen, with a countdown ring top-left that turns into a
/// close (X) button after [countdownSeconds]; tapping it calls [onContinue].
///
/// [canGoBack] controls the system back gesture/button:
/// - `false` (default — "FSN_2" style): back does nothing, ever. The only
///   way out is the X button once the countdown ends.
/// - `true` ("FSN_1" style): back always returns to the previous screen
///   (without calling [onContinue] — this is "go back", not "skip ahead"),
///   even while the countdown is still running. Forward progress still only
///   ever happens through the X button after the countdown ends.
///
/// Call [FullScreenNativeAdScreen.pushOrSkip] rather than navigating to this
/// directly — it's a no-op straight to [onContinue] when ads are hidden
/// ([AscAdsConfig.isHideAd]) or the ad never loads, so it's never a dead end.
class FullScreenNativeAdScreen extends StatefulWidget {
  const FullScreenNativeAdScreen({
    super.key,
    required this.adUnitId,
    required this.onContinue,
    this.countdownSeconds = 3,
    this.canGoBack = false,
  });

  final String adUnitId;
  final VoidCallback onContinue;
  final int countdownSeconds;
  final bool canGoBack;

  /// Pushes this screen, or skips straight to [onContinue] when ads are
  /// hidden — the caller never needs its own `if (AscAdsConfig.isHideAd)`
  /// check at the call site.
  static void pushOrSkip(
    BuildContext context, {
    required String adUnitId,
    required VoidCallback onContinue,
    int countdownSeconds = 3,
    bool canGoBack = false,
  }) {
    if (AscAdsConfig.isHideAd) {
      onContinue();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenNativeAdScreen(
          adUnitId: adUnitId,
          onContinue: onContinue,
          countdownSeconds: countdownSeconds,
          canGoBack: canGoBack,
        ),
      ),
    );
  }

  @override
  State<FullScreenNativeAdScreen> createState() =>
      _FullScreenNativeAdScreenState();
}

class _FullScreenNativeAdScreenState extends State<FullScreenNativeAdScreen> {
  late final AscNativeAdService _adService;
  bool _adLoaded = false;
  late int _remaining = widget.countdownSeconds;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    // Google's own template style never stretches to fill a screen (it just
    // renders at its own compact natural size, leaving the rest blank) — a
    // real full-screen look needs a custom native factory whose own layout
    // is built to fill the space (see FsnNativeAdFactory.kt).
    _adService = AscNativeAdService(
      adUnitId: widget.adUnitId,
      factoryId: AdsConfig.fsnNativeAdFactoryId,
    );
    _load();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) timer.cancel();
    });
  }

  Future<void> _load() async {
    await _adService.load();
    if (mounted) {
      // Loaded or not, stop blocking on the ad content itself once the SDK
      // is done trying — a failed load still counts down to the close
      // button same as a slow one, it just shows a blank card underneath.
      setState(() => _adLoaded = _adService.isLoaded);
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _adService.dispose();
    super.dispose();
  }

  /// Advances forward (X button / countdown-gated) — pops, then runs
  /// [FullScreenNativeAdScreen.onContinue].
  void _onClose() {
    Navigator.of(context).pop();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final canClose = _remaining <= 0;
    return PopScope(
      // Never lets a raw system pop through — canGoBack:true still routes
      // back through here (as "go back", not "skip ahead"), so this screen
      // never silently reveals whatever's underneath without a decision
      // being made either way.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (widget.canGoBack) {
          Navigator.of(context).pop();
        }
        // canGoBack: false — back is a no-op for this screen's whole
        // lifetime, countdown or not; only the X button ever advances.
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _adLoaded
                  ? _adService.render(height: double.infinity)
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    ),
              Positioned(
                top: 12,
                right: 12,
                child: canClose
                    ? _CloseButton(onTap: _onClose)
                    : _CountdownRing(
                        remaining: _remaining,
                        total: widget.countdownSeconds,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.remaining, required this.total});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: total == 0 ? 1 : remaining / total,
            strokeWidth: 2,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
          Text(
            '$remaining',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}
