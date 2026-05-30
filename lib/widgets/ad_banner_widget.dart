import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Widget que muestra el banner de anuncios en la parte inferior
/// Para usar en Stack con Positioned o simplemente como widget normal
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (kIsWeb) return;

      _bannerAd = BannerAd(
        adUnitId: AdService.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _isLoaded = false;
            _bannerAd = null;
          });
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // En web, no mostrar nada
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    // Mostrar banner si está listo, sino espacio
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 50,
        child: SizedBox.shrink(),
      );
    }

    return Container(
      height: AdSize.banner.height.toDouble(),
      color: Colors.black87,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
