import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart'; // For PlatformException

// Posibles resultados de la autenticacion
enum BiometricAuthResult { success, failure, notAvailable, lockedOut, canceled, platformError, unknownError }

// Servicio de autenticacion
class BiometricAuthService {
  final LocalAuthentication _auth;

  BiometricAuthService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  // Verifica si la biometria esta disponible
  Future<bool> biometriaDisponible() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  // Autentica usando la biometria
  Future<BiometricAuthResult> autenticar() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'La aplicación necesita verificar su identidad',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );

      if (didAuthenticate) {
        return BiometricAuthResult.success;
      } else {
        return BiometricAuthResult.failure;
      }
    } on PlatformException catch (e) {
      if (e.code == 'notAvailable' || e.code == 'notEnrolled') {
        return BiometricAuthResult.notAvailable;
      } else if (e.code == 'lockedOut' || e.code == 'permanentlyLockedOut') {
        return BiometricAuthResult.lockedOut;
      } else if (e.code == 'auth_failed') {
        return BiometricAuthResult.failure;
      } else if (e.code == 'Aborted') {
        return BiometricAuthResult.canceled;
      }
      return BiometricAuthResult.platformError;
    } catch (e) {
      return BiometricAuthResult.unknownError;
    }
  }
}

final biometricAuthServiceProvider = Provider((ref) => BiometricAuthService());
