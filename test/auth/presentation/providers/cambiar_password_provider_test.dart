import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/usecases/cambiar_password_use_case.dart';
import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:cssayp_movil/auth/presentation/providers/cambiar_password_provider.dart';
import 'package:cssayp_movil/shared/exceptions/password_exceptions.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

@GenerateNiceMocks([MockSpec<UsuarioRepository>(), MockSpec<CambiarPasswordUseCase>()])
import 'cambiar_password_provider_test.mocks.dart';

void main() {
  provideDummy<CambiarPasswordResponseModel>(
    const CambiarPasswordGenericErrorResponse(statusCode: 500, estado: false, mensaje: 'Dummy error response'),
  );
  group('CambiarPasswordProvider (Mockito)', () {
    late ProviderContainer container;
    late MockUsuarioRepository mockUsuarioRepository;
    late MockCambiarPasswordUseCase mockCambiarPasswordUseCase;

    setUp(() {
      mockUsuarioRepository = MockUsuarioRepository();
      mockCambiarPasswordUseCase = MockCambiarPasswordUseCase();

      // Crea el ProviderContainer sobrescribiendo las dependencias por los mocks
      container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          cambiarPasswordUseCaseProvider.overrideWith((ref) => Future.value(mockCambiarPasswordUseCase)),
        ],
      );
    });

    // Limpia el container después de cada test y resetea los mocks
    tearDown(() {
      container.dispose();
      reset(mockUsuarioRepository);
      reset(mockCambiarPasswordUseCase);
    });

    test(
      'El estado inicial del CambiarPasswordProvider debería ser CambiarPasswordState con isSuccess = false',
      () async {
        // Act
        final state = await container.read(cambiarPasswordProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.isSuccess, false);
      },
    );

    test('cambiarPassword debería actualizar el estado a success cuando la operación es exitosa', () async {
      // Arrange
      final successResponse = const CambiarPasswordSuccessResponse(
        statusCode: 200,
        estado: true,
        mensaje: 'Contraseña cambiada exitosamente',
      );

      when(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).thenAnswer((_) async => successResponse);

      await container.read(cambiarPasswordProvider.future);
      // Act
      await container.read(cambiarPasswordProvider.notifier).cambiarPassword('oldPassword', 'newPassword');

      // Assert - Esperar a que el estado se actualice completamente
      await Future.delayed(const Duration(milliseconds: 10));

      final state = container.read(cambiarPasswordProvider);
      expect(state.hasValue, true);
      expect(state.value?.isSuccess, true);

      verify(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).called(1);
    });

    test('cambiarPassword debería lanzar IncorrectPasswordException cuando la operación falla', () async {
      // Arrange
      final errorResponse = const CambiarPasswordInvalidCredentialsResponse(
        statusCode: 400,
        estado: false,
        mensaje: 'Contraseña actual incorrecta',
      );

      when(mockCambiarPasswordUseCase.execute('wrongPassword', 'newPassword')).thenAnswer((_) async => errorResponse);

      await container.read(cambiarPasswordProvider.future);
      // Act
      await container.read(cambiarPasswordProvider.notifier).cambiarPassword('wrongPassword', 'newPassword');

      // Assert
      final state = container.read(cambiarPasswordProvider);
      expect(state.hasError, true);
      expect(state.error, isA<IncorrectPasswordException>());
      expect((state.error as IncorrectPasswordException).message, 'Contraseña actual incorrecta');
      expect((state.error as IncorrectPasswordException).code, 'ERR_INCORRECT_PASSWORD');

      verify(mockCambiarPasswordUseCase.execute('wrongPassword', 'newPassword')).called(1);
    });

    test('cambiarPassword debería manejar errores genéricos del servidor', () async {
      // Arrange
      final genericErrorResponse = const CambiarPasswordGenericErrorResponse(
        statusCode: 500,
        estado: false,
        mensaje: 'Error interno del servidor',
      );

      when(
        mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword'),
      ).thenAnswer((_) async => genericErrorResponse);

      await container.read(cambiarPasswordProvider.future);
      // Act
      await container.read(cambiarPasswordProvider.notifier).cambiarPassword('oldPassword', 'newPassword');

      // Assert
      final state = container.read(cambiarPasswordProvider);
      expect(state.hasError, true);
      expect(state.error, isA<IncorrectPasswordException>());
      expect((state.error as IncorrectPasswordException).message, 'Error interno del servidor');

      verify(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).called(1);
    });

    test('reset debería reiniciar el estado del provider', () async {
      // Arrange - Primero cambiar el estado a success
      final successResponse = const CambiarPasswordSuccessResponse(
        statusCode: 200,
        estado: true,
        mensaje: 'Contraseña cambiada exitosamente',
      );

      when(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).thenAnswer((_) async => successResponse);

      await container.read(cambiarPasswordProvider.future);
      await container.read(cambiarPasswordProvider.notifier).cambiarPassword('oldPassword', 'newPassword');

      // Verificar que el estado es success
      expect(container.read(cambiarPasswordProvider).value?.isSuccess, true);

      // Act
      container.read(cambiarPasswordProvider.notifier).reset();

      // Assert
      final state = container.read(cambiarPasswordProvider);
      expect(state.hasValue, true);
      expect(state.value?.isSuccess, false);
    });

    test('cambiarPassword debería mostrar estado de loading durante la operación', () async {
      // Arrange
      final successResponse = const CambiarPasswordSuccessResponse(
        statusCode: 200,
        estado: true,
        mensaje: 'Contraseña cambiada exitosamente',
      );

      // Usar un Completer para controlar exactamente cuándo se completa la operación
      final completer = Completer<CambiarPasswordResponseModel>();

      when(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).thenAnswer((_) async {
        return await completer.future;
      });

      await container.read(cambiarPasswordProvider.future);
      // Act - Iniciar la operación
      final future = container.read(cambiarPasswordProvider.notifier).cambiarPassword('oldPassword', 'newPassword');

      // Assert - Verificar que está en estado de loading inmediatamente después de iniciar
      // Esperar un microtick para asegurar que el estado se actualice
      await Future.microtask(() {});

      final loadingState = container.read(cambiarPasswordProvider);
      expect(loadingState.isLoading, true);

      // Completar la operación
      completer.complete(successResponse);

      // Esperar a que termine la operación
      await future;

      // Verificar el estado final
      final finalState = container.read(cambiarPasswordProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value?.isSuccess, true);
    });

    test('cambiarPassword debería manejar excepciones del repositorio', () async {
      // Arrange
      when(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).thenThrow(Exception('Error de conexión'));

      await container.read(cambiarPasswordProvider.future);
      // Act
      await container.read(cambiarPasswordProvider.notifier).cambiarPassword('oldPassword', 'newPassword');

      // Assert
      final state = container.read(cambiarPasswordProvider);
      expect(state.hasError, true);
      expect(state.error, isA<Exception>());
      expect((state.error as Exception).toString(), contains('Error de conexión'));

      verify(mockCambiarPasswordUseCase.execute('oldPassword', 'newPassword')).called(1);
    });
  });
}
