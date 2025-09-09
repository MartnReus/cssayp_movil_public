import 'dart:async';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/usecases/recuperar_password_use_case.dart';
import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';
import 'package:cssayp_movil/auth/presentation/providers/password_recovery_provider.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

@GenerateNiceMocks([MockSpec<UsuarioRepository>(), MockSpec<RecuperarPasswordUseCase>()])
import 'password_recovery_provider_test.mocks.dart';

void main() {
  provideDummy<RecuperarResponseModel>(
    const RecuperarGenericErrorResponse(statusCode: 500, success: false, errorMessage: 'Dummy error response'),
  );

  group('PasswordRecoveryProvider (Mockito)', () {
    late ProviderContainer container;
    late MockUsuarioRepository mockUsuarioRepository;
    late MockRecuperarPasswordUseCase mockRecuperarPasswordUseCase;

    setUp(() {
      mockUsuarioRepository = MockUsuarioRepository();
      mockRecuperarPasswordUseCase = MockRecuperarPasswordUseCase();

      // Crea el ProviderContainer sobrescribiendo las dependencias por los mocks
      container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          recuperarPasswordUseCaseProvider.overrideWith((ref) => Future.value(mockRecuperarPasswordUseCase)),
        ],
      );
    });

    // Limpia el container después de cada test y resetea los mocks
    tearDown(() {
      container.dispose();
      reset(mockUsuarioRepository);
      reset(mockRecuperarPasswordUseCase);
    });

    test(
      'El estado inicial del PasswordRecoveryProvider debería ser PasswordRecoveryState con isSuccess = false',
      () async {
        // Act
        final state = await container.read(passwordRecoveryProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.isSuccess, false);
      },
    );

    test('recuperarPassword debería actualizar el estado a success cuando la operación es exitosa', () async {
      // Arrange
      final successResponse = const RecuperarSuccessResponse(statusCode: 200, success: true);

      when(mockRecuperarPasswordUseCase.execute('12345', 'test@example.com')).thenAnswer((_) async => successResponse);

      await container.read(passwordRecoveryProvider.future);
      // Act
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('12345', 'test@example.com');

      // Assert - Esperar a que el estado se actualice completamente
      await Future.delayed(const Duration(milliseconds: 10));

      final state = container.read(passwordRecoveryProvider);
      expect(state.hasValue, true);
      expect(state.value?.isSuccess, true);

      verify(mockRecuperarPasswordUseCase.execute('12345', 'test@example.com')).called(1);
    });

    test('recuperarPassword debería actualizar el estado con error cuando la operación falla', () async {
      // Arrange
      when(
        mockRecuperarPasswordUseCase.execute('9999999', 'wrong@example.com'),
      ).thenThrow(AuthException('Datos incorrectos o usuario no encontrado', 'ERR_INVALID_CREDENTIALS'));

      await container.read(passwordRecoveryProvider.future);
      // Act
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('9999999', 'wrong@example.com');

      // Assert
      final state = container.read(passwordRecoveryProvider);
      expect(state.hasError, true);
      expect(state.error, isA<AuthException>());
      expect((state.error as AuthException).message, equals('Datos incorrectos o usuario no encontrado'));
      expect((state.error as AuthException).code, equals('ERR_INVALID_CREDENTIALS'));

      verify(mockRecuperarPasswordUseCase.execute('9999999', 'wrong@example.com')).called(1);
    });

    test('recuperarPassword debería manejar errores genéricos del servidor', () async {
      // Arrange
      when(
        mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com'),
      ).thenThrow(AuthException('Error interno del servidor', 'ERR_UNEXPECTED_PASS_RECOVERY'));

      await container.read(passwordRecoveryProvider.future);
      // Act
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('12345678', 'test@example.com');

      // Assert
      final state = container.read(passwordRecoveryProvider);
      expect(state.hasError, true);
      expect(state.error, isA<AuthException>());
      expect((state.error as AuthException).message, equals('Error interno del servidor'));
      expect((state.error as AuthException).code, equals('ERR_UNEXPECTED_PASS_RECOVERY'));

      verify(mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com')).called(1);
    });

    test('reset debería reiniciar el estado del provider', () async {
      // Arrange - Primero cambiar el estado a success
      final successResponse = const RecuperarSuccessResponse(statusCode: 200, success: true);

      when(
        mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com'),
      ).thenAnswer((_) async => successResponse);

      await container.read(passwordRecoveryProvider.future);
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('12345678', 'test@example.com');

      // Verificar que el estado es success
      expect(container.read(passwordRecoveryProvider).value?.isSuccess, true);

      // Act
      container.read(passwordRecoveryProvider.notifier).reset();

      // Assert - Esperar a que el estado se actualice completamente
      await Future.delayed(const Duration(milliseconds: 10));

      final state = container.read(passwordRecoveryProvider);
      expect(state.hasValue, true);
      expect(state.value?.isSuccess, false);
    });

    test('recuperarPassword debería mostrar estado de loading durante la operación', () async {
      // Arrange
      final successResponse = const RecuperarSuccessResponse(statusCode: 200, success: true);

      // Usar un Completer para controlar exactamente cuándo se completa la operación
      final completer = Completer<RecuperarResponseModel>();

      when(mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com')).thenAnswer((_) {
        return completer.future;
      });

      await container.read(passwordRecoveryProvider.future);
      // Act - Iniciar la operación
      final future = container
          .read(passwordRecoveryProvider.notifier)
          .recuperarPassword('12345678', 'test@example.com');

      // Assert - Verificar que está en estado de loading inmediatamente después de iniciar
      // Esperar un microtick para asegurar que el estado se actualice
      await Future.microtask(() {});

      final loadingState = container.read(passwordRecoveryProvider);
      expect(loadingState.isLoading, true);

      // Completar la operación
      completer.complete(successResponse);

      // Esperar a que termine la operación
      await future;

      // Verificar el estado final
      final finalState = container.read(passwordRecoveryProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value?.isSuccess, true);
    });

    test('recuperarPassword debería manejar excepciones del use case', () async {
      // Arrange
      when(
        mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com'),
      ).thenThrow(Exception('Error de conexión'));

      await container.read(passwordRecoveryProvider.future);

      // Act
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('12345678', 'test@example.com');

      // Assert
      final state = container.read(passwordRecoveryProvider);
      expect(state.hasError, true);
      expect(state.error, isA<Exception>());
      expect((state.error as Exception).toString(), contains('Error de conexión'));

      verify(mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com')).called(1);
    });

    test('recuperarPassword debería convertir correctamente el nroAfiliado de String a int', () async {
      // Arrange
      final successResponse = const RecuperarSuccessResponse(statusCode: 200, success: true);

      when(
        mockRecuperarPasswordUseCase.execute('87654321', 'user@example.com'),
      ).thenAnswer((_) async => successResponse);

      await container.read(passwordRecoveryProvider.future);

      // Act
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('87654321', 'user@example.com');

      // Assert
      final state = container.read(passwordRecoveryProvider);
      expect(state.hasValue, true);
      expect(state.value?.isSuccess, true);

      verify(mockRecuperarPasswordUseCase.execute('87654321', 'user@example.com')).called(1);
    });

    test('recuperarPassword debería manejar múltiples llamadas consecutivas', () async {
      // Arrange
      final successResponse = const RecuperarSuccessResponse(statusCode: 200, success: true);

      when(
        mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com'),
      ).thenAnswer((_) async => successResponse);

      await container.read(passwordRecoveryProvider.future);

      // Act - Primera llamada
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('12345678', 'test@example.com');

      // Verificar primera llamada
      expect(container.read(passwordRecoveryProvider).value?.isSuccess, true);

      // Reset para segunda llamada
      container.read(passwordRecoveryProvider.notifier).reset();

      // Segunda llamada
      await container.read(passwordRecoveryProvider.notifier).recuperarPassword('12345678', 'test@example.com');

      // Assert
      final state = container.read(passwordRecoveryProvider);
      expect(state.hasValue, true);
      expect(state.value?.isSuccess, true);

      verify(mockRecuperarPasswordUseCase.execute('12345678', 'test@example.com')).called(2);
    });
  });
}
