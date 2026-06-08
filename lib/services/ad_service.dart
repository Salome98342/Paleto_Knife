import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'consent_service.dart' as local_consent;


class AdService {
  // =========================
  // SINGLETON
  // =========================
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // =========================
  // =========================
  // Ad unit configuration
  // Default values use Google's test ad units. Replace these at release
  // with your real AdMob unit IDs via `setAdUnitIds(...)` before calling `init()`.
  // =========================

  static String bannerUnitId = 'ca-app-pub-4429728476735259/7173399735';
  static String interstitialUnitId = 'ca-app-pub-4429728476735259/2965324316';

  static String rewardedGemasUnitId = 'ca-app-pub-4429728476735259/7221556066';
  static String rewardedMonedasUnitId = 'ca-app-pub-4429728476735259/5695429435';
  static String rewardedRevivirUnitId = 'ca-app-pub-4429728476735259/4382347765';
  static String rewardedGachaUnitId = 'ca-app-pub-4429728476735259/6761302358';

  // Test device IDs for development. Set to your device id(s) while testing.
  // Example: ['ABCDEF012345']  (leave empty for production)
  // Add your test device IDs here to force test ads while debugging.
  // Example device id found in device logs: D0CF9BE58E804327C669D288EBD2BBE6
  // Keep this empty for production.
  static List<String> testDeviceIds = [
    'D0CF9BE58E804327C669D288EBD2BBE6',
  ];

  /// Replace ad unit IDs programmatically (call before `init()` in main)
  static void setAdUnitIds({
    String? banner,
    String? interstitial,
    String? rewardedGemas,
    String? rewardedMonedas,
    String? rewardedRevivir,
    String? rewardedGacha,
  }) {
    if (banner != null) bannerUnitId = banner;
    if (interstitial != null) interstitialUnitId = interstitial;
    if (rewardedGemas != null) rewardedGemasUnitId = rewardedGemas;
    if (rewardedMonedas != null) rewardedMonedasUnitId = rewardedMonedas;
    if (rewardedRevivir != null) rewardedRevivirUnitId = rewardedRevivir;
    if (rewardedGacha != null) rewardedGachaUnitId = rewardedGacha;
  }

  // =========================
  // INSTANCIAS
  // =========================

