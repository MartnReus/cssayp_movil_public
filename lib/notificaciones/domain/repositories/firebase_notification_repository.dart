import 'package:firebase_messaging/firebase_messaging.dart';

abstract interface class FirebaseNotificationRepository {
  Future<void> initialize();
  Future<String?> getToken();
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
}
