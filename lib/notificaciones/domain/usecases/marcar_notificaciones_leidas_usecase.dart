import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/notificaciones.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

class MarcarNotificacionesLeidasUseCase {
  final NotificacionesRepository notificacionesRepository;
  final UsuarioRepository usuarioRepository;

  MarcarNotificacionesLeidasUseCase({required this.notificacionesRepository, required this.usuarioRepository});

  Future<void> execute(List<String> uuidList) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw AuthNotAuthenticatedException('No se pudo obtener el usuario actual');
    }
    return notificacionesRepository.marcarNotificacionesComoLeidas(uuidList, usuario.nroAfiliado);
  }
}
