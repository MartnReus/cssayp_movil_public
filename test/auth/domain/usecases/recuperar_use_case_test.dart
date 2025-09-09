import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/usecases/recuperar_password_use_case.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'recuperar_use_case_test.mocks.dart';

@GenerateMocks([UsuarioRepository])
void main() {
  provideDummy<RecuperarResponseModel>(const RecuperarSuccessResponse(statusCode: 200, success: true));

  group("Funcion de recuperar contraseña (execute)", () {
    late RecuperarPasswordUseCase recuperarPasswordUseCase;
    late MockUsuarioRepository mockUsuarioRepository;

    setUp(() {
      mockUsuarioRepository = MockUsuarioRepository();
      recuperarPasswordUseCase = RecuperarPasswordUseCase(usuarioRepository: mockUsuarioRepository);
    });

    test("execute debe retornar un RecuperarSuccessResponse si los datos enviados son correctos", () async {
      final successResponse = RecuperarSuccessResponse(statusCode: 200, success: true);

      when(mockUsuarioRepository.recuperarPassword(any, any, any)).thenAnswer((_) async => successResponse);

      expect(() => recuperarPasswordUseCase.execute('1234567890', 'test@test.com'), returnsNormally);

      verify(mockUsuarioRepository.recuperarPassword('dni', '1234567890', 'test@test.com')).called(1);
    });

    test("execute debe lanzar una excepción si los datos enviados son incorrectos", () async {
      when(mockUsuarioRepository.recuperarPassword(any, any, any)).thenThrow(
        AuthException(
          'El número de documento no coincide con el que se encuentra en el sistema',
          'ERR_INVALID_CREDENTIALS',
        ),
      );

      expect(() => recuperarPasswordUseCase.execute('1234567890', 'test@test.com'), throwsA(isA<AuthException>()));

      verify(mockUsuarioRepository.recuperarPassword('dni', '1234567890', 'test@test.com')).called(1);
    });

    test("execute debe retornar un RecuperarGenericErrorResponse cuando hay error de conexión", () async {
      final genericErrorResponse = RecuperarGenericErrorResponse(
        statusCode: 500,
        success: false,
        errorMessage: 'Error en la conexión con el servidor',
      );

      when(mockUsuarioRepository.recuperarPassword(any, any, any)).thenAnswer((_) async => genericErrorResponse);

      expect(() => recuperarPasswordUseCase.execute('1234567890', 'test@test.com'), throwsA(isA<AuthException>()));

      verify(mockUsuarioRepository.recuperarPassword('dni', '1234567890', 'test@test.com')).called(1);
    });

    test("execute debe lanzar AuthException cuando ocurre una excepción inesperada", () async {
      when(mockUsuarioRepository.recuperarPassword(any, any, any)).thenThrow(Exception('Error inesperado'));

      expect(() => recuperarPasswordUseCase.execute('1234567890', 'test@test.com'), throwsA(isA<Exception>()));

      verify(mockUsuarioRepository.recuperarPassword('dni', '1234567890', 'test@test.com')).called(1);
    });

    test("execute debe manejar diferentes tipos de parámetros correctamente", () async {
      final successResponse = RecuperarSuccessResponse(statusCode: 200, success: true);

      when(mockUsuarioRepository.recuperarPassword(any, any, any)).thenAnswer((_) async => successResponse);

      // Test con diferentes valores de parámetros
      expect(() => recuperarPasswordUseCase.execute('987654321', 'usuario@test.com'), returnsNormally);
      expect(() => recuperarPasswordUseCase.execute('12345', 'admin@test.com'), returnsNormally);

      verify(mockUsuarioRepository.recuperarPassword('dni', '987654321', 'usuario@test.com')).called(1);
      verify(mockUsuarioRepository.recuperarPassword('naf', '12345', 'admin@test.com')).called(1);
    });
  });
}