  // ================================
  // PRIVATE DEBUG LOGGER
  // ================================
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AdService] $message');
    }
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  RewardedAd? _rewardedGemas;
  RewardedAd? _rewardedMonedas;
  RewardedAd? _rewardedRevivir;
  RewardedAd? _rewardedGacha;

  bool isBannerReady = false;
  bool isInterstitialReady = false;

  bool isRewardedGemasReady = false;
  bool isRewardedMonedasReady = false;
  bool isRewardedRevivirReady = false;
  bool isRewardedGachaReady = false;

  // =========================
  // INIT
  // =========================

  bool _initialized = false;
  bool _initializing = false;
  Future<void> init() async {
    // Evitar que se dispare init múltiples veces.
    if (_initialized || _initializing) return;

    _initializing = true;

    if (kIsWeb) {
      _log('🌐 Web platform detected - AdService skipping native initialization');
      _initialized = true;
      _initializing = false;
      return;
    }

    _log('📱 Initializing AdService on mobile platform...');


    // Apply test device ids configuration for development (no-op if empty)
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds),
      );
      _log('✅ RequestConfiguration applied: testDeviceIds=$testDeviceIds');
    } catch (e) {
      _log('⚠️ Failed to apply RequestConfiguration: $e');
    }

    await MobileAds.instance.initialize();
    _log('✅ MobileAds initialized successfully');

    // Check consent preferences and decide whether to load ads
    final consent = await local_consent.ConsentService.getConsentStatus();
    final adFree = consent == local_consent.ConsentStatus.adFree;
    final nonPersonalized = consent == local_consent.ConsentStatus.nonPersonalized;

    if (adFree) {
      _log('User opted-out of ads (ad-free). Skipping ad loading.');
      _initialized = true;
      return;
    }

    _log('📦 Loading all ads... (nonPersonalized=$nonPersonalized)');

    // Evitar re-cargar ads si init se llama varias veces por reconstrucciones.
    // (Mantiene el flujo normal pero reduce presión de WebView => menos timeouts.)
    if (_bannerAd == null) {
      loadBanner(nonPersonalized: nonPersonalized);
    }

    if (_interstitialAd == null) {
      loadInterstitial(nonPersonalized: nonPersonalized);
    }


    loadRewardedGemas(nonPersonalized: nonPersonalized);
    loadRewardedMonedas(nonPersonalized: nonPersonalized);
    loadRewardedRevivir(nonPersonalized: nonPersonalized);
    loadRewardedGacha(nonPersonalized: nonPersonalized);

    _initialized = true;
    _initializing = false;
  }


  // =========================
  // BANNER
  // =========================

  void loadBanner({bool nonPersonalized = false}) {
    if (kIsWeb) return;
    final request = nonPersonalized ? AdRequest(nonPersonalizedAds: true) : const AdRequest();

    _bannerAd = BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerReady = false;
        },
      ),
    );

    _bannerAd!.load();
  }

  BannerAd? getBanner() {
    return isBannerReady ? _bannerAd : null;
  }

  // =========================
  // INTERSTITIAL
  // =========================

  void loadInterstitial({bool nonPersonalized = false}) {
    if (kIsWeb) return;
    final request = nonPersonalized ? AdRequest(nonPersonalizedAds: true) : const AdRequest();

    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialReady = true;
        },
        onAdFailedToLoad: (error) {
          isInterstitialReady = false;
        },
      ),
    );
  }

  void showInterstitial() {
    if (kIsWeb) return;
    if (!isInterstitialReady || _interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial(); // recargar
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitial();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
    isInterstitialReady = false;
  }

  // =========================
  // REWARDED BASE
  // =========================

  void _loadRewarded({
    required String id,
    required Function(RewardedAd) onLoaded,
    required Function() onFailed,
    bool nonPersonalized = false,
  }) {
    _log('Loading RewardedAd with ID: $id');
    
    if (kIsWeb) {
      _log('Web platform detected - skipping rewarded ad load');
      return;
    }

    final request = nonPersonalized ? AdRequest(nonPersonalizedAds: true) : const AdRequest();

    RewardedAd.load(
      adUnitId: id,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _log('✅ RewardedAd loaded successfully: $id');
          onLoaded(ad);
        },
        onAdFailedToLoad: (error) {
          _log('❌ RewardedAd failed to load: $id - Error: ${error.message}');
          onFailed();
        },
      ),
    );
  }

  void _showRewarded({
    required RewardedAd? ad,
    required Function() onReward,
    required Function() onReload,
  }) {
    if (kIsWeb) {
      // En web, simular que se ganó la recompensa
      onReward();
      return;
    }

    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onReload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onReload();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onReward();
      },
    );
  }

  // =========================
  // GEMAS
  // =========================

  void loadRewardedGemas({bool nonPersonalized = false}) {
    _loadRewarded(
      id: rewardedGemasUnitId,
      onLoaded: (ad) {
        _rewardedGemas = ad;
        isRewardedGemasReady = true;
      },
      onFailed: () => isRewardedGemasReady = false,
      nonPersonalized: nonPersonalized,
    );
  }

  void showRewardedGemas(Function() onReward) {
    _log('showRewardedGemas called - isReady=$isRewardedGemasReady');
    
    if (kIsWeb) {
      _log('Web platform detected - executing reward directly');
      onReward();
      return;
    }

    // Si el ad está listo, intentar mostrarlo
    if (isRewardedGemasReady && _rewardedGemas != null) {
      _log('Ad ready - showing RewardedAd. Ad instance: $_rewardedGemas');
      _showRewarded(
        ad: _rewardedGemas,
        onReward: onReward,
        onReload: loadRewardedGemas,
      );
      _rewardedGemas = null;
      isRewardedGemasReady = false;
    } else {
      // FALLBACK: Si no hay ad, ejecutar la recompensa de todas formas
      _log('⚠️ FALLBACK: Ad not ready (_rewardedGemas=${_rewardedGemas?.hashCode}) - executing reward anyway & reloading');
      onReward();
      // Reintentar cargar el ad para próxima vez
      loadRewardedGemas();
    }
  }

  // =========================
  // MONEDAS
  // =========================

  void loadRewardedMonedas({bool nonPersonalized = false}) {
    _loadRewarded(
      id: rewardedMonedasUnitId,
      onLoaded: (ad) {
        _rewardedMonedas = ad;
        isRewardedMonedasReady = true;
      },
      onFailed: () => isRewardedMonedasReady = false,
      nonPersonalized: nonPersonalized,
    );
  }

  void showRewardedMonedas(Function() onReward) {
    _log('showRewardedMonedas called - isReady=$isRewardedMonedasReady');
    
    if (kIsWeb) {
      _log('Web platform detected - executing reward directly');
      onReward();
      return;
    }

    // Si el ad está listo, intentar mostrarlo
    if (isRewardedMonedasReady && _rewardedMonedas != null) {
      _log('Ad ready - showing RewardedAd. Ad instance: $_rewardedMonedas');
      _showRewarded(
        ad: _rewardedMonedas,
        onReward: onReward,
        onReload: loadRewardedMonedas,
      );
      _rewardedMonedas = null;
      isRewardedMonedasReady = false;
    } else {
      // FALLBACK: Si no hay ad, ejecutar la recompensa de todas formas
      _log('⚠️ FALLBACK: Ad not ready (_rewardedMonedas=${_rewardedMonedas?.hashCode}) - executing reward anyway & reloading');
      onReward();
      // Reintentar cargar el ad para próxima vez
      loadRewardedMonedas();
    }
  }

  // =========================
  // REVIVIR
  // =========================

  void loadRewardedRevivir({bool nonPersonalized = false}) {
    _loadRewarded(
      id: rewardedRevivirUnitId,
      onLoaded: (ad) {
        _rewardedRevivir = ad;
        isRewardedRevivirReady = true;
      },
      onFailed: () => isRewardedRevivirReady = false,
      nonPersonalized: nonPersonalized,
    );
  }

  void showRewardedRevivir(Function() onReward) {
    _log('showRewardedRevivir called - isReady=$isRewardedRevivirReady');
    
    if (kIsWeb) {
      _log('Web platform detected - executing reward directly');
      onReward();
      return;
    }

    // Si el ad está listo, intentar mostrarlo
    if (isRewardedRevivirReady && _rewardedRevivir != null) {
      _log('Ad ready - showing RewardedAd. Ad instance: $_rewardedRevivir');
      _showRewarded(
        ad: _rewardedRevivir,
        onReward: onReward,
        onReload: loadRewardedRevivir,
      );
      _rewardedRevivir = null;
      isRewardedRevivirReady = false;
    } else {
      // FALLBACK: Si no hay ad, ejecutar la recompensa de todas formas
      _log('⚠️ FALLBACK: Ad not ready (_rewardedRevivir=${_rewardedRevivir?.hashCode}) - executing reward anyway & reloading');
      onReward();
      // Reintentar cargar el ad para próxima vez
      loadRewardedRevivir();
    }
  }

  // =========================
  // GACHA
  // =========================

  void loadRewardedGacha({bool nonPersonalized = false}) {
    _loadRewarded(
      id: rewardedGachaUnitId,
      onLoaded: (ad) {
        _rewardedGacha = ad;
        isRewardedGachaReady = true;
      },
      onFailed: () => isRewardedGachaReady = false,
      nonPersonalized: nonPersonalized,
    );
  }

  void showRewardedGacha(Function() onReward) {
    _log('showRewardedGacha called - isReady=$isRewardedGachaReady');
    
    if (kIsWeb) {
      _log('Web platform detected - executing reward directly');
      onReward();
      return;
    }

    // Si el ad está listo, intentar mostrarlo
    if (isRewardedGachaReady && _rewardedGacha != null) {
      _log('Ad ready - showing RewardedAd. Ad instance: $_rewardedGacha');
      _showRewarded(
        ad: _rewardedGacha,
        onReward: onReward,
        onReload: loadRewardedGacha,
      );
      _rewardedGacha = null;
      isRewardedGachaReady = false;
    } else {
      // FALLBACK: Si no hay ad, ejecutar la recompensa de todas formas
      _log('⚠️ FALLBACK: Ad not ready (_rewardedGacha=${_rewardedGacha?.hashCode}) - executing reward anyway & reloading');
      onReward();
      // Reintentar cargar el ad para próxima vez
      loadRewardedGacha();
    }
  }
}
