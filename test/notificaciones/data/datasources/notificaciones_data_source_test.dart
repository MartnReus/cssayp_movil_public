import 'dart:convert';
import 'package:cssayp_movil/config.dart';
import 'package:cssayp_movil/notificaciones/data/datasources/notificaciones_data_source.dart';
import 'package:cssayp_movil/notificaciones/data/models/notificacion_model.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notificaciones_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NotificacionesDataSource dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NotificacionesDataSource(mockHttpClient);
  });

  group('obtenerNotificaciones', () {
    const tNroAfiliado = 1;
    const tAuthToken = 'test_token';

    test('debe retornar PaginatedResponse<NotificacionModel> cuando el código de respuesta es 200', () async {
      // arrange
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'data': [
              {
                'uuid': '1',
                'type': 'type',
                'title': 'Title',
                'body': 'Body',
                'sent_at': DateTime.now().toIso8601String(),
                'read_at': null,
              },
            ],
            'links': {},
            'meta': {},
          }),
          200,
        ),
      );

      // act
      final result = await dataSource.obtenerNotificaciones(tNroAfiliado, tAuthToken);

      // assert
      expect(result, isA<PaginatedResponse<NotificacionModel>>());
      verify(
        mockHttpClient.get(
          Uri.parse('${AppConfig.personasApiURL}/api/notificaciones/afiliado/$tNroAfiliado'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $tAuthToken',
          },
        ),
      );
    });

    test('debe lanzar una excepción cuando el código de respuesta no es 200', () async {
      // arrange
      when(
        mockHttpClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Something went wrong', 404));

      // act
      final call = dataSource.obtenerNotificaciones;

      // assert
      expect(() => call(tNroAfiliado, tAuthToken), throwsException);
    });
  });

  group('marcarNotificacionesComoLeidas', () {
    const tUuidList = ['uuid1', 'uuid2'];
    const tNroAfiliado = 1;
    const tAuthToken = 'test_token';

    test('debe completar exitosamente cuando el código de respuesta es 200', () async {
      // arrange
      when(
        mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => http.Response('Success', 200));

      // act
      await dataSource.marcarNotificacionesComoLeidas(tUuidList, tNroAfiliado, tAuthToken);

      // assert
      verify(
        mockHttpClient.post(
          Uri.parse('${AppConfig.personasApiURL}/api/notificaciones/marcar-leido'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $tAuthToken',
          },
          body: jsonEncode({'uuidList': tUuidList, 'nroAfiliado': tNroAfiliado}),
        ),
      );
    });

    test('debe lanzar una excepción cuando el código de respuesta no es 200', () async {
      // arrange
      when(
        mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => http.Response('Something went wrong', 500));

      // act
      final call = dataSource.marcarNotificacionesComoLeidas;

      // assert
      expect(() => call(tUuidList, tNroAfiliado, tAuthToken), throwsException);
    });
  });

  group('registrarDispositivo', () {
    const tFcmToken = 'fcmToken';
    const tNroAfiliado = 1;
    const tNombreDispositivo = 'device';
    const tPlataforma = 'android';
    const tAuthToken = 'test_token';

    test('debe completar exitosamente cuando el código de respuesta es 200', () async {
      // arrange
      when(
        mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => http.Response('Success', 200));

      // act
      await dataSource.registrarDispositivo(tFcmToken, tNroAfiliado, tNombreDispositivo, tPlataforma, tAuthToken);

      // assert
      verify(
        mockHttpClient.post(
          Uri.parse('${AppConfig.personasApiURL}/api/notificaciones/afiliado/dispositivos/registrar'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $tAuthToken',
          },
          body: jsonEncode({
            'fcmToken': tFcmToken,
            'nroAfiliado': tNroAfiliado,
            'nombreDispositivo': tNombreDispositivo,
            'plataforma': tPlataforma,
          }),
        ),
      );
    });

    test('debe lanzar una excepción cuando el código de respuesta no es 200', () async {
      // arrange
      when(
        mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => http.Response('Something went wrong', 500));

      // act
      final call = dataSource.registrarDispositivo;

      // assert
      expect(() => call(tFcmToken, tNroAfiliado, tNombreDispositivo, tPlataforma, tAuthToken), throwsException);
    });
  });
}
