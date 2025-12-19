import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';
import 'package:http/http.dart' as http;

// TODO: Implementar este cliente en app_providers
class AppHttpClient {
  final http.Client _innerClient;
  final JwtTokenService _tokenService;

  AppHttpClient(this._innerClient, this._tokenService);

  Future<http.Response> get(String url, {Map<String, String>? headers, bool requiresAuth = false}) async {
    return _sendRequest('GET', url, headers: headers, requiresAuth: requiresAuth);
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    return _sendRequest('POST', url, body: body, headers: headers, requiresAuth: requiresAuth);
  }

  Future<http.Response> put(String url, {Object? body, Map<String, String>? headers, bool requiresAuth = false}) async {
    return _sendRequest('PUT', url, body: body, headers: headers, requiresAuth: requiresAuth);
  }

  Future<http.Response> _sendRequest(
    String method,
    String url, {
    Object? body,
    Map<String, String>? headers,
    required bool requiresAuth,
  }) async {
    final finalHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json', ...?headers};

    if (requiresAuth) {
      final token = await _tokenService.obtenerToken();

      if (token != null && token.isNotEmpty) {
        finalHeaders['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('Sesión no iniciada (Token no encontrado)');
      }
    }

    final uri = Uri.parse(url);
    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _innerClient.get(uri, headers: finalHeaders);
          break;
        case 'POST':
          response = await _innerClient.post(uri, headers: finalHeaders, body: body);
          break;
        case 'PUT':
          response = await _innerClient.put(uri, headers: finalHeaders, body: body);
          break;
        // Agregar DELETE, PATCH si es necesario
        default:
          throw UnimplementedError('Método $method no soportado');
      }

      _handleGlobalErrors(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _handleGlobalErrors(http.Response response) {
    if (response.statusCode == 401) {
      throw AuthNotAuthenticatedException('Sesión no iniciada (Token de autenticación no encontrado)');
    }
  }
}
