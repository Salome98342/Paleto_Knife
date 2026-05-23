import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConsentStatus { unknown, personalized, nonPersonalized, adFree }

class ConsentService {
  static const _prefsKey = 'consent_status_v1';

  /// Devuelve el estado de consentimiento guardado (por defecto: unknown)
  static Future<ConsentStatus> getConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return ConsentStatus.unknown;
    switch (raw) {
      case 'personalized':
        return ConsentStatus.personalized;
      case 'nonPersonalized':
        return ConsentStatus.nonPersonalized;
      case 'adFree':
        return ConsentStatus.adFree;
      default:
        return ConsentStatus.unknown;
    }
  }

  static Future<void> setConsentStatus(ConsentStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = {
      ConsentStatus.personalized: 'personalized',
      ConsentStatus.nonPersonalized: 'nonPersonalized',
      ConsentStatus.adFree: 'adFree',
      ConsentStatus.unknown: 'unknown',
    }[status]!;
    await prefs.setString(_prefsKey, raw);
  }

  /// Si el consentimiento es desconocido, muestra un diálogo de elección.
  static Future<ConsentStatus> ensureConsent(BuildContext context) async {
    final current = await getConsentStatus();
    if (current != ConsentStatus.unknown) return current;

    final chosen = await showDialog<ConsentStatus>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Preferencias de anuncios'),
        content: const Text(
          '¿Cómo prefieres que se muestren los anuncios? Puedes cambiar esto más tarde en Ajustes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ConsentStatus.nonPersonalized),
            child: const Text('Anuncios no personalizados'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ConsentStatus.adFree),
            child: const Text('Sin anuncios (ad-free)'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, ConsentStatus.personalized),
            child: const Text('Aceptar anuncios personalizados'),
          ),
        ],
      ),
    );

    final result = chosen ?? ConsentStatus.unknown;
    await setConsentStatus(result);
    return result;
  }
}
