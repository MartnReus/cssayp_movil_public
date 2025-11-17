import 'dart:convert';

import 'package:cssayp_movil/auth/data/datasources/preferencias_data_source.dart';
import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:cssayp_movil/auth/data/models/datos_usuario_response_models.dart';
import 'package:cssayp_movil/auth/domain/entities/datos_usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/data/datasources/usuario_data_source.dart';
import 'package:cssayp_movil/auth/data/datasources/secure_storage_data_source.dart';
import 'package:cssayp_movil/auth/data/models/auth_response_models.dart';
import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioDataSource usuarioDataSource;
  final SecureStorageDataSource secureStorageDataSource;
  final PreferenciasDataSource preferenciasDataSource;

  UsuarioRepositoryImpl({
    required this.usuarioDataSource,
    required this.secureStorageDataSource,
    required this.preferenciasDataSource,
  });

  @override
  Future<UsuarioEntity?> autenticar(String username, String password) async {
    final AuthResponseModel responseModel = await usuarioDataSource.autenticarUsuario(username, password);

    switch (responseModel) {
      case AuthSuccessResponse success:
        await secureStorageDataSource.guardarToken(success.token);

        final usuarioJson = success.toJson();
        usuarioJson['username'] = username;
        final usuario = UsuarioEntity.fromJson(usuarioJson);
        await preferenciasDataSource.guardarValor('usuario', json.encode(usuario));
        return usuario;

      case AuthInvalidCredentialsResponse invalidCredentials:
        throw AuthInvalidCredentialsException(invalidCredentials.errorMessage);

      case AuthGenericErrorResponse genericError:
        throw AuthGenericLoginException(genericError.errorMessage);
    }
  }

  @override
  Future<bool> estaAutenticado() async {
    try {
      final token = await secureStorageDataSource.obtenerToken();
      return token != null && token.isNotEmpty && _formatoTokenValido(token);
    } on AuthLocalStorageException {
      // Cualquier problema con el almacenamiento local significa "no autenticado"
      return false;
    }
  }

  bool _formatoTokenValido(String token) {
    try {
      final jwtToken = JwtDecoder.decode(token);

      if (jwtToken.isEmpty) {
        return false;
      }

      final requiredFields = ['naf', 'dig', 'cir', 'sex', 'val'];
      for (final field in requiredFields) {
        if (!jwtToken.containsKey(field)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<RecuperarResponseModel> recuperarPassword(String tipoDocumento, String nroDocumento, String email) async {
    try {
      final RecuperarResponseModel responseRecModel = await usuarioDataSource.recuperarPassword(
        tipoDocumento,
        nroDocumento,
        email,
      );

      return responseRecModel;
    } catch (e) {
      throw Exception('Error al recuperar contraseña: $e');
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await secureStorageDataSource.eliminarToken();
    } on AuthLocalStorageException catch (e) {
      throw AuthException('Error al eliminar token de autenticación: ${e.message}', e.code);
    } catch (e) {
      throw AuthException('Error inesperado al cerrar sesión: $e', 'ERR_UNEXPECTED_LOGOUT');
    }
  }

  @override
  Future<UsuarioEntity?> obtenerUsuarioActual() async {
    try {
      // Verificar si el usuario está autenticado
      final token = await secureStorageDataSource.obtenerToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      // Recuperar el usuario desde SharedPreferences
      final usuarioJson = await preferenciasDataSource.obtenerValor('usuario');
      if (usuarioJson == null || usuarioJson.isEmpty) {
        return null;
      }
      final usuario = UsuarioEntity.fromJson(json.decode(usuarioJson));

      DatosUsuarioEntity? datosUsuario;
      // Recuperar los datos del usuario desde SharedPreferences
      final datosUsuarioNaf = await preferenciasDataSource.obtenerValor('datos_usuario_naf');
      final datosUsuarioJson = await preferenciasDataSource.obtenerValor('datos_usuario');

      final bool isNuevoNaf = datosUsuarioNaf == null || datosUsuarioNaf != usuario.nroAfiliado.toString();
      final bool sinDatosUsuario = datosUsuarioJson == null || datosUsuarioJson.isEmpty;

      if (isNuevoNaf || sinDatosUsuario) {
        // Si no hay datos del usuario, obtenerlos desde la API
        final datosResponse = await usuarioDataSource.obtenerDatosUsuario(token);
        if (datosResponse is DatosUsuarioSuccessResponse) {
          // Guardar los datos del usuario en SharedPreferences
          datosUsuario = DatosUsuarioEntity.fromJson(datosResponse.toJson());
          await preferenciasDataSource.guardarValor('datos_usuario', json.encode(datosUsuario));
          await preferenciasDataSource.guardarValor('datos_usuario_naf', usuario.nroAfiliado.toString());
        }
      } else {
        datosUsuario = DatosUsuarioEntity.fromJson(json.decode(datosUsuarioJson));
      }

      usuario.datosUsuario = datosUsuario;

      return usuario;
    } on AuthLocalStorageException {
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<CambiarPasswordResponseModel> cambiarPassword(String passwordActual, String passwordNueva) async {
    final token = await secureStorageDataSource.obtenerToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Token no disponible', 'ERR_TOKEN_NOT_AVAILABLE');
    }
    final CambiarPasswordResponseModel responseCambiarPassword = await usuarioDataSource.cambiarPassword(
      token,
      passwordActual,
      passwordNueva,
    );
    return responseCambiarPassword;
  }
}
