import 'dart:io';

import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:device_info_plus/device_info_plus.dart';

class RegistrarDispositivoUseCase {
  final NotificacionesRepository notificacionesRepository;
  final UsuarioRepository usuarioRepository;
  final DeviceInfoPlugin deviceInfoPlugin;

  RegistrarDispositivoUseCase({
    required this.notificacionesRepository,
    required this.usuarioRepository,
    required this.deviceInfoPlugin,
  });

  Future<void> execute(String token) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw AuthNotAuthenticatedException('No hay usuario autenticado');
    }

    String nombreDispositivo = 'Desconocido';
    String plataforma = 'Desconocido';

    if (Platform.isAndroid) {
      plataforma = 'android';
      final androidInfo = await deviceInfoPlugin.androidInfo;
      nombreDispositivo = androidInfo.model;
    } else if (Platform.isIOS) {
      plataforma = 'ios';
      final iosInfo = await deviceInfoPlugin.iosInfo;
      nombreDispositivo = iosInfo.name;
    }

    return notificacionesRepository.registrarDispositivo(token, usuario.nroAfiliado, nombreDispositivo, plataforma);
  }
}
