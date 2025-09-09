import 'package:cssayp_movil/auth/data/datasources/secure_storage_data_source.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'secure_storage_data_source_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group("SecureStorageDataSource", () {
    late SecureStorageDataSource secureStorageDataSource;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      secureStorageDataSource = SecureStorageDataSource(secureStorage: mockSecureStorage);
    });

    group("guardarToken", () {
      test("debe guardar correctamente el token cuando no hay errores", () async {
        // Arrange
        const token = 'test_token_123';
        when(mockSecureStorage.write(key: 'token', value: token)).thenAnswer((_) async {});

        // Act
        await secureStorageDataSource.guardarToken(token);

        // Assert
        verify(mockSecureStorage.write(key: 'token', value: token)).called(1);
      });

      test("debe lanzar AuthStorageAccessException cuando el usuario cancela la operación", () async {
        // Arrange
        const token = 'test_token_123';
        when(
          mockSecureStorage.write(key: 'token', value: token),
        ).thenThrow(PlatformException(code: 'UserCancel', message: 'Usuario canceló'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.guardarToken(token),
          throwsA(isA<AuthStorageAccessException>()),
        );

        verify(mockSecureStorage.write(key: 'token', value: token)).called(1);
      });

      test("debe lanzar AuthStorageUnavailableException cuando el almacenamiento no está disponible", () async {
        // Arrange
        const token = 'test_token_123';
        when(
          mockSecureStorage.write(key: 'token', value: token),
        ).thenThrow(PlatformException(code: 'NotAvailable', message: 'No disponible'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.guardarToken(token),
          throwsA(isA<AuthStorageUnavailableException>()),
        );

        verify(mockSecureStorage.write(key: 'token', value: token)).called(1);
      });

      test("debe lanzar AuthStorageAccessException para otros errores de plataforma", () async {
        // Arrange
        const token = 'test_token_123';
        when(
          mockSecureStorage.write(key: 'token', value: token),
        ).thenThrow(PlatformException(code: 'UnknownError', message: 'Error desconocido'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.guardarToken(token),
          throwsA(isA<AuthStorageAccessException>()),
        );

        verify(mockSecureStorage.write(key: 'token', value: token)).called(1);
      });

      test("debe lanzar AuthStorageAccessException para errores inesperados", () async {
        // Arrange
        const token = 'test_token_123';
        when(mockSecureStorage.write(key: 'token', value: token)).thenThrow(Exception('Error inesperado'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.guardarToken(token),
          throwsA(isA<AuthStorageAccessException>()),
        );

        verify(mockSecureStorage.write(key: 'token', value: token)).called(1);
      });
    });

    group("obtenerToken", () {
      test("debe retornar el token cuando existe", () async {
        // Arrange
        const expectedToken = 'test_token_123';
        when(mockSecureStorage.read(key: 'token')).thenAnswer((_) async => expectedToken);

        // Act
        final result = await secureStorageDataSource.obtenerToken();

        // Assert
        expect(result, equals(expectedToken));
        verify(mockSecureStorage.read(key: 'token')).called(1);
      });

      test("debe retornar null cuando el token no existe", () async {
        // Arrange
        when(mockSecureStorage.read(key: 'token')).thenAnswer((_) async => null);

        // Act
        final result = await secureStorageDataSource.obtenerToken();

        // Assert
        expect(result, isNull);
        verify(mockSecureStorage.read(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageAccessException cuando el usuario cancela la operación", () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'token'),
        ).thenThrow(PlatformException(code: 'UserCancel', message: 'Usuario canceló'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.obtenerToken(), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.read(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageUnavailableException cuando el almacenamiento no está disponible", () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'token'),
        ).thenThrow(PlatformException(code: 'KeychainError', message: 'Error de keychain'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.obtenerToken(),
          throwsA(isA<AuthStorageUnavailableException>()),
        );

        verify(mockSecureStorage.read(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageAccessException para otros errores de plataforma", () async {
        // Arrange
        when(
          mockSecureStorage.read(key: 'token'),
        ).thenThrow(PlatformException(code: 'UnknownError', message: 'Error desconocido'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.obtenerToken(), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.read(key: 'token')).called(1);
      });

      test("debe re-lanzar errores inesperados sin envolverlos", () async {
        // Arrange
        final unexpectedError = Exception('Error inesperado');
        when(mockSecureStorage.read(key: 'token')).thenThrow(unexpectedError);

        // Act & Assert
        expect(() async => await secureStorageDataSource.obtenerToken(), throwsA(same(unexpectedError)));

        verify(mockSecureStorage.read(key: 'token')).called(1);
      });
    });

    group("eliminarToken", () {
      test("debe eliminar correctamente el token cuando no hay errores", () async {
        // Arrange
        when(mockSecureStorage.delete(key: 'token')).thenAnswer((_) async {});

        // Act
        await secureStorageDataSource.eliminarToken();

        // Assert
        verify(mockSecureStorage.delete(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageAccessException cuando el usuario cancela la operación", () async {
        // Arrange
        when(
          mockSecureStorage.delete(key: 'token'),
        ).thenThrow(PlatformException(code: 'UserFallback', message: 'Usuario canceló'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.eliminarToken(), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.delete(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageUnavailableException cuando el almacenamiento no está disponible", () async {
        // Arrange
        when(
          mockSecureStorage.delete(key: 'token'),
        ).thenThrow(PlatformException(code: 'NotAvailable', message: 'No disponible'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.eliminarToken(),
          throwsA(isA<AuthStorageUnavailableException>()),
        );

        verify(mockSecureStorage.delete(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageAccessException para otros errores de plataforma", () async {
        // Arrange
        when(
          mockSecureStorage.delete(key: 'token'),
        ).thenThrow(PlatformException(code: 'UnknownError', message: 'Error desconocido'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.eliminarToken(), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.delete(key: 'token')).called(1);
      });

      test("debe lanzar AuthStorageAccessException para errores inesperados", () async {
        // Arrange
        when(mockSecureStorage.delete(key: 'token')).thenThrow(Exception('Error inesperado'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.eliminarToken(), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.delete(key: 'token')).called(1);
      });
    });

    group("guardarValor", () {
      test("debe guardar correctamente el valor cuando no hay errores", () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockSecureStorage.write(key: key, value: value)).thenAnswer((_) async {});

        // Act
        await secureStorageDataSource.guardarValor(key, value);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test("debe lanzar AuthStorageAccessException para errores de plataforma", () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(
          mockSecureStorage.write(key: key, value: value),
        ).thenThrow(PlatformException(code: 'UnknownError', message: 'Error de plataforma'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.guardarValor(key, value),
          throwsA(isA<AuthStorageAccessException>()),
        );

        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test("debe lanzar AuthStorageAccessException para errores inesperados", () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockSecureStorage.write(key: key, value: value)).thenThrow(Exception('Error inesperado'));

        // Act & Assert
        expect(
          () async => await secureStorageDataSource.guardarValor(key, value),
          throwsA(isA<AuthStorageAccessException>()),
        );

        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });
    });

    group("obtenerValor", () {
      test("debe retornar el valor cuando existe", () async {
        // Arrange
        const key = 'test_key';
        const expectedValue = 'test_value';
        when(mockSecureStorage.read(key: key)).thenAnswer((_) async => expectedValue);

        // Act
        final result = await secureStorageDataSource.obtenerValor(key);

        // Assert
        expect(result, equals(expectedValue));
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test("debe retornar null cuando el valor no existe", () async {
        // Arrange
        const key = 'non_existent_key';
        when(mockSecureStorage.read(key: key)).thenAnswer((_) async => null);

        // Act
        final result = await secureStorageDataSource.obtenerValor(key);

        // Assert
        expect(result, isNull);
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test("debe lanzar AuthStorageAccessException para errores de plataforma", () async {
        // Arrange
        const key = 'test_key';
        when(
          mockSecureStorage.read(key: key),
        ).thenThrow(PlatformException(code: 'UnknownError', message: 'Error de plataforma'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.obtenerValor(key), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test("debe lanzar AuthStorageAccessException para errores inesperados", () async {
        // Arrange
        const key = 'test_key';
        when(mockSecureStorage.read(key: key)).thenThrow(Exception('Error inesperado'));

        // Act & Assert
        expect(() async => await secureStorageDataSource.obtenerValor(key), throwsA(isA<AuthStorageAccessException>()));

        verify(mockSecureStorage.read(key: key)).called(1);
      });
    });
  });
}
