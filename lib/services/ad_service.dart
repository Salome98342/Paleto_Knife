import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // =========================
  // SINGLETON
  // =========================
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // =========================
  // IDS (CAMBIAR EN PRODUCCIÓN)
  // =========================

  static const String bannerId = 'ca-app-pub-4429728476735259/7283517276';
  static const String interstitialId = 'ca-app-pub-4429728476735259/2965324316';

  static const String rewardedGemasId = 'ca-app-pub-4429728476735259/2299313168';
  static const String rewardedMonedasId = 'ca-app-pub-4429728476735259/5695429435';
  static const String rewardedRevivirId = 'ca-app-pub-4429728476735259/4382347765';
  static const String rewardedGachaId = 'ca-app-pub-4429728476735259/6761302358';

  // =========================
  // INSTANCIAS
  // =========================

  // ================================
  // PRIVATE DEBUG LOGGER
  // ================================
  void _log(String message) {
    if (kDebugMode) {
      print('[AdService] $message');
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

  Future<void> init() async {
    // google_mobile_ads no soporta web
    if (kIsWeb) {
      _log('🌐 Web platform detected - AdService skipping native initialization');
      return;
    }

    _log('📱 Initializing AdService on mobile platform...');
    await MobileAds.instance.initialize();
    _log('✅ MobileAds initialized successfully');

    _log('📦 Loading all ads...');
    loadBanner();
    loadInterstitial();

    loadRewardedGemas();
    loadRewardedMonedas();
    loadRewardedRevivir();
    loadRewardedGacha();
  }

  // =========================
  // BANNER
  // =========================

  void loadBanner() {
    if (kIsWeb) return;

    _bannerAd = BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
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

  void loadInterstitial() {
    if (kIsWeb) return;

    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
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
  }) {
    _log('Loading RewardedAd with ID: $id');
    
    if (kIsWeb) {
      _log('Web platform detected - skipping rewarded ad load');
      return;
    }

    RewardedAd.load(
      adUnitId: id,
      request: const AdRequest(),
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

  void loadRewardedGemas() {
    _loadRewarded(
      id: rewardedGemasId,
      onLoaded: (ad) {
        _rewardedGemas = ad;
        isRewardedGemasReady = true;
      },
      onFailed: () => isRewardedGemasReady = false,
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

  void loadRewardedMonedas() {
    _loadRewarded(
      id: rewardedMonedasId,
      onLoaded: (ad) {
        _rewardedMonedas = ad;
        isRewardedMonedasReady = true;
      },
      onFailed: () => isRewardedMonedasReady = false,
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

  void loadRewardedRevivir() {
    _loadRewarded(
      id: rewardedRevivirId,
      onLoaded: (ad) {
        _rewardedRevivir = ad;
        isRewardedRevivirReady = true;
      },
      onFailed: () => isRewardedRevivirReady = false,
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

  void loadRewardedGacha() {
    _loadRewarded(
      id: rewardedGachaId,
      onLoaded: (ad) {
        _rewardedGacha = ad;
        isRewardedGachaReady = true;
      },
      onFailed: () => isRewardedGachaReady = false,
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
