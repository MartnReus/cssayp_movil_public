import 'package:cssayp_movil/auth/data/datasources/preferencias_data_source.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'preferencias_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group("PreferenciasDataSource", () {
    late PreferenciasDataSource preferenciasDataSource;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      preferenciasDataSource = PreferenciasDataSource(prefs: mockSharedPreferences);
    });

    group("guardarPreferenciaBiometria", () {
      test("debe guardar correctamente la preferencia de biometría cuando no hay errores", () async {
        // Arrange
        const valor = true;
        when(mockSharedPreferences.setBool('utilizar_biometria', valor)).thenAnswer((_) async => true);

        // Act
        await preferenciasDataSource.guardarPreferenciaBiometria(valor);

        // Assert
        verify(mockSharedPreferences.setBool('utilizar_biometria', valor)).called(1);
      });

      test("debe lanzar AuthPreferencesWriteException cuando hay un error al guardar", () async {
        // Arrange
        const valor = false;
        when(mockSharedPreferences.setBool('utilizar_biometria', valor)).thenThrow(Exception('Error de escritura'));

        // Act & Assert
        expect(
          () async => await preferenciasDataSource.guardarPreferenciaBiometria(valor),
          throwsA(isA<AuthPreferencesWriteException>()),
        );

        verify(mockSharedPreferences.setBool('utilizar_biometria', valor)).called(1);
      });
    });

    group("obtenerPreferenciaBiometria", () {
      test("debe retornar true cuando la preferencia está guardada como true", () async {
        // Arrange
        when(mockSharedPreferences.getBool('utilizar_biometria')).thenReturn(true);

        // Act
        final result = await preferenciasDataSource.obtenerPreferenciaBiometria();

        // Assert
        expect(result, isTrue);
        verify(mockSharedPreferences.getBool('utilizar_biometria')).called(1);
      });

      test("debe retornar false cuando la preferencia está guardada como false", () async {
        // Arrange
        when(mockSharedPreferences.getBool('utilizar_biometria')).thenReturn(false);

        // Act
        final result = await preferenciasDataSource.obtenerPreferenciaBiometria();

        // Assert
        expect(result, isFalse);
        verify(mockSharedPreferences.getBool('utilizar_biometria')).called(1);
      });

      test("debe retornar false cuando la preferencia no existe (null)", () async {
        // Arrange
        when(mockSharedPreferences.getBool('utilizar_biometria')).thenReturn(null);

        // Act
        final result = await preferenciasDataSource.obtenerPreferenciaBiometria();

        // Assert
        expect(result, isFalse);
        verify(mockSharedPreferences.getBool('utilizar_biometria')).called(1);
      });

      test("debe lanzar AuthPreferencesReadException cuando hay un error al leer", () async {
        // Arrange
        when(mockSharedPreferences.getBool('utilizar_biometria')).thenThrow(Exception('Error de lectura'));

        // Act & Assert
        expect(
          () async => await preferenciasDataSource.obtenerPreferenciaBiometria(),
          throwsA(isA<AuthPreferencesReadException>()),
        );

        verify(mockSharedPreferences.getBool('utilizar_biometria')).called(1);
      });
    });

    group("obtenerValor", () {
      test("debe retornar el valor correcto cuando existe", () async {
        // Arrange
        const key = 'test_key';
        const expectedValue = 'test_value';
        when(mockSharedPreferences.getString(key)).thenReturn(expectedValue);

        // Act
        final result = await preferenciasDataSource.obtenerValor(key);

        // Assert
        expect(result, equals(expectedValue));
        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test("debe retornar null cuando la clave no existe", () async {
        // Arrange
        const key = 'non_existent_key';
        when(mockSharedPreferences.getString(key)).thenReturn(null);

        // Act
        final result = await preferenciasDataSource.obtenerValor(key);

        // Assert
        expect(result, isNull);
        verify(mockSharedPreferences.getString(key)).called(1);
      });

      test("debe lanzar AuthPreferencesReadException cuando hay un error al leer", () async {
        // Arrange
        const key = 'test_key';
        when(mockSharedPreferences.getString(key)).thenThrow(Exception('Error de lectura'));

        // Act & Assert
        expect(
          () async => await preferenciasDataSource.obtenerValor(key),
          throwsA(isA<AuthPreferencesReadException>()),
        );

        verify(mockSharedPreferences.getString(key)).called(1);
      });
    });

    group("guardarValor", () {
      test("debe guardar correctamente el valor cuando no hay errores", () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockSharedPreferences.setString(key, value)).thenAnswer((_) async => true);

        // Act
        await preferenciasDataSource.guardarValor(key, value);

        // Assert
        verify(mockSharedPreferences.setString(key, value)).called(1);
      });

      test("debe lanzar AuthPreferencesWriteException cuando hay un error al guardar", () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockSharedPreferences.setString(key, value)).thenThrow(Exception('Error de escritura'));

        // Act & Assert
        expect(
          () async => await preferenciasDataSource.guardarValor(key, value),
          throwsA(isA<AuthPreferencesWriteException>()),
        );

        verify(mockSharedPreferences.setString(key, value)).called(1);
      });
    });
  });
}
