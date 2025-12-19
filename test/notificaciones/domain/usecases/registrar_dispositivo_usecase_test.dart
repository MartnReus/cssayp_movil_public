import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:cssayp_movil/notificaciones/domain/usecases/registrar_dispositivo_usecase.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'registrar_dispositivo_usecase_test.mocks.dart';

@GenerateMocks([NotificacionesRepository, UsuarioRepository, DeviceInfoPlugin, AndroidDeviceInfo, IosDeviceInfo])
void main() {
  late RegistrarDispositivoUseCase useCase;
  late MockNotificacionesRepository mockNotificacionesRepository;
  late MockUsuarioRepository mockUsuarioRepository;
  late MockDeviceInfoPlugin mockDeviceInfoPlugin;

  setUp(() {
    mockNotificacionesRepository = MockNotificacionesRepository();
    mockUsuarioRepository = MockUsuarioRepository();
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    useCase = RegistrarDispositivoUseCase(
      notificacionesRepository: mockNotificacionesRepository,
      usuarioRepository: mockUsuarioRepository,
      deviceInfoPlugin: mockDeviceInfoPlugin,
    );
  });

  group('RegistrarDispositivoUseCase', () {
    const tToken = 'fcm_token';
    final tUsuario = UsuarioEntity(
      nroAfiliado: 123,
      apellidoNombres: 'Test User',
      cambiarPassword: false,
      username: 'testuser',
    );

    test('debe lanzar AuthNotAuthenticatedException si el usuario es nulo', () async {
      // arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // act
      final call = useCase.execute;

      // assert
      expect(() => call(tToken), throwsA(isA<AuthNotAuthenticatedException>()));
      verify(mockUsuarioRepository.obtenerUsuarioActual());
      verifyZeroInteractions(mockNotificacionesRepository);
      verifyZeroInteractions(mockDeviceInfoPlugin);
    });

    test('debe registrar dispositivo como Desconocido si no es Android ni iOS (Test Environment)', () async {
      // arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => tUsuario);
      when(
        mockNotificacionesRepository.registrarDispositivo(any, any, any, any),
      ).thenAnswer((_) async => Future.value());

      // act
      await useCase.execute(tToken);

      // assert
      verify(mockUsuarioRepository.obtenerUsuarioActual());
      // En entorno de test (Windows/Linux/Mac), Platform.isAndroid y Platform.isIOS son falsos
      verify(
        mockNotificacionesRepository.registrarDispositivo(tToken, tUsuario.nroAfiliado, 'Desconocido', 'Desconocido'),
      );
    });
  });
}
