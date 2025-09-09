import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

class LoginUseCase {
  final UsuarioRepository usuarioRepository;

  LoginUseCase({required this.usuarioRepository});

  Future<void> execute(String username, String password) async {
    final usuario = await usuarioRepository.autenticar(username, password);

    if (usuario == null) {
      throw AuthInvalidCredentialsException('Datos incorrectos');
    }
  }
}
