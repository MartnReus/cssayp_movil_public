import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';

class CambiarPasswordUseCase {
  final UsuarioRepository usuarioRepository;

  CambiarPasswordUseCase({required this.usuarioRepository});

  Future<CambiarPasswordResponseModel> execute(String passwordActual, String passwordNueva) async {
    return usuarioRepository.cambiarPassword(passwordActual, passwordNueva);
  }
}
