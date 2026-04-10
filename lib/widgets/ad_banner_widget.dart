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
  final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    // En web, no mostrar nada
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    // Mostrar banner si está listo, sino espacio
    if (!_adService.isBannerReady) {
      return const SizedBox(
        height: 50,
        child: SizedBox.shrink(),
      );
    }

    final banner = _adService.getBanner();
    if (banner == null) {
      return const SizedBox(height: 50, child: SizedBox.shrink());
    }

    return Container(
      height: AdSize.banner.height.toDouble(),
      color: Colors.black87,
      child: AdWidget(ad: banner),
    );
  }
}
