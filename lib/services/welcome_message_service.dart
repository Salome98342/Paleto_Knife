import 'dart:math';

/// Servicio que proporciona mensajes de bienvenida dinámicos personalizados
class WelcomeMessageService {
  static const List<String> welcomeMessages = [
    '¡Hola, {username}!',
    '¿Listo para la aventura, {username}?',
    '¡Bienvenido de nuevo, {username}!',
    '¿Qué tal, {username}?',
    '¡Vamos con todo, {username}!',
    '¡Encantado de verte, {username}!',
    '¡Es un placer, {username}!',
    '¡Que empiece la diversión, {username}!',
    'Hola de nuevo, {username}',
    '¡Prepárate, {username}!',
  ];

  /// Obtener un mensaje aleatorio personalizado
  static String getRandomWelcomeMessage(String username) {
    final random = Random();
    final message = welcomeMessages[random.nextInt(welcomeMessages.length)];
    return message.replaceAll('{username}', username);
  }

  /// Obtener todos los mensajes (para debugging)
  static List<String> getAllMessages(String username) {
    return welcomeMessages
        .map((msg) => msg.replaceAll('{username}', username))
        .toList();
  }
}
