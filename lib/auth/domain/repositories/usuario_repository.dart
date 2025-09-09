import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';

abstract interface class UsuarioRepository {
  Future<UsuarioEntity?> autenticar(String usuario, String password);
  Future<bool> estaAutenticado();
  Future<void> cerrarSesion();
  Future<UsuarioEntity?> obtenerUsuarioActual();
  Future<RecuperarResponseModel> recuperarPassword(String tipoDocumento, String nroDocumento, String email);
  Future<CambiarPasswordResponseModel> cambiarPassword(String passwordActual, String passwordNueva);
}
