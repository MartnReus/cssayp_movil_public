import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/repositories/preferencias_repository.dart';
import 'package:cssayp_movil/auth/presentation/providers/auth_provider.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

@GenerateNiceMocks([MockSpec<UsuarioRepository>(), MockSpec<PreferenciasRepository>()])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider (Mockito)', () {
    late ProviderContainer container;
    // Declara tus mocks
    late MockUsuarioRepository mockUsuarioRepository;
    late MockPreferenciasRepository mockPreferenciasRepository;

    setUp(() {
      mockUsuarioRepository = MockUsuarioRepository();
      mockPreferenciasRepository = MockPreferenciasRepository();

      // Valores iniciales
      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      // Crea el ProviderContainer sobrescribiendo las dependencias por los mocks
      container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          preferenciasRepositoryProvider.overrideWith((ref) => Future.value(mockPreferenciasRepository)),
        ],
      );
    });

    // Limpia el container después de cada test y resetea los mocks
    tearDown(() {
      container.dispose();
      reset(mockUsuarioRepository);
      reset(mockPreferenciasRepository);
    });

    test(
      'El estado inicial del AuthProvider debería ser AuthStatus.noAutenticado si no hay usuario autenticado',
      () async {
        // Arrange
        when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => false);

        // Act
        await container.read(authProvider.future);

        // Assert
        final authState = container.read(authProvider).value;
        expect(authState, isNotNull);
        expect(authState?.status, AuthStatus.noAutenticado);
        expect(authState?.usuario, isNull);

        verify(mockUsuarioRepository.estaAutenticado()).called(1);
      },
    );

    test(
      'login debería actualizar el estado a autenticadoNoRequiereBiometria en login exitoso sin biometría',
      () async {
        // Arrange
        final testUser = UsuarioEntity(
          nroAfiliado: 123,
          apellidoNombres: 'Test, User',
          cambiarPassword: false,
          username: 'testuser',
        );

        when(mockUsuarioRepository.autenticar('testuser', 'password')).thenAnswer((_) async => testUser);
        when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);
        when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

        // Para inicializar el provider (sino da error)
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).login('testuser', 'password');

        // Assert
        final authState = container.read(authProvider).value;
        expect(authState, isNotNull);
        expect(authState?.status, AuthStatus.autenticadoNoRequiereBiometria);
        expect(authState?.usuario, testUser);

        verify(mockUsuarioRepository.autenticar('testuser', 'password')).called(1);
        verify(mockUsuarioRepository.estaAutenticado()).called(greaterThanOrEqualTo(1));
        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(greaterThanOrEqualTo(1));
        verify(mockPreferenciasRepository.obtenerPreferenciaBiometria()).called(greaterThanOrEqualTo(1));
      },
    );

    test('logout debería actualizar el estado a AuthStatus.noAutenticado', () async {
      // Arrange
      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer(
        (_) async => UsuarioEntity(nroAfiliado: 1, apellidoNombres: 'A', cambiarPassword: false, username: 'user'),
      );
      await container.read(authProvider.future);

      when(mockUsuarioRepository.cerrarSesion()).thenAnswer((_) async => Future.value());

      // Act
      await container.read(authProvider.notifier).logout();

      // Assert
      final authState = container.read(authProvider).value;
      expect(authState, isNotNull);
      expect(authState?.status, AuthStatus.noAutenticado);
      expect(authState?.usuario, isNull);

      verify(mockUsuarioRepository.cerrarSesion()).called(1);
    });

    test('actualizarPreferenciaBiometria debería cambiar la preferencia y refrescar el estado', () async {
      // Arrange
      final testUser = UsuarioEntity(
        nroAfiliado: 123,
        apellidoNombres: 'Test, User',
        cambiarPassword: false,
        username: 'testuser',
      );
      when(mockUsuarioRepository.autenticar('testuser', 'password')).thenAnswer((_) async => testUser);
      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);
      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      await container.read(authProvider.future);

      // Act: Login
      await container.read(authProvider.notifier).login('testuser', 'password');
      expect(container.read(authProvider).value?.status, AuthStatus.autenticadoNoRequiereBiometria);

      // Act: Habilitar biometría
      when(mockPreferenciasRepository.guardarPreferenciaBiometria(true)).thenAnswer((_) async => Future.value());
      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => true);

      await container.read(authProvider.notifier).actualizarPreferenciaBiometria(true);

      // Assert
      final authStateAfterBiometric = container.read(authProvider).value;
      expect(authStateAfterBiometric, isNotNull);
      expect(authStateAfterBiometric?.status, AuthStatus.autenticadoRequiereBiometria);
      expect(await container.read(authProvider.notifier).getBiometriaHabilitada(), true);
      verify(mockPreferenciasRepository.guardarPreferenciaBiometria(true)).called(1);

      // Act: Deshabilitar biometría
      when(mockPreferenciasRepository.guardarPreferenciaBiometria(false)).thenAnswer((_) async => Future.value());
      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      await container.read(authProvider.notifier).actualizarPreferenciaBiometria(false);

      // Assert
      final authStateAfterNoBiometric = container.read(authProvider).value;
      expect(authStateAfterNoBiometric, isNotNull);
      expect(authStateAfterNoBiometric?.status, AuthStatus.autenticadoNoRequiereBiometria);
      expect(await container.read(authProvider.notifier).getBiometriaHabilitada(), false);
      verify(mockPreferenciasRepository.guardarPreferenciaBiometria(false)).called(1);
    });

    test('login debería lanzar AuthException para credenciales incorrectas', () async {
      // Arrange
      when(mockUsuarioRepository.autenticar('wronguser', 'wrongpassword')).thenAnswer((_) async => null);
      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => false);

      await container.read(authProvider.future);

      // Act
      await container.read(authProvider.notifier).login('wronguser', 'wrongpassword');

      // Assert
      final authState = container.read(authProvider);
      expect(authState.hasError, true);
      expect(authState.error, isA<AuthException>());
      expect((authState.error as AuthException).code, 'ERR_INVALID_CREDENTIALS');

      verify(mockUsuarioRepository.autenticar('wronguser', 'wrongpassword')).called(1);
    });

    test('refresh debería actualizar el estado de autenticación', () async {
      // Arrange
      final testUser = UsuarioEntity(
        nroAfiliado: 123,
        apellidoNombres: 'Test, Refresh',
        cambiarPassword: false,
        username: 'testuser',
      );

      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => false);
      await container.read(authProvider.future);
      expect(container.read(authProvider).value?.status, AuthStatus.noAutenticado);

      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);
      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      // Act
      await container.read(authProvider.notifier).refresh();

      // Assert
      final authState = container.read(authProvider).value;
      expect(authState, isNotNull);
      expect(authState?.status, AuthStatus.autenticadoNoRequiereBiometria);
      expect(authState?.usuario, testUser);

      verify(mockUsuarioRepository.estaAutenticado()).called(greaterThanOrEqualTo(1));
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(greaterThanOrEqualTo(1));
      verify(mockPreferenciasRepository.obtenerPreferenciaBiometria()).called(greaterThanOrEqualTo(1));
    });
  });
}
