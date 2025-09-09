import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

class SecureStorageDataSource {
  final FlutterSecureStorage _secureStorage;

  SecureStorageDataSource({required FlutterSecureStorage secureStorage}) : _secureStorage = secureStorage;

  Future<void> guardarToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel' || e.code == 'UserFallback') {
        throw AuthStorageAccessException('Operación cancelada por el usuario');
      } else if (e.code == 'NotAvailable' || e.code == 'KeychainError') {
        throw AuthStorageUnavailableException();
      } else {
        throw AuthStorageAccessException('Error de plataforma: ${e.message}');
      }
    } catch (e) {
      throw AuthStorageAccessException('Error inesperado: $e');
    }
  }

  Future<String?> obtenerToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel' || e.code == 'UserFallback') {
        throw AuthStorageAccessException('Operación cancelada por el usuario');
      } else if (e.code == 'NotAvailable' || e.code == 'KeychainError') {
        throw AuthStorageUnavailableException();
      } else {
        throw AuthStorageAccessException('Error de plataforma: ${e.message}');
      }
    }
  }

  Future<void> eliminarToken() async {
    try {
      await _secureStorage.delete(key: 'token');
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel' || e.code == 'UserFallback') {
        throw AuthStorageAccessException('Operación cancelada por el usuario');
      } else if (e.code == 'NotAvailable' || e.code == 'KeychainError') {
        throw AuthStorageUnavailableException();
      } else {
        throw AuthStorageAccessException('Error de plataforma: ${e.message}');
      }
    } catch (e) {
      throw AuthStorageAccessException('Error inesperado: $e');
    }
  }

  Future<void> guardarValor(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } on PlatformException catch (e) {
      throw AuthStorageAccessException('Error de plataforma: ${e.message}');
    } catch (e) {
      throw AuthStorageAccessException('Error inesperado: $e');
    }
  }

  Future<String?> obtenerValor(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } on PlatformException catch (e) {
      throw AuthStorageAccessException('Error de plataforma: ${e.message}');
    } catch (e) {
      throw AuthStorageAccessException('Error inesperado: $e');
    }
  }
}
