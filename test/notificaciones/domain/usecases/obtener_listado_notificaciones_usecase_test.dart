import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/domain/entities/notificacion_entity.dart';
import 'package:cssayp_movil/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:cssayp_movil/notificaciones/domain/usecases/obtener_listado_notificaciones_usecase.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:cssayp_movil/shared/models/pagination_links.dart';
import 'package:cssayp_movil/shared/models/pagination_meta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'obtener_listado_notificaciones_usecase_test.mocks.dart';

@GenerateMocks([NotificacionesRepository, UsuarioRepository])
void main() {
  late ObtenerListadoNotificacionesUseCase useCase;
  late MockNotificacionesRepository mockNotificacionesRepository;
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockNotificacionesRepository = MockNotificacionesRepository();
    mockUsuarioRepository = MockUsuarioRepository();
    useCase = ObtenerListadoNotificacionesUseCase(
      notificacionesRepository: mockNotificacionesRepository,
      usuarioRepository: mockUsuarioRepository,
    );
  });

  group('ObtenerListadoNotificacionesUseCase', () {
    final tUsuario = UsuarioEntity(
      nroAfiliado: 123,
      apellidoNombres: 'Test User',
      cambiarPassword: false,
      username: 'testuser',
    );
    final tPaginatedResponse = PaginatedResponse<NotificacionEntity>(
      data: [],
      links: PaginationLinks(first: '', last: '', prev: '', next: ''),
      meta: PaginationMeta(currentPage: 1, from: 1, lastPage: 1, path: '', perPage: 15, to: 1, total: 0),
    );

    test('debe lanzar AuthNotAuthenticatedException si el usuario es nulo', () async {
      // arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // act
      final call = useCase.execute;

      // assert
      expect(() => call(), throwsA(isA<AuthNotAuthenticatedException>()));
      verify(mockUsuarioRepository.obtenerUsuarioActual());
      verifyZeroInteractions(mockNotificacionesRepository);
    });

    test('debe retornar PaginatedResponse si el usuario existe', () async {
      // arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => tUsuario);
      when(mockNotificacionesRepository.obtenerNotificaciones(any)).thenAnswer((_) async => tPaginatedResponse);

      // act
      final result = await useCase.execute();

      // assert
      expect(result, tPaginatedResponse);
      verify(mockUsuarioRepository.obtenerUsuarioActual());
      verify(mockNotificacionesRepository.obtenerNotificaciones(tUsuario.nroAfiliado));
    });
  });
}
