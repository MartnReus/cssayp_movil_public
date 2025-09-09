import 'package:cssayp_movil/auth/data/models/auth_response_models.dart';
import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:cssayp_movil/auth/data/models/datos_usuario_response_models.dart';
import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';
import 'package:cssayp_movil/auth/data/mappers/cambiar_password_response_mapper.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class UsuarioDataSource {
  final http.Client client;

  UsuarioDataSource({required this.client});

  Future<AuthResponseModel> autenticarUsuario(String usuario, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConfig.cgaUrl}/ws/usr/login'),
        body: json.encode({'usuario': usuario, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> data = json.decode(response.body);
      if (data['nro_afiliado'] == 0) {
        return AuthInvalidCredentialsResponse.fromJson(response.statusCode, data);
      }
      return AuthSuccessResponse.fromJson(response.statusCode, data);
    } on SocketException catch (_) {
      return AuthGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return AuthGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return AuthGenericErrorResponse(
        statusCode: 500,
        errorMessage: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return AuthGenericErrorResponse(statusCode: 0, errorMessage: 'Error inesperado al autenticar usuario');
    }
  }

  Future<RecuperarResponseModel> recuperarPassword(String tipoDocumento, String nroDocumento, String email) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConfig.consultaApiURL}/api/v1/resetPass'),
        body: json.encode({'tipo_documento': tipoDocumento, 'nro_documento': nroDocumento, 'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return RecuperarSuccessResponse.fromJson(response.statusCode, data);
      }

      if (response.statusCode == 400) {
        return RecuperarInvalidCredentialsResponse.fromJson(response.statusCode, data);
      }

      return RecuperarGenericErrorResponse(statusCode: 500, errorMessage: 'Error inesperado al recuperar contraseña');
    } on SocketException catch (_) {
      return RecuperarGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return RecuperarGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return RecuperarGenericErrorResponse(
        statusCode: 500,
        errorMessage: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return RecuperarGenericErrorResponse(statusCode: 0, errorMessage: 'Error inesperado al recuperar contraseña');
    }
  }

  Future<DatosUsuarioResponseModel> obtenerDatosUsuario(String token) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.cgaUrl}/ws/usr/datos-usuario'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        return DatosUsuarioSuccessResponse.fromJson(response.statusCode, data);
      }
      if (response.statusCode == 401) {
        return DatosUsuarioInvalidTokenResponse.fromJson(response.statusCode, {'mensaje': 'Token inválido'});
      }
      return DatosUsuarioGenericErrorResponse(
        statusCode: response.statusCode,
        mensaje: 'Error inesperado al obtener datos del usuario',
      );
    } on SocketException catch (_) {
      return DatosUsuarioGenericErrorResponse(statusCode: 0, mensaje: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return DatosUsuarioGenericErrorResponse(statusCode: 0, mensaje: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return DatosUsuarioGenericErrorResponse(
        statusCode: 500,
        mensaje: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return DatosUsuarioGenericErrorResponse(statusCode: 0, mensaje: 'Error inesperado al obtener datos del usuario');
    }
  }

  Future<CambiarPasswordResponseModel> cambiarPassword(
    String token,
    String passwordActual,
    String passwordNueva,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConfig.cgaUrl}/ws/opc/cambiar-password'),
        body: json.encode({
          'passwordActual': passwordActual,
          'passwordNueva': passwordNueva,
          'passwordRepetir': passwordNueva,
        }),
        headers: {'Authorization': 'Bearer $token'},
      );

      final Map<String, dynamic> data = json.decode(response.body);
      return CambiarPasswordResponseMapper.fromApiResponse(response.statusCode, data);
    } on SocketException catch (_) {
      return CambiarPasswordGenericErrorResponse(
        statusCode: 0,
        estado: false,
        mensaje: 'Error en la conexión con el servidor',
      );
    } on TimeoutException catch (_) {
      return CambiarPasswordGenericErrorResponse(
        statusCode: 0,
        estado: false,
        mensaje: 'Error en la conexión con el servidor',
      );
    } on FormatException catch (_) {
      return CambiarPasswordGenericErrorResponse(
        statusCode: 500,
        estado: false,
        mensaje: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return CambiarPasswordGenericErrorResponse(
        statusCode: 0,
        estado: false,
        mensaje: 'Error inesperado al cambiar contraseña',
      );
    }
  }
}
