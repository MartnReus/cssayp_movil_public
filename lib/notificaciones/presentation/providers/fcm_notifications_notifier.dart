import 'package:cssayp_movil/notificaciones/notificaciones.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FcmNotificationNotifier extends Notifier<void> {
  late final FirebaseNotificationRepository _firebaseRepository;

  @override
  void build() {
    _firebaseRepository = ref.watch(firebaseNotificationRepositoryProvider);
    _initialize();
  }

  Future<void> _initialize() async {
    await _firebaseRepository.initialize();

    // Print token for debugging
    final token = await _firebaseRepository.getToken();
    print('FCM Token: $token');

    if (token != null) {
      final registrarDispositivoUseCase = await ref.read(registrarDispositivoUseCaseProvider.future);
      await registrarDispositivoUseCase.execute(token);
    }

    _firebaseRepository.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    _firebaseRepository.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle navigation here
    });
  }
}
