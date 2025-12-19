import 'package:cssayp_movil/notificaciones/data/datasources/notificaciones_data_source.dart';
import 'package:cssayp_movil/notificaciones/data/models/notificacion_model.dart';
import 'package:cssayp_movil/notificaciones/data/repositories/notificaciones_repository_impl.dart';
import 'package:cssayp_movil/notificaciones/domain/entities/notificacion_entity.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:cssayp_movil/shared/models/pagination_links.dart';
import 'package:cssayp_movil/shared/models/pagination_meta.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notificaciones_repository_impl_test.mocks.dart';

@GenerateMocks([NotificacionesDataSource, JwtTokenService])
void main() {
  late NotificacionesRepositoryImpl repository;
  late MockNotificacionesDataSource mockDataSource;
  late MockJwtTokenService mockJwtTokenService;

  setUp(() {
    mockDataSource = MockNotificacionesDataSource();
    mockJwtTokenService = MockJwtTokenService();
    repository = NotificacionesRepositoryImpl(mockDataSource, mockJwtTokenService);
  });

  group('obtenerNotificaciones', () {
    const tNroAfiliado = 1;
    const tAuthToken = 'test_token';
    final tNotificacionModelList = [
      NotificacionModel(uuid: '1', type: 'type', title: 'Title', body: 'Body', sentAt: DateTime.now(), readAt: null),
    ];
    final tPaginatedResponse = PaginatedResponse<NotificacionModel>(
      data: tNotificacionModelList,
      links: PaginationLinks(first: '', last: '', prev: '', next: ''),
      meta: PaginationMeta(currentPage: 1, from: 1, lastPage: 1, path: '', perPage: 15, to: 1, total: 1),
    );

    test('debe retornar PaginatedResponse<NotificacionEntity> cuando la llamada al datasource es exitosa', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => tAuthToken);
      when(mockDataSource.obtenerNotificaciones(any, any)).thenAnswer((_) async => tPaginatedResponse);

      // act
      final result = await repository.obtenerNotificaciones(tNroAfiliado);

      // assert
      expect(result, isA<PaginatedResponse<NotificacionEntity>>());
      verify(mockJwtTokenService.obtenerToken());
      verify(mockDataSource.obtenerNotificaciones(tNroAfiliado, tAuthToken));
    });

    test('debe lanzar una excepción si el token es nulo', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => null);

      // act
      final call = repository.obtenerNotificaciones;

      // assert
      expect(() => call(tNroAfiliado), throwsException);
      verify(mockJwtTokenService.obtenerToken());
      verifyZeroInteractions(mockDataSource);
    });

    test('debe propagar la excepción si el datasource lanza una excepción', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => tAuthToken);
      when(mockDataSource.obtenerNotificaciones(any, any)).thenThrow(Exception('Datasource Error'));

      // act
      try {
        await repository.obtenerNotificaciones(tNroAfiliado);
        fail('Should have thrown an exception');
      } catch (e) {
        // assert
        expect(e, isA<Exception>());
      }

      verify(mockJwtTokenService.obtenerToken());
      verify(mockDataSource.obtenerNotificaciones(any, any));
    });
  });

  group('marcarNotificacionesComoLeidas', () {
    const tUuidList = ['uuid1', 'uuid2'];
    const tNroAfiliado = 1;
    const tAuthToken = 'test_token';

    test('debe llamar al datasource con los parámetros correctos', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => tAuthToken);
      when(mockDataSource.marcarNotificacionesComoLeidas(any, any, any)).thenAnswer((_) async => Future.value());

      // act
      await repository.marcarNotificacionesComoLeidas(tUuidList, tNroAfiliado);

      // assert
      verify(mockJwtTokenService.obtenerToken());
      verify(mockDataSource.marcarNotificacionesComoLeidas(tUuidList, tNroAfiliado, tAuthToken));
    });

    test('debe lanzar una excepción si el token es nulo', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => null);

      // act
      final call = repository.marcarNotificacionesComoLeidas;

      // assert
      expect(() => call(tUuidList, tNroAfiliado), throwsException);
      verify(mockJwtTokenService.obtenerToken());
      verifyZeroInteractions(mockDataSource);
    });
  });

  group('registrarDispositivo', () {
    const tFcmToken = 'fcmToken';
    const tNroAfiliado = 1;
    const tNombreDispositivo = 'device';
    const tPlataforma = 'android';
    const tAuthToken = 'test_token';

    test('debe llamar al datasource con los parámetros correctos', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => tAuthToken);
      when(mockDataSource.registrarDispositivo(any, any, any, any, any)).thenAnswer((_) async => Future.value());

      // act
      await repository.registrarDispositivo(tFcmToken, tNroAfiliado, tNombreDispositivo, tPlataforma);

      // assert
      verify(mockJwtTokenService.obtenerToken());
      verify(mockDataSource.registrarDispositivo(tFcmToken, tNroAfiliado, tNombreDispositivo, tPlataforma, tAuthToken));
    });

    test('debe lanzar una excepción si el token es nulo', () async {
      // arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => null);

      // act
      final call = repository.registrarDispositivo;

      // assert
      expect(() => call(tFcmToken, tNroAfiliado, tNombreDispositivo, tPlataforma), throwsException);
      verify(mockJwtTokenService.obtenerToken());
      verifyZeroInteractions(mockDataSource);
    });
  });
}
