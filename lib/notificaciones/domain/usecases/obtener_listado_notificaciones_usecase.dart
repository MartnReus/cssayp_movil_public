import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/domain/entities/notificacion_entity.dart';
import 'package:cssayp_movil/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';

class ObtenerListadoNotificacionesUseCase {
  final NotificacionesRepository notificacionesRepository;
  final UsuarioRepository usuarioRepository;

  ObtenerListadoNotificacionesUseCase({required this.notificacionesRepository, required this.usuarioRepository});

  Future<PaginatedResponse<NotificacionEntity>> execute() async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw AuthNotAuthenticatedException('No se pudo obtener el usuario actual');
    }
    return notificacionesRepository.obtenerNotificaciones(usuario.nroAfiliado);
  }
}
