import 'package:cssayp_movil/notificaciones/data/repositories/firebase_notification_repository_impl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firebase_notification_repository_impl_test.mocks.dart';

@GenerateMocks([FirebaseMessaging])
void main() {
  late FirebaseNotificationRepositoryImpl repository;
  late MockFirebaseMessaging mockFirebaseMessaging;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    repository = FirebaseNotificationRepositoryImpl(firebaseMessaging: mockFirebaseMessaging);
  });

  group('initialize', () {
    test('debe solicitar permisos y configurar opciones de presentación en primer plano', () async {
      // arrange
      when(
        mockFirebaseMessaging.requestPermission(
          alert: anyNamed('alert'),
          announcement: anyNamed('announcement'),
          badge: anyNamed('badge'),
          carPlay: anyNamed('carPlay'),
          criticalAlert: anyNamed('criticalAlert'),
          provisional: anyNamed('provisional'),
          sound: anyNamed('sound'),
        ),
      ).thenAnswer(
        (_) async => const NotificationSettings(
          authorizationStatus: AuthorizationStatus.authorized,
          alert: AppleNotificationSetting.enabled,
          announcement: AppleNotificationSetting.disabled,
          badge: AppleNotificationSetting.enabled,
          carPlay: AppleNotificationSetting.disabled,
          criticalAlert: AppleNotificationSetting.disabled,
          lockScreen: AppleNotificationSetting.enabled,
          notificationCenter: AppleNotificationSetting.enabled,
          showPreviews: AppleShowPreviewSetting.always,
          timeSensitive: AppleNotificationSetting.disabled,
          sound: AppleNotificationSetting.enabled,
          providesAppNotificationSettings: AppleNotificationSetting.enabled,
        ),
      );

      when(
        mockFirebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: anyNamed('alert'),
          badge: anyNamed('badge'),
          sound: anyNamed('sound'),
        ),
      ).thenAnswer((_) async => {});

      // act
      await repository.initialize();

      // assert
      verify(
        mockFirebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        ),
      );

      verify(mockFirebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true));
    });
  });

  group('getToken', () {
    test('debe retornar el token de FirebaseMessaging', () async {
      // arrange
      const tToken = 'test_token';
      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => tToken);

      // act
      final result = await repository.getToken();

      // assert
      expect(result, tToken);
      verify(mockFirebaseMessaging.getToken());
    });

    test('debe retornar null si FirebaseMessaging retorna null', () async {
      // arrange
      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => null);

      // act
      final result = await repository.getToken();

      // assert
      expect(result, null);
      verify(mockFirebaseMessaging.getToken());
    });
  });

  group('subscribeToTopic', () {
    test('debe llamar a subscribeToTopic en FirebaseMessaging', () async {
      // arrange
      const tTopic = 'test_topic';
      when(mockFirebaseMessaging.subscribeToTopic(any)).thenAnswer((_) async => {});

      // act
      await repository.subscribeToTopic(tTopic);

      // assert
      verify(mockFirebaseMessaging.subscribeToTopic(tTopic));
    });
  });

  group('unsubscribeFromTopic', () {
    test('debe llamar a unsubscribeFromTopic en FirebaseMessaging', () async {
      // arrange
      const tTopic = 'test_topic';
      when(mockFirebaseMessaging.unsubscribeFromTopic(any)).thenAnswer((_) async => {});

      // act
      await repository.unsubscribeFromTopic(tTopic);

      // assert
      verify(mockFirebaseMessaging.unsubscribeFromTopic(tTopic));
    });
  });
}
