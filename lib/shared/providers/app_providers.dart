import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';
import 'package:cssayp_movil/shared/database/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//--------- Repositories ----------------
final usuarioRepositoryProvider = FutureProvider<UsuarioRepository>(
  (ref) async => UsuarioRepositoryImpl(
    usuarioDataSource: ref.read(usuarioDataSourceProvider),
    secureStorageDataSource: ref.read(secureStorageDataSourceProvider),
    preferenciasDataSource: await ref.read(preferenciasDataSourceProvider.future),
  ),
);

final preferenciasRepositoryProvider = FutureProvider<PreferenciasRepository>(
  (ref) async =>
      PreferenciasRepositoryImpl(preferenciasDataSource: await ref.read(preferenciasDataSourceProvider.future)),
);

final boletasRepositoryProvider = FutureProvider<BoletasRepository>(
  (ref) async => BoletasRepositoryImpl(
    boletasDataSource: ref.read(boletasDataSourceProvider),
    boletasLocalDataSource: ref.read(boletasLocalDataSourceProvider),
    jwtTokenService: ref.read(jwtTokenServiceProvider),
  ),
);

final paywayRepositoryProvider = FutureProvider<PaywayRepository>(
  (ref) async => PaywayRepositoryImpl(paywayDataSource: ref.read(paywayDataSourceProvider)),
);

//--------------------------------------

//--------- Data sources ---------------
final secureStorageDataSourceProvider = Provider<SecureStorageDataSource>(
  (ref) => SecureStorageDataSource(secureStorage: ref.read(secureStorageProvider)),
);

final usuarioDataSourceProvider = Provider<UsuarioDataSource>(
  (ref) => UsuarioDataSource(client: ref.read(httpClientProvider)),
);

final preferenciasDataSourceProvider = FutureProvider<PreferenciasDataSource>(
  (ref) async => PreferenciasDataSource(prefs: await ref.read(sharedPreferencesProvider.future)),
);

final boletasDataSourceProvider = Provider<BoletasDataSource>(
  (ref) => BoletasDataSource(client: ref.read(httpClientProvider)),
);

final boletasLocalDataSourceProvider = Provider<BoletasLocalDataSource>(
  (ref) => BoletasLocalDataSource(databaseHelper: ref.read(databaseHelperProvider)),
);

final paywayDataSourceProvider = Provider<PaywayDataSource>(
  (ref) => PaywayDataSource(client: ref.read(httpClientProvider)),
);

//--------------------------------------

//--------- Services -------------------
final jwtTokenServiceProvider = Provider<JwtTokenService>(
  (ref) => JwtTokenService(secureStorageDataSource: ref.read(secureStorageDataSourceProvider)),
);

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());
//--------------------------------------

// -------- External Libraries --------
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) async => await SharedPreferences.getInstance(),
);

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final httpClientProvider = Provider<http.Client>((ref) => http.Client());
//--------------------------------------
