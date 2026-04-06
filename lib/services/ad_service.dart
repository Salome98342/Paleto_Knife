import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool isAdLoaded = kIsWeb ? true : false;
  bool isAdLoading = false;

  // Use test ID during development. Replace with your actual ad unit ID for release.
  final String _adUnitId =
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  Future<void> initConfigs() async {
    if (kIsWeb) return; // Ads no soportados en web
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (kIsWeb) return;
    if (isAdLoading) return;
    isAdLoading = true;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded = true;
          isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          isAdLoaded = false;
          isAdLoading = false;
          // Retry later depending on logic
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(int rewardAmount) onRewardEarned,
    VoidCallback? onAdClosed,
  }) {
    if (kIsWeb) {
      // Simulate ad reward on web for development
      debugPrint('Simulating Ad reward on Web');
      onRewardEarned(10);
      if (onAdClosed != null) onAdClosed();
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        isAdLoaded = false;
        _loadRewardedAd(); // Load the next ad
        if (onAdClosed != null) onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
        isAdLoaded = false;
        _loadRewardedAd(); // Load the next ad
        if (onAdClosed != null) onAdClosed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        // Reward is given
        onRewardEarned(
          10,
        ); // for example, give 10 gems per ad. User can configure this.
      },
    );
  }
}
