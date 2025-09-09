/// Modulo Auth - Manejo de autenticación y usuarios
///
/// Este modulo proporciona funcionalidad para:
/// - Autenticación de usuarios (login, logout)
/// - Recuperación y cambio de contraseñas
/// - Gestión de sesiones y preferencias
/// - Autenticación biométrica
/// - Verificación de estado de autenticación
library;

// Domain Layer
export 'domain/entities/usuario_entity.dart';
export 'domain/entities/datos_usuario_entity.dart';
export 'domain/repositories/usuario_repository.dart';
export 'domain/repositories/preferencias_repository.dart';
export 'domain/usecases/login_use_case.dart';
export 'domain/usecases/cambiar_password_use_case.dart';
export 'domain/usecases/recuperar_password_use_case.dart';
export 'domain/usecases/verificar_estado_autenticacion_use_case.dart';

// Data Layer
export 'data/models/auth_response_models.dart';
export 'data/models/cambiar_password_response_models.dart';
export 'data/models/datos_usuario_response_models.dart';
export 'data/models/recuperar_password_response_models.dart';
export 'data/mappers/cambiar_password_response_mapper.dart';
export 'data/repositories/usuario_repository_impl.dart';
export 'data/repositories/preferencias_repository_impl.dart';
export 'data/datasources/usuario_data_source.dart';
export 'data/datasources/preferencias_data_source.dart';
export 'data/datasources/secure_storage_data_source.dart';

// Presentation Layer
export 'presentation/providers/auth_provider.dart';
export 'presentation/providers/biometric_provider.dart';
export 'presentation/providers/cambiar_password_provider.dart';
export 'presentation/providers/password_recovery_provider.dart';
export 'presentation/screens/home.dart';
export 'presentation/screens/login.dart';
export 'presentation/screens/splash_screen.dart';
export 'presentation/screens/cambiar_password.dart';
export 'presentation/screens/recuperar_password.dart';
export 'presentation/screens/envio_email.dart';
export 'presentation/screens/password_actualizada.dart';
export 'presentation/widgets/login_form.dart';
export 'presentation/widgets/login_biometric.dart';
