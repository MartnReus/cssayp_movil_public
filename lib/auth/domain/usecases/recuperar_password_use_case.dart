import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

/* Funcionalidad de recuperar contraseña
Requiere del usuario su nroAfiliado, nroDocumento y email
Comprobado los datos, se envia una contraseña temporal la cual debe colocarse junto a la nueva contraseña
*/

class RecuperarPasswordUseCase {
  final UsuarioRepository usuarioRepository;

  RecuperarPasswordUseCase({required this.usuarioRepository});

  Future<void> execute(String dniOrNroAfiliado, String email) async {
    final tipoDocumento = dniOrNroAfiliado.length > 5 ? 'dni' : 'naf';
    final response = await usuarioRepository.recuperarPassword(tipoDocumento, dniOrNroAfiliado, email);

    if (response.success == false) {
      if (response.statusCode == 400) {
        final invalidCredentialsResponse = response as RecuperarInvalidCredentialsResponse;
        final mensajeError = invalidCredentialsResponse.errorMessage;
        final emailHint = invalidCredentialsResponse.emailHint;
        throw AuthException('$mensajeError\nEmail registrado: $emailHint', 'ERR_INVALID_CREDENTIALS');
      }
      throw AuthException((response as RecuperarGenericErrorResponse).errorMessage, 'ERR_UNEXPECTED_PASS_RECOVERY');
    }
  }
}
