import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:cssayp_movil/notificaciones/domain/usecases/marcar_notificaciones_leidas_usecase.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'marcar_notificaciones_leidas_usecase_test.mocks.dart';

@GenerateMocks([NotificacionesRepository, UsuarioRepository])
void main() {
  late MarcarNotificacionesLeidasUseCase useCase;
  late MockNotificacionesRepository mockNotificacionesRepository;
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockNotificacionesRepository = MockNotificacionesRepository();
    mockUsuarioRepository = MockUsuarioRepository();
    useCase = MarcarNotificacionesLeidasUseCase(
      notificacionesRepository: mockNotificacionesRepository,
      usuarioRepository: mockUsuarioRepository,
    );
  });

  group('MarcarNotificacionesLeidasUseCase', () {
    const tUuidList = ['uuid1', 'uuid2'];
    final tUsuario = UsuarioEntity(
      nroAfiliado: 123,
      apellidoNombres: 'Test User',
      cambiarPassword: false,
      username: 'testuser',
    );

    test('debe lanzar AuthNotAuthenticatedException si el usuario es nulo', () async {
      // arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // act
      final call = useCase.execute;

      // assert
      expect(() => call(tUuidList), throwsA(isA<AuthNotAuthenticatedException>()));
      verify(mockUsuarioRepository.obtenerUsuarioActual());
      verifyZeroInteractions(mockNotificacionesRepository);
    });

    test('debe llamar al repositorio si el usuario existe', () async {
      // arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => tUsuario);
      when(
        mockNotificacionesRepository.marcarNotificacionesComoLeidas(any, any),
      ).thenAnswer((_) async => Future.value());

      // act
      await useCase.execute(tUuidList);

      // assert
      verify(mockUsuarioRepository.obtenerUsuarioActual());
      verify(mockNotificacionesRepository.marcarNotificacionesComoLeidas(tUuidList, tUsuario.nroAfiliado));
    });
  });
}
