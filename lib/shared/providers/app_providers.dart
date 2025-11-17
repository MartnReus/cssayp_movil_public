import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/database/database_helper.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';
import 'package:cssayp_movil/shared/services/pdf_service.dart';
import 'package:cssayp_movil/shared/services/permission_handler_service.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
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

final juiciosRepositoryProvider = FutureProvider<JuiciosRepository>(
  (ref) async => JuiciosRepositoryImpl(dataSource: ref.read(boletasDataSourceProvider)),
);

final paywayRepositoryProvider = FutureProvider<PaywayRepository>(
  (ref) async => PaywayRepositoryImpl(paywayDataSource: ref.read(paywayDataSourceProvider)),
);

final comprobantesRepositoryProvider = FutureProvider<ComprobantesRepository>(
  (ref) async => ComprobantesRepositoryImpl(
    comprobantesLocalDataSource: ref.read(comprobantesLocalDataSourceProvider),
    comprobantesRemoteDataSource: ref.read(comprobantesRemoteDataSourceProvider),
  ),
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

final comprobantesLocalDataSourceProvider = Provider<ComprobantesLocalDataSource>(
  (ref) => ComprobantesLocalDataSource(databaseHelper: ref.read(databaseHelperProvider)),
);

final comprobantesRemoteDataSourceProvider = Provider<ComprobantesRemoteDataSource>(
  (ref) => ComprobantesRemoteDataSource(client: ref.read(httpClientProvider)),
);

//--------------------------------------

//--------- Services -------------------
final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

final jwtTokenServiceProvider = Provider<JwtTokenService>(
  (ref) => JwtTokenService(secureStorageDataSource: ref.read(secureStorageDataSourceProvider)),
);

final pdfServiceProvider = Provider<PdfService>((ref) => PdfService());

final permissionHandlerServiceProvider = Provider<PermissionHandlerService>(
  (ref) => PermissionHandlerService(deviceInfo: ref.read(deviceInfoPlusProvider)),
);
//--------------------------------------

// -------- External Libraries --------
final deviceInfoPlusProvider = Provider<DeviceInfoPlugin>((ref) => DeviceInfoPlugin());

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) async => await SharedPreferences.getInstance(),
);

final sharePlusProvider = Provider<SharePlus>((ref) => SharePlus.instance);
//--------------------------------------
