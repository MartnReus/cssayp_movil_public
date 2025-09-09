import 'package:cssayp_movil/auth/presentation/providers/biometric_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'biometric_auth_service_test.mocks.dart';

const _reason = 'La aplicación necesita verificar su identidad';
const _options = AuthenticationOptions(stickyAuth: true, biometricOnly: false);

@GenerateNiceMocks([MockSpec<LocalAuthentication>()])
void main() {
  group('BiometricAuthService - canCheckBiometrics', () {
    late MockLocalAuthentication mockLocalAuth;
    late BiometricAuthService biometricAuthService;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      biometricAuthService = BiometricAuthService(auth: mockLocalAuth);
    });

    test('debe retornar true cuando LocalAuthentication.canCheckBiometrics es true', () async {
      when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);

      final result = await biometricAuthService.biometriaDisponible();
      expect(result, isTrue);
      verify(mockLocalAuth.canCheckBiometrics).called(1);
    });

    test('debe retornar false cuando LocalAuthentication.canCheckBiometrics lanza PlatformException', () async {
      when(mockLocalAuth.canCheckBiometrics).thenThrow(PlatformException(code: 'notAvailable'));

      final result = await biometricAuthService.biometriaDisponible();
      expect(result, isFalse);
      verify(mockLocalAuth.canCheckBiometrics).called(1);
    });
  });

  group('BiometricAuthService - authenticate', () {
    late MockLocalAuthentication mockLocalAuth;
    late BiometricAuthService biometricAuthService;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      biometricAuthService = BiometricAuthService(auth: mockLocalAuth);
    });

    void stubAuthenticate(bool returnValue) {
      when(
        mockLocalAuth.authenticate(localizedReason: _reason, options: _options),
      ).thenAnswer((_) async => returnValue);
    }

    Future<void> stubAuthenticateThrows(String code) async {
      when(
        mockLocalAuth.authenticate(localizedReason: _reason, options: _options),
      ).thenThrow(PlatformException(code: code));
    }

    test('debe retornar success cuando authenticate devuelve true', () async {
      stubAuthenticate(true);

      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.success));
      verify(mockLocalAuth.authenticate(localizedReason: _reason, options: _options)).called(1);
    });

    test('debe retornar failure cuando authenticate devuelve false', () async {
      stubAuthenticate(false);
      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.failure));
    });

    test('debe retornar notAvailable cuando PlatformException code es notAvailable', () async {
      await stubAuthenticateThrows('notAvailable');

      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.notAvailable));
    });

    test('debe retornar notAvailable cuando PlatformException code es notEnrolled', () async {
      await stubAuthenticateThrows('notEnrolled');

      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.notAvailable));
    });

    test('debe retornar lockedOut cuando PlatformException code es lockedOut', () async {
      await stubAuthenticateThrows('lockedOut');
      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.lockedOut));
    });

    test('debe retornar lockedOut cuando PlatformException code es permanentlyLockedOut', () async {
      await stubAuthenticateThrows('permanentlyLockedOut');
      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.lockedOut));
    });

    test('debe retornar failure cuando PlatformException code es auth_failed', () async {
      await stubAuthenticateThrows('auth_failed');
      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.failure));
    });

    test('debe retornar canceled cuando PlatformException code es Aborted', () async {
      await stubAuthenticateThrows('Aborted');
      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.canceled));
    });

    test('debe retornar platformError para cualquier otro PlatformException', () async {
      await stubAuthenticateThrows('someOther');
      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.platformError));
    });

    test('debe retornar unknownError para cualquier otra excepcion', () async {
      when(mockLocalAuth.authenticate(localizedReason: _reason, options: _options)).thenThrow(Exception('unexpected'));

      final result = await biometricAuthService.autenticar();
      expect(result, equals(BiometricAuthResult.unknownError));
    });
  });
}
