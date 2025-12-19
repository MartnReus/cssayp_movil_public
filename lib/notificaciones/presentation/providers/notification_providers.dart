import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/notificaciones/notificaciones.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/notificaciones/presentation/providers/fcm_notifications_notifier.dart';
import 'package:cssayp_movil/notificaciones/presentation/providers/notificaciones_notifier.dart';

final notificationProvider = NotifierProvider<FcmNotificationNotifier, void>(FcmNotificationNotifier.new);

final registrarDispositivoUseCaseProvider = FutureProvider<RegistrarDispositivoUseCase>((ref) async {
  return RegistrarDispositivoUseCase(
    notificacionesRepository: ref.read(notificacionesRepositoryProvider),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
    deviceInfoPlugin: ref.read(deviceInfoPlusProvider),
  );
});

final obtenerListadoNotificacionesUseCaseProvider = FutureProvider<ObtenerListadoNotificacionesUseCase>((ref) async {
  return ObtenerListadoNotificacionesUseCase(
    notificacionesRepository: ref.read(notificacionesRepositoryProvider),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  );
});

final marcarNotificacionesLeidasUseCaseProvider = FutureProvider<MarcarNotificacionesLeidasUseCase>((ref) async {
  return MarcarNotificacionesLeidasUseCase(
    notificacionesRepository: ref.read(notificacionesRepositoryProvider),
    usuarioRepository: await ref.read(usuarioRepositoryProvider.future),
  );
});

final notificacionesNotifierProvider = AsyncNotifierProvider<NotificacionesNotifier, NotificacionesState>(
  NotificacionesNotifier.new,
);
