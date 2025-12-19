import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/main.dart';
import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/notificaciones.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:cssayp_movil/shared/models/pagination_links.dart';
import 'package:cssayp_movil/shared/models/pagination_meta.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/providers/connectivity_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../test/notificaciones/domain/usecases/obtener_listado_notificaciones_usecase_test.mocks.dart';

// Use a fake instead of a mock to avoid "Bad state: Cannot call when within a stub response" issues
// with mockito when we don't need complex interactions.
class FakeFirebaseNotificationRepository implements FirebaseNotificationRepository {
  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getToken() async => 'fake_token';

  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
}

class MockConnectivityNotifier extends ConnectivityNotifier {
  @override
  Stream<ConnectivityStatus> build() {
    return Stream.value(ConnectivityStatus.online);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notificaciones Flow Tests', () {
    testWidgets('Debe mostrar notificaciones y marcarlas como leídas', (tester) async {
      final mockNotificacionesRepository = MockNotificacionesRepository();
      final mockUsuarioRepository = MockUsuarioRepository();
      final fakeFirebaseNotificationRepository = FakeFirebaseNotificationRepository();

      // Setup User
      final testUser = UsuarioEntity(
        nroAfiliado: 999,
        apellidoNombres: 'Test User',
        cambiarPassword: false,
        username: 'test_user',
      );

      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);

      // Setup Notifications
      final notificaciones = [
        NotificacionEntity(
          uuid: '1',
          titulo: 'Pago Imputado',
          mensaje: 'Su pago ha sido imputado correctamente',
          codigoTipo: 'PAGOS_IMPUTADOS',
          fechaEnviado: DateTime.now().subtract(const Duration(hours: 1)),
          fechaLeido: null,
          data: null,
        ),
        NotificacionEntity(
          uuid: '2',
          titulo: 'Boleta por Vencer',
          mensaje: 'Su boleta vence pronto',
          codigoTipo: 'BOLETA_POR_VENCER',
          fechaEnviado: DateTime.now().subtract(const Duration(days: 1)),
          fechaLeido: DateTime.now(),
          data: null,
        ),
      ];

      when(mockNotificacionesRepository.obtenerNotificaciones(999)).thenAnswer((_) async {
        return PaginatedResponse(
          data: notificaciones,
          links: PaginationLinks(),
          meta: PaginationMeta(currentPage: 1, path: '', perPage: 10),
        );
      });

      when(mockNotificacionesRepository.marcarNotificacionesComoLeidas(any, any)).thenAnswer((_) async => {});

      // Override providers
      final container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          notificacionesRepositoryProvider.overrideWith((ref) => mockNotificacionesRepository),
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
          firebaseNotificationRepositoryProvider.overrideWith((ref) => fakeFirebaseNotificationRepository),
        ],
      );

      // Start App
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      // Wait for Home Screen
      await tester.pumpAndSettle();
      expect(find.text('¡Bienvenido!'), findsOneWidget);

      // Navigate to Notifications
      final notificationIcon = find.widgetWithIcon(IconButton, Icons.notifications);
      expect(notificationIcon, findsOneWidget);
      await tester.tap(notificationIcon);
      await tester.pumpAndSettle();

      // Verify Notifications Screen
      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.text('Pago Imputado'), findsOneWidget);
      expect(find.text('Boleta por Vencer'), findsOneWidget);

      // Verify "Mark as Read" logic (implicit)
      // We verify that the repository method was called
      verify(mockNotificacionesRepository.marcarNotificacionesComoLeidas(any, 999)).called(1);
    });

    testWidgets('Debe mostrar estado vacío cuando no hay notificaciones', (tester) async {
      final mockNotificacionesRepository = MockNotificacionesRepository();
      final mockUsuarioRepository = MockUsuarioRepository();
      final fakeFirebaseNotificationRepository = FakeFirebaseNotificationRepository();

      final testUser = UsuarioEntity(
        nroAfiliado: 999,
        apellidoNombres: 'Test User',
        cambiarPassword: false,
        username: 'test_user',
      );

      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);

      when(mockNotificacionesRepository.obtenerNotificaciones(999)).thenAnswer((_) async {
        return PaginatedResponse(
          data: [],
          links: PaginationLinks(),
          meta: PaginationMeta(currentPage: 1, path: '', perPage: 10),
        );
      });

      final container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          notificacionesRepositoryProvider.overrideWith((ref) => mockNotificacionesRepository),
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
          firebaseNotificationRepositoryProvider.overrideWith((ref) => fakeFirebaseNotificationRepository),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();

      expect(find.text('No tienes notificaciones'), findsOneWidget);
    });

    testWidgets('Debe realizar navegación al detalle de la notificación', skip: true, (tester) async {
      final mockNotificacionesRepository = MockNotificacionesRepository();
      final mockUsuarioRepository = MockUsuarioRepository();
      final fakeFirebaseNotificationRepository = FakeFirebaseNotificationRepository();

      final testUser = UsuarioEntity(
        nroAfiliado: 999,
        apellidoNombres: 'Test User',
        cambiarPassword: false,
        username: 'test_user',
      );

      final notificacion = NotificacionEntity(
        uuid: '1',
        titulo: 'Pago Imputado',
        mensaje: 'Su pago ha sido imputado correctamente. El detalle es muy largo para mostrarlo en la lista.',
        codigoTipo: 'PAGOS_IMPUTADOS',
        fechaEnviado: DateTime.now(),
        fechaLeido: null,
        data: null,
      );

      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);

      when(mockNotificacionesRepository.obtenerNotificaciones(999)).thenAnswer((_) async {
        return PaginatedResponse(
          data: [notificacion],
          links: PaginationLinks(),
          meta: PaginationMeta(currentPage: 1, path: '', perPage: 10),
        );
      });

      when(mockNotificacionesRepository.marcarNotificacionesComoLeidas(any, any)).thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          notificacionesRepositoryProvider.overrideWith((ref) => mockNotificacionesRepository),
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
          firebaseNotificationRepositoryProvider.overrideWith((ref) => fakeFirebaseNotificationRepository),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();

      expect(find.text('Pago Imputado'), findsOneWidget);

      // Tap on the notification card using Key
      await tester.tap(find.byKey(const Key('1')));
      await tester.pumpAndSettle();

      // Verify BottomSheet is shown (Detail View)
      expect(
        find.text('Su pago ha sido imputado correctamente. El detalle es muy largo para mostrarlo en la lista.'),
        findsOneWidget,
      );
      expect(find.text('Cerrar'), findsOneWidget);

      // Close BottomSheet
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      // Verify we are back
      expect(find.text('Notificaciones'), findsOneWidget);
    });
  });
}
