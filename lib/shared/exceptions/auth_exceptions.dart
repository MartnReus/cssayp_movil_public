import 'package:cssayp_movil/shared/exceptions/generic_exception.dart';

class AuthException extends GenericException {
  AuthException(super.message, super.code);
}

// Excepciones específicas para almacenamiento local seguro (SecureStorage)
class AuthLocalStorageException extends AuthException {
  AuthLocalStorageException(super.message, super.code);
}

class AuthStorageAccessException extends AuthLocalStorageException {
  AuthStorageAccessException(String details)
    : super('Error al acceder al almacenamiento seguro: $details', 'ERR_STORAGE_ACCESS');
}

class AuthStorageUnavailableException extends AuthLocalStorageException {
  AuthStorageUnavailableException()
    : super('Almacenamiento seguro no disponible en este dispositivo', 'ERR_STORAGE_UNAVAILABLE');
}

// Excepciones específicas para preferencias (SharedPreferences)
class AuthPreferencesException extends AuthException {
  AuthPreferencesException(super.message, super.code);
}

class AuthPreferencesAccessException extends AuthPreferencesException {
  AuthPreferencesAccessException(String details)
    : super('Error al acceder a las preferencias: $details', 'ERR_PREFERENCES_ACCESS');
}

class AuthPreferencesWriteException extends AuthPreferencesException {
  AuthPreferencesWriteException(String details)
    : super('Error al escribir en las preferencias: $details', 'ERR_PREFERENCES_WRITE');
}

class AuthPreferencesReadException extends AuthPreferencesException {
  AuthPreferencesReadException(String details)
    : super('Error al leer las preferencias: $details', 'ERR_PREFERENCES_READ');
}

// Excepción específicas para autenticación
class AuthInvalidCredentialsException extends AuthException {
  AuthInvalidCredentialsException(String message) : super(message, 'ERR_INVALID_CREDENTIALS');
}

class AuthNotAuthenticatedException extends AuthException {
  AuthNotAuthenticatedException(String message) : super(message, 'ERR_NOT_AUTHENTICATED');
}

class AuthGenericLoginException extends AuthException {
  AuthGenericLoginException(String message) : super(message, 'ERR_UNEXPECTED_LOGIN');
}
