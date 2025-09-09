import 'dart:convert';

import 'package:cssayp_movil/auth/data/models/auth_response_models.dart';
import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:cssayp_movil/auth/data/datasources/secure_storage_data_source.dart';
import 'package:cssayp_movil/auth/data/datasources/usuario_data_source.dart';
import 'package:cssayp_movil/auth/data/datasources/preferencias_data_source.dart';
import 'package:cssayp_movil/auth/data/repositories/usuario_repository_impl.dart';

import 'usuario_repository_impl_test.mocks.dart';

@GenerateMocks([UsuarioDataSource, SecureStorageDataSource, PreferenciasDataSource])
void main() {
  provideDummy<AuthResponseModel>(
    const AuthGenericErrorResponse(statusCode: 500, errorMessage: 'Dummy error response'),
  );
  group("Funcion de autenticar usuario (autenticar)", () {
    late UsuarioRepositoryImpl usuarioRepositoryImpl;
    late MockUsuarioDataSource mockUsuarioDataSource;
    late MockSecureStorageDataSource mockSecureStorageDataSource;
    late MockPreferenciasDataSource mockPreferenciasDataSource;

    setUp(() {
      mockUsuarioDataSource = MockUsuarioDataSource();
      mockSecureStorageDataSource = MockSecureStorageDataSource();
      mockPreferenciasDataSource = MockPreferenciasDataSource();
      usuarioRepositoryImpl = UsuarioRepositoryImpl(
        usuarioDataSource: mockUsuarioDataSource,
        secureStorageDataSource: mockSecureStorageDataSource,
        preferenciasDataSource: mockPreferenciasDataSource,
      );
    });

    test("autenticar debe retornar un UsuarioEntity si los datos son correctos", () async {
      final authSuccessResponse = AuthSuccessResponse(
        statusCode: 200,
        nroAfiliado: 22334,
        apellidoNombres: "Juan Perez",
        token: "token",
        cambiarPassword: true,
      );

      when(mockUsuarioDataSource.autenticarUsuario(any, any)).thenAnswer((_) async => authSuccessResponse);
      when(mockSecureStorageDataSource.guardarToken(any)).thenAnswer((_) async => Future.value());
      when(mockPreferenciasDataSource.guardarValor(any, any)).thenAnswer((_) async => Future.value());

      final result = await usuarioRepositoryImpl.autenticar("jperez", "thepassword");
      expect(result, isA<UsuarioEntity>());
      expect(result?.nroAfiliado, equals(22334));
      expect(result?.apellidoNombres, equals("Juan Perez"));
      expect(result?.cambiarPassword, equals(true));
      expect(result?.username, equals("jperez"));
      expect(result?.datosUsuario, isNull);

      verify(mockUsuarioDataSource.autenticarUsuario("jperez", "thepassword")).called(1);
      verify(mockSecureStorageDataSource.guardarToken("token")).called(1);
      verify(mockPreferenciasDataSource.guardarValor("usuario", json.encode(result))).called(1);
    });

    test("autenticar debe retornar un AuthInvalidCredentialsException si los datos son incorrectos", () async {
      when(mockUsuarioDataSource.autenticarUsuario(any, any)).thenAnswer(
        (_) async => AuthInvalidCredentialsResponse(
          statusCode: 401,
          nroAfiliado: 0,
          errorMessage: "Error al autenticar usuario",
        ),
      );

      try {
        await usuarioRepositoryImpl.autenticar("jperez", "thepassword");
      } catch (e) {
        expect(e, isA<AuthInvalidCredentialsException>());
        expect((e as AuthInvalidCredentialsException).message, equals("Error al autenticar usuario"));
        expect((e).code, equals("ERR_INVALID_CREDENTIALS"));
      }
    });

    test("autenticar debe retornar un AuthGenericLoginException si ocurre un error inesperado", () async {
      when(mockUsuarioDataSource.autenticarUsuario(any, any)).thenAnswer(
        (_) async => AuthGenericErrorResponse(statusCode: 500, errorMessage: "Error inesperado al autenticar usuario"),
      );

      try {
        await usuarioRepositoryImpl.autenticar("jperez", "thepassword");
      } catch (e) {
        expect(e, isA<AuthGenericLoginException>());
        expect((e as AuthGenericLoginException).message, equals("Error inesperado al autenticar usuario"));
        expect((e).code, equals("ERR_UNEXPECTED_LOGIN"));
      }
    });

    test("autenticar debe retornar un AuthLocalStorageException si ocurre un error al guardar el token", () async {
      final authSuccessResponse = AuthSuccessResponse(
        statusCode: 200,
        nroAfiliado: 22334,
        apellidoNombres: "Juan Perez",
        token: "token",
        cambiarPassword: true,
      );

      when(mockUsuarioDataSource.autenticarUsuario(any, any)).thenAnswer((_) async => authSuccessResponse);

      when(
        mockSecureStorageDataSource.guardarToken(any),
      ).thenThrow(AuthLocalStorageException("Error al guardar el token", "ERR_STORAGE_ACCESS"));

      try {
        await usuarioRepositoryImpl.autenticar("jperez", "thepassword");
      } catch (e) {
        expect(e, isA<AuthLocalStorageException>());
        expect((e as AuthLocalStorageException).message, equals("Error al guardar el token"));
        expect((e).code, equals("ERR_STORAGE_ACCESS"));
      }
    });

    test("autenticar debe retornar un AuthPreferencesException si ocurre un error al guardar el usuario", () async {
      final authSuccessResponse = AuthSuccessResponse(
        statusCode: 200,
        nroAfiliado: 22334,
        apellidoNombres: "Juan Perez",
        token: "token",
        cambiarPassword: true,
      );

      when(mockUsuarioDataSource.autenticarUsuario(any, any)).thenAnswer((_) async => authSuccessResponse);
      when(mockSecureStorageDataSource.guardarToken(any)).thenAnswer((_) async => Future.value());
      when(
        mockPreferenciasDataSource.guardarValor(any, any),
      ).thenThrow(AuthPreferencesWriteException("No se otorgaron permisos para acceder a las preferencias"));

      try {
        await usuarioRepositoryImpl.autenticar("jperez", "thepassword");
      } catch (e) {
        expect(e, isA<AuthPreferencesWriteException>());
        expect(
          (e as AuthPreferencesWriteException).message,
          equals("Error al escribir en las preferencias: No se otorgaron permisos para acceder a las preferencias"),
        );
        expect((e).code, equals("ERR_PREFERENCES_WRITE"));
      }
    });
  });

  group("Funcion de verificar estado de autenticacion (estaAutenticado)", () {
    late UsuarioRepositoryImpl usuarioRepositoryImpl;
    late MockUsuarioDataSource mockUsuarioDataSource;
    late MockSecureStorageDataSource mockSecureStorageDataSource;
    late MockPreferenciasDataSource mockPreferenciasDataSource;

    setUp(() {
      mockUsuarioDataSource = MockUsuarioDataSource();
      mockSecureStorageDataSource = MockSecureStorageDataSource();
      mockPreferenciasDataSource = MockPreferenciasDataSource();
      usuarioRepositoryImpl = UsuarioRepositoryImpl(
        usuarioDataSource: mockUsuarioDataSource,
        secureStorageDataSource: mockSecureStorageDataSource,
        preferenciasDataSource: mockPreferenciasDataSource,
      );
    });

    test("estaAutenticado debe retornar true si el usuario está autenticado", () async {
      when(mockSecureStorageDataSource.obtenerToken()).thenAnswer(
        (_) async =>
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYWYiOiI0NjU2IiwiZGlnIjoiNSIsImNpciI6IjEiLCJzZXgiOiJNIiwidmFsIjowfQ.on3sxgCv8pBqEbf5MEbesNVtnQHXgoKsDe2m8BKaynM",
      );
      final result = await usuarioRepositoryImpl.estaAutenticado();
      expect(result, equals(true));
    });

    test(
      "estaAutenticado debe retornar false si no se encuentra el token en el almacenamiento seguro (es null)",
      () async {
        when(mockSecureStorageDataSource.obtenerToken()).thenAnswer((_) async => null);
        final result = await usuarioRepositoryImpl.estaAutenticado();
        expect(result, equals(false));
      },
    );

    test("estaAutenticado debe retornar false si el token es un string vacio", () async {
      when(mockSecureStorageDataSource.obtenerToken()).thenAnswer((_) async => "");
      final result = await usuarioRepositoryImpl.estaAutenticado();
      expect(result, equals(false));
    });

    test(
      "estaAutenticado debe retornar false si no se puede acceder al almacenamiento seguro en este dispositivo (AuthStorageUnavailableException)",
      () async {
        when(mockSecureStorageDataSource.obtenerToken()).thenThrow(AuthStorageUnavailableException());
        final result = await usuarioRepositoryImpl.estaAutenticado();
        expect(result, equals(false));
      },
    );

    test(
      "estaAutenticado debe retornar un false si ocurre un error al acceder al almacenamiento seguro (AuthStorageAccessException)",
      () async {
        when(
          mockSecureStorageDataSource.obtenerToken(),
        ).thenThrow(AuthStorageAccessException("Error al acceder al almacenamiento seguro"));
        final result = await usuarioRepositoryImpl.estaAutenticado();
        expect(result, equals(false));
      },
    );
  });
}
