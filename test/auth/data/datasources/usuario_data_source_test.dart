import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/auth/data/datasources/usuario_data_source.dart';
import 'package:cssayp_movil/auth/data/models/auth_response_models.dart';
import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';
import 'package:cssayp_movil/auth/data/models/datos_usuario_response_models.dart';
import 'package:cssayp_movil/auth/data/models/recuperar_password_response_models.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'usuario_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group("Funcion de inicio de sesion (autenticarUsuario)", () {
    late UsuarioDataSource usuarioDataSource;
    late MockClient mockClient;

    final cgaUrl = "${AppConfig.cgaUrl}/ws/usr/login";
    final requestHeaders = {'Content-Type': 'application/json'};

    setUp(() {
      mockClient = MockClient();
      usuarioDataSource = UsuarioDataSource(client: mockClient);
    });

    test("autenticarUsuario debe retornar un AuthSuccessResponse si el usuario y contraseña son correctos", () async {
      final requestBody = json.encode({'usuario': 'username', 'password': 'validPassword'});

      // Respuesta que devuelve el endpoint
      final successResponseBody = json.encode({
        'nro_afiliado': 999,
        'apellido_nombres': 'Perez, Juan',
        'token': '1234567890',
        'cambiar_password': 0,
      });
      const successResponseStatus = 200;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await usuarioDataSource.autenticarUsuario('username', 'validPassword');
      expect(result, isA<AuthSuccessResponse>());
      expect((result as AuthSuccessResponse).nroAfiliado, equals(999));
      expect((result).apellidoNombres, equals('Perez, Juan'));
      expect((result).token, equals('1234567890'));
      expect((result).cambiarPassword, equals(false));

      verify(mockClient.post(Uri.parse(cgaUrl), body: requestBody, headers: requestHeaders)).called(1);
    });

    test("autenticarUsuario debe retornar un AuthInvalidCredentialsResponse si la contraseña es incorrecta", () async {
      final requestBody = json.encode({'usuario': 'username', 'password': 'invalidPassword'});

      // Respuesta que devuelve el endpoint
      final invalidCredentialsResponseBody = json.encode({'nro_afiliado': 0, 'mensaje': 'Datos incorrectos'});
      const invalidCredentialsResponseStatus = 200;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(invalidCredentialsResponseBody, invalidCredentialsResponseStatus));

      final result = await usuarioDataSource.autenticarUsuario('username', 'invalidPassword');
      expect(result, isA<AuthInvalidCredentialsResponse>());
      expect((result as AuthInvalidCredentialsResponse).nroAfiliado, equals(0));
      expect((result).errorMessage, equals('Datos incorrectos'));

      verify(mockClient.post(Uri.parse(cgaUrl), body: requestBody, headers: requestHeaders)).called(1);
    });

    test(
      "autenticarUsuario debe retornar un AuthGenericErrorResponse si el endpoint está caído o hay timeout",
      () async {
        final requestBodyTimeoutException = json.encode({'usuario': 'usernameTimeout', 'password': 'password'});
        final requestBodySocketException = json.encode({'usuario': 'usernameSocket', 'password': 'password'});

        // Simular que el endpoint está caído o hay timeout
        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(TimeoutException('Connection timeout'));

        when(
          mockClient.post(any, body: requestBodySocketException, headers: anyNamed('headers')),
        ).thenThrow(SocketException('Connection timeout'));

        final resultTimeoutException = await usuarioDataSource.autenticarUsuario('usernameTimeout', 'password');
        final resultSocketException = await usuarioDataSource.autenticarUsuario('usernameSocket', 'password');

        expect(resultSocketException, isA<AuthGenericErrorResponse>());

        expect(resultTimeoutException, isA<AuthGenericErrorResponse>());

        expect(
          (resultTimeoutException as AuthGenericErrorResponse).errorMessage,
          equals('Error en la conexión con el servidor'),
        );
        expect(
          (resultSocketException as AuthGenericErrorResponse).errorMessage,
          equals('Error en la conexión con el servidor'),
        );

        verify(
          mockClient.post(Uri.parse(cgaUrl), body: requestBodyTimeoutException, headers: requestHeaders),
        ).called(1);
        verify(mockClient.post(Uri.parse(cgaUrl), body: requestBodySocketException, headers: requestHeaders)).called(1);
      },
    );

    test("autenticarUsuario debe retornar un AuthGenericErrorResponse si el endpoint devuelve error 500", () async {
      final requestBody = json.encode({'usuario': 'username', 'password': 'password'});
      const errorResponseStatus = 500;
      const errorResponseBody = '''
        <!DOCTYPE html>
        <html>
        <head><title>500 Internal Server Error</title></head>
        <body>
        <h1>Internal Server Error</h1>
        <p>The server encountered an internal error and was unable to complete your request.</p>
        </body>
        </html>
        ''';

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(errorResponseBody, errorResponseStatus, headers: {'Content-Type': 'text/html'}),
      );

      final result = await usuarioDataSource.autenticarUsuario('username', 'password');
      expect(result, isA<AuthGenericErrorResponse>());
      expect((result as AuthGenericErrorResponse).statusCode, equals(errorResponseStatus));
      expect((result).errorMessage, equals('Error del servidor, intente nuevamente más tarde'));

      verify(mockClient.post(Uri.parse(cgaUrl), body: requestBody, headers: requestHeaders)).called(1);
    });
  });

  group("Funcion de recuperacion de contraseña (recuperarPassword)", () {
    late UsuarioDataSource usuarioDataSource;
    late MockClient mockClient;

    final consultaApiURL = "${AppConfig.consultaApiURL}/api/v1/resetPass";
    final requestHeaders = {'Content-Type': 'application/json'};

    setUp(() {
      mockClient = MockClient();
      usuarioDataSource = UsuarioDataSource(client: mockClient);
    });
    test("recuperarPassword debe retornar un RecuperarSuccessResponse si los datos enviados son correctos", () async {
      final requestBody = json.encode({
        'tipo_documento': 'dni',
        'nro_documento': '1234567890',
        'email': 'test@test.com',
      });
      final successResponseBody = json.encode({'success': true});
      const successResponseStatus = 200;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await usuarioDataSource.recuperarPassword('dni', '1234567890', 'test@test.com');

      expect(result, isA<RecuperarSuccessResponse>());
      expect((result as RecuperarSuccessResponse).success, equals(true));
      expect((result).statusCode, equals(successResponseStatus));

      verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
    });

    test(
      "recuperarPassword debe retornar un RecuperarInvalidCredentialsResponse si los datos enviados son incorrectos",
      () async {
        final requestBody = json.encode({
          'tipo_documento': 'dni',
          'nro_documento': '1234567890',
          'email': 'test@test.com',
        });
        final invalidCredentialsResponseBody = json.encode({
          'success': false,
          'error': 'El número de documento no coincide con el que se encuentra en el sistema',
          'email_hint': 't**@t**t.com',
        });
        const invalidCredentialsResponseStatus = 400;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(invalidCredentialsResponseBody, invalidCredentialsResponseStatus));

        final result = await usuarioDataSource.recuperarPassword('dni', '1234567890', 'test@test.com');
        expect(result, isA<RecuperarInvalidCredentialsResponse>());
        expect((result as RecuperarInvalidCredentialsResponse).success, equals(false));
        expect(
          (result).errorMessage,
          equals('El número de documento no coincide con el que se encuentra en el sistema'),
        );
        expect((result).statusCode, equals(invalidCredentialsResponseStatus));

        verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
      },
    );

    test("recuperarPassword debe retornar un RecuperarGenericErrorResponse cuando hay timeout de conexión", () async {
      final requestBodyTimeoutException = json.encode({
        'tipo_documento': 'dni',
        'nro_documento': '1234567890',
        'email': 'timeout@test.com',
      });
      final requestBodySocketException = json.encode({
        'tipo_documento': 'dni',
        'nro_documento': '1234567890',
        'email': 'socket@test.com',
      });

      when(
        mockClient.post(Uri.parse(consultaApiURL), body: requestBodyTimeoutException, headers: requestHeaders),
      ).thenThrow(TimeoutException('Connection timeout'));
      when(
        mockClient.post(Uri.parse(consultaApiURL), body: requestBodySocketException, headers: requestHeaders),
      ).thenThrow(SocketException('Connection timeout'));

      final resultTimeoutException = await usuarioDataSource.recuperarPassword('dni', '1234567890', 'timeout@test.com');
      final resultSocketException = await usuarioDataSource.recuperarPassword('dni', '1234567890', 'socket@test.com');

      expect(resultTimeoutException, isA<RecuperarGenericErrorResponse>());
      expect(resultSocketException, isA<RecuperarGenericErrorResponse>());
      expect(
        (resultTimeoutException as RecuperarGenericErrorResponse).errorMessage,
        equals('Error en la conexión con el servidor'),
      );
      expect(
        (resultSocketException as RecuperarGenericErrorResponse).errorMessage,
        equals('Error en la conexión con el servidor'),
      );

      verify(
        mockClient.post(Uri.parse(consultaApiURL), body: requestBodyTimeoutException, headers: requestHeaders),
      ).called(1);
      verify(
        mockClient.post(Uri.parse(consultaApiURL), body: requestBodySocketException, headers: requestHeaders),
      ).called(1);
    });

    test(
      "recuperarPassword debe retornar un RecuperarGenericErrorResponse cuando el servidor devuelve HTML (FormatException)",
      () async {
        final requestBody = json.encode({
          'tipo_documento': 'dni',
          'nro_documento': '1234567890',
          'email': 'test@test.com',
        });
        const errorResponseStatus = 500;
        const errorResponseBody = '''
        <!DOCTYPE html>
        <html>
        <head><title>500 Internal Server Error</title></head>
        <body>
        <h1>Internal Server Error</h1>
        <p>The server encountered an internal error and was unable to complete your request.</p>
        </body>
        </html>
        ''';

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        final result = await usuarioDataSource.recuperarPassword('dni', '1234567890', 'test@test.com');
        expect(result, isA<RecuperarGenericErrorResponse>());
        expect((result as RecuperarGenericErrorResponse).statusCode, equals(500));
        expect((result).errorMessage, equals('Error del servidor, intente nuevamente más tarde'));

        verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
      },
    );
  });

  group("Funcion de cambio de contraseña (cambiarPassword)", () {
    late UsuarioDataSource usuarioDataSource;
    late MockClient mockClient;

    final cgaUrl = "${AppConfig.cgaUrl}/ws/opc/cambiar-password";
    final requestHeaders = {'Authorization': 'Bearer token'};

    setUp(() {
      mockClient = MockClient();
      usuarioDataSource = UsuarioDataSource(client: mockClient);
    });

    test(
      "cambiarPassword debe retornar un CambiarPasswordSuccessResponse si los datos enviados son correctos",
      () async {
        final requestBody = json.encode({
          'passwordActual': 'actual',
          'passwordNueva': 'nueva',
          'passwordRepetir': 'nueva',
        });
        final successResponseBody = json.encode({'estado': true});
        const successResponseStatus = 200;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        final result = await usuarioDataSource.cambiarPassword('token', 'actual', 'nueva');
        expect(result, isA<CambiarPasswordSuccessResponse>());
        expect((result as CambiarPasswordSuccessResponse).estado, equals(true));
        expect((result).statusCode, equals(successResponseStatus));

        verify(mockClient.post(Uri.parse(cgaUrl), body: requestBody, headers: requestHeaders)).called(1);
      },
    );

    test(
      "cambiarPassword debe retornar un CambiarPasswordInvalidCredentialsResponse si los datos enviados son incorrectos",
      () async {
        final requestBody = json.encode({
          'passwordActual': 'actual',
          'passwordNueva': 'nueva',
          'passwordRepetir': 'nueva',
        });
        final invalidCredentialsResponseBody = json.encode({
          'estado': 0,
          'mensaje': 'La contraseña actual es incorrecta',
        });
        const invalidCredentialsResponseStatus = 200;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(invalidCredentialsResponseBody, invalidCredentialsResponseStatus));

        final result = await usuarioDataSource.cambiarPassword('token', 'actual', 'nueva');
        expect(result, isA<CambiarPasswordInvalidCredentialsResponse>());
        expect((result as CambiarPasswordInvalidCredentialsResponse).estado, equals(false));
        expect((result).mensaje, equals('La contraseña actual es incorrecta'));
        expect((result).statusCode, equals(invalidCredentialsResponseStatus));

        verify(mockClient.post(Uri.parse(cgaUrl), body: requestBody, headers: requestHeaders)).called(1);
      },
    );

    test(
      "cambiarPassword debe retornar un CambiarPasswordGenericErrorResponse cuando hay timeout de conexión",
      () async {
        final requestBodyTimeoutException = json.encode({
          'passwordActual': 'actualTimeout',
          'passwordNueva': 'nuevaTimeout',
          'passwordRepetir': 'nuevaTimeout',
        });
        final requestBodySocketException = json.encode({
          'passwordActual': 'actualSocket',
          'passwordNueva': 'nuevaSocket',
          'passwordRepetir': 'nuevaSocket',
        });

        when(
          mockClient.post(Uri.parse(cgaUrl), body: requestBodyTimeoutException, headers: requestHeaders),
        ).thenThrow(TimeoutException('Connection timeout'));
        when(
          mockClient.post(Uri.parse(cgaUrl), body: requestBodySocketException, headers: requestHeaders),
        ).thenThrow(SocketException('Connection timeout'));

        final resultTimeoutException = await usuarioDataSource.cambiarPassword(
          'token',
          'actualTimeout',
          'nuevaTimeout',
        );
        final resultSocketException = await usuarioDataSource.cambiarPassword('token', 'actualSocket', 'nuevaSocket');

        // Verificar que los resultados sean del tipo CambiarPasswordGenericErrorResponse
        expect(resultTimeoutException, isA<CambiarPasswordGenericErrorResponse>());
        expect(resultSocketException, isA<CambiarPasswordGenericErrorResponse>());

        // Verificar que el mensaje sea correcto
        expect((resultTimeoutException).mensaje, equals('Error en la conexión con el servidor'));
        expect((resultSocketException).mensaje, equals('Error en la conexión con el servidor'));

        // Verificar que el estado sea false
        expect((resultTimeoutException).estado, equals(false));
        expect((resultSocketException).estado, equals(false));

        // Verificar que el statusCode sea 0
        expect((resultTimeoutException).statusCode, equals(0));
        expect((resultSocketException).statusCode, equals(0));

        verify(
          mockClient.post(Uri.parse(cgaUrl), body: requestBodyTimeoutException, headers: requestHeaders),
        ).called(1);
        verify(mockClient.post(Uri.parse(cgaUrl), body: requestBodySocketException, headers: requestHeaders)).called(1);
      },
    );
  });

  group("Funcion de obtener datos del usuario (obtenerDatosUsuario)", () {
    late UsuarioDataSource usuarioDataSource;
    late MockClient mockClient;

    final cgaUrl = "${AppConfig.cgaUrl}/ws/usr/datos-usuario";
    final requestHeaders = {'Authorization': 'Bearer token'};

    setUp(() {
      mockClient = MockClient();
      usuarioDataSource = UsuarioDataSource(client: mockClient);
    });

    test(
      "obtenerDatosUsuario debe retornar un DatosUsuarioSuccessResponse si los datos enviados son correctos",
      () async {
        final successResponseBody = json.encode({
          'APELLIDO': 'Apellido',
          'NOMBRES': 'Nombres',
          'APELLIDO_NOMBRES': 'Apellido, Nombres',
          'TITULO': 'Dr.',
          'NRO_AFILIADO_DIGITO': '12345-1',
          'CIRCUNSCRIPCION': '1',
          'EMAIL': 'test@test.com',
          'CAMBIAR_PASSWORD': '1',
          'DEBE_ACTUALIZAR_DATOS': '0',
          'DEBE_VALIDAR': '0',
        });
        const successResponseStatus = 200;

        when(
          mockClient.get(Uri.parse(cgaUrl), headers: requestHeaders),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        final result = await usuarioDataSource.obtenerDatosUsuario('token');
        expect(result, isA<DatosUsuarioSuccessResponse>());
        expect((result as DatosUsuarioSuccessResponse).statusCode, equals(successResponseStatus));
        expect((result).apellido, equals('Apellido'));
        expect((result).nombres, equals('Nombres'));
        expect((result).apellidoNombres, equals('Apellido, Nombres'));
        expect((result).titulo, equals('Dr.'));
        expect((result).nroAfiliadoDigito, equals('12345-1'));
        expect((result).circunscripcion, equals('1'));
        expect((result).email, equals('test@test.com'));
        expect((result).cambiarPassword, equals(true));
        expect((result).debeActualizarDatos, equals(false));
        expect((result).debeValidar, equals(false));

        verify(mockClient.get(Uri.parse(cgaUrl), headers: requestHeaders)).called(1);
      },
    );

    test("obtenerDatosUsuario debe retornar un DatosUsuarioInvalidTokenResponse si el token es inválido", () async {
      final invalidTokenResponseBody = json.encode({'usuario_logueado': 0});
      const invalidTokenResponseStatus = 401;

      when(
        mockClient.get(Uri.parse(cgaUrl), headers: requestHeaders),
      ).thenAnswer((_) async => http.Response(invalidTokenResponseBody, invalidTokenResponseStatus));

      final result = await usuarioDataSource.obtenerDatosUsuario('token');
      expect(result, isA<DatosUsuarioInvalidTokenResponse>());
      expect((result as DatosUsuarioInvalidTokenResponse).statusCode, equals(invalidTokenResponseStatus));
      expect((result).mensaje, equals('Token inválido'));

      verify(mockClient.get(Uri.parse(cgaUrl), headers: requestHeaders)).called(1);
    });

    test(
      "obtenerDatosUsuario debe retornar un DatosUsuarioGenericErrorResponse cuando hay timeout de conexión",
      () async {
        final requestHeadersTimeoutException = {'Authorization': 'Bearer timeout_token'};
        final requestHeadersSocketException = {'Authorization': 'Bearer socket_token'};

        when(
          mockClient.get(Uri.parse(cgaUrl), headers: requestHeadersTimeoutException),
        ).thenThrow(TimeoutException('Connection timeout'));
        when(
          mockClient.get(Uri.parse(cgaUrl), headers: requestHeadersSocketException),
        ).thenThrow(SocketException('Connection timeout'));

        final resultTimeoutException = await usuarioDataSource.obtenerDatosUsuario('timeout_token');
        final resultSocketException = await usuarioDataSource.obtenerDatosUsuario('socket_token');

        expect(resultTimeoutException, isA<DatosUsuarioGenericErrorResponse>());
        expect(resultSocketException, isA<DatosUsuarioGenericErrorResponse>());

        expect(
          (resultTimeoutException as DatosUsuarioGenericErrorResponse).mensaje,
          equals('Error en la conexión con el servidor'),
        );
        expect(
          (resultSocketException as DatosUsuarioGenericErrorResponse).mensaje,
          equals('Error en la conexión con el servidor'),
        );

        expect((resultTimeoutException).statusCode, equals(0));
        expect((resultSocketException).statusCode, equals(0));

        verify(mockClient.get(Uri.parse(cgaUrl), headers: requestHeadersTimeoutException)).called(1);
        verify(mockClient.get(Uri.parse(cgaUrl), headers: requestHeadersSocketException)).called(1);
      },
    );

    test(
      "obtenerDatosUsuario debe retornar un DatosUsuarioGenericErrorResponse cuando el servidor devuelve HTML (FormatException)",
      () async {
        const errorResponseStatus = 500;
        const errorResponseBody = '''
        <!DOCTYPE html>
        <html>
        <head><title>500 Internal Server Error</title></head>
        <body>
        <h1>Internal Server Error</h1>
        <p>The server encountered an internal error and was unable to complete your request.</p>
        </body>
        </html>
        ''';

        when(
          mockClient.get(Uri.parse(cgaUrl), headers: requestHeaders),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        final result = await usuarioDataSource.obtenerDatosUsuario('token');
        expect(result, isA<DatosUsuarioGenericErrorResponse>());
        expect((result as DatosUsuarioGenericErrorResponse).statusCode, equals(500));
        expect((result).mensaje, equals('Error del servidor, intente nuevamente más tarde'));

        verify(mockClient.get(Uri.parse(cgaUrl), headers: requestHeaders)).called(1);
      },
    );
  });
}
