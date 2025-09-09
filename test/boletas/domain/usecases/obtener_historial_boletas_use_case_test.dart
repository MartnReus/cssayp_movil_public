import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

import 'obtener_historial_boletas_use_case_test.mocks.dart';

@GenerateMocks([BoletasRepository, UsuarioRepository])
void main() {
  group('ObtenerHistorialBoletasUseCase', () {
    late ObtenerHistorialBoletasUseCase useCase;
    late MockBoletasRepository mockBoletasRepository;
    late MockUsuarioRepository mockUsuarioRepository;

    setUp(() {
      mockBoletasRepository = MockBoletasRepository();
      mockUsuarioRepository = MockUsuarioRepository();
      useCase = ObtenerHistorialBoletasUseCase(
        boletasRepository: mockBoletasRepository,
        usuarioRepository: mockUsuarioRepository,
      );
    });

    group('execute', () {
      test('debería retornar HistorialBoletasSuccessResponse cuando el usuario está autenticado', () async {
        // Arrange
        const nroAfiliado = 12345;
        const page = 1;
        final usuario = UsuarioEntity(
          nroAfiliado: nroAfiliado,
          apellidoNombres: 'Test User',
          cambiarPassword: false,
          username: 'testuser',
        );

        final boletaHistorial = BoletaHistorialModel(idBoletaGenerada: '1', monto: '100.0', caratula: 'Test Caratula');

        final expectedResponse = HistorialBoletasSuccessResponse(
          statusCode: 200,
          currentPage: 1,
          boletas: [boletaHistorial],
          lastPage: 1,
          total: 1,
          perPage: 10,
        );

        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuario);
        when(
          mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: page),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await useCase.execute(page: page);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
        verify(mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: page)).called(1);
      });

      test('debería retornar HistorialBoletasSuccessResponse cuando no se especifica página', () async {
        // Arrange
        const nroAfiliado = 12345;
        final usuario = UsuarioEntity(
          nroAfiliado: nroAfiliado,
          apellidoNombres: 'Test User',
          cambiarPassword: false,
          username: 'testuser',
        );

        final boletaHistorial = BoletaHistorialModel(idBoletaGenerada: '1', monto: '100.0', caratula: 'Test Caratula');

        final expectedResponse = HistorialBoletasSuccessResponse(
          statusCode: 200,
          currentPage: 1,
          boletas: [boletaHistorial],
          lastPage: 1,
          total: 1,
          perPage: 10,
        );

        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuario);
        when(
          mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: null),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
        verify(mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: null)).called(1);
      });

      test('debería lanzar AuthNotAuthenticatedException cuando no hay usuario autenticado', () async {
        // Arrange
        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

        // Act & Assert
        expect(() => useCase.execute(page: 1), throwsA(isA<AuthNotAuthenticatedException>()));

        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
        verifyNever(mockBoletasRepository.obtenerHistorialBoletas(any, page: anyNamed('page')));
      });

      test(
        'debería lanzar AuthNotAuthenticatedException con mensaje correcto cuando no hay usuario autenticado',
        () async {
          // Arrange
          when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

          // Act & Assert
          try {
            await useCase.execute(page: 1);
            fail('Se esperaba que se lance AuthNotAuthenticatedException');
          } catch (e) {
            expect(e, isA<AuthNotAuthenticatedException>());
            final exception = e as AuthNotAuthenticatedException;
            expect(exception.message, equals('No hay usuario autenticado'));
          }

          verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
          verifyNever(mockBoletasRepository.obtenerHistorialBoletas(any, page: anyNamed('page')));
        },
      );

      test('debería pasar correctamente el nroAfiliado del usuario al repositorio', () async {
        // Arrange
        const nroAfiliado = 98765;
        const page = 2;
        final usuario = UsuarioEntity(
          nroAfiliado: nroAfiliado,
          apellidoNombres: 'Another User',
          cambiarPassword: true,
          username: 'anotheruser',
        );

        final expectedResponse = HistorialBoletasSuccessResponse(
          statusCode: 200,
          currentPage: 2,
          boletas: [],
          lastPage: 2,
          total: 0,
          perPage: 10,
        );

        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuario);
        when(
          mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: page),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        await useCase.execute(page: page);

        // Assert
        verify(mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: page)).called(1);
      });

      test('debería propagar excepciones del repositorio de boletas', () async {
        // Arrange
        const nroAfiliado = 12345;
        final usuario = UsuarioEntity(
          nroAfiliado: nroAfiliado,
          apellidoNombres: 'Test User',
          cambiarPassword: false,
          username: 'testuser',
        );

        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuario);
        when(
          mockBoletasRepository.obtenerHistorialBoletas(any, page: anyNamed('page')),
        ).thenThrow(Exception('Error del repositorio'));

        // Act & Assert
        try {
          await useCase.execute(page: 1);
          fail('Se esperaba que se lance una excepción');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Error del repositorio'));
        }

        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
        verify(mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: 1)).called(1);
      });

      test('debería propagar excepciones del repositorio de usuario', () async {
        // Arrange
        when(mockUsuarioRepository.obtenerUsuarioActual()).thenThrow(Exception('Error de conexión'));

        // Act & Assert
        expect(() => useCase.execute(page: 1), throwsA(isA<Exception>()));

        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
        verifyNever(mockBoletasRepository.obtenerHistorialBoletas(any, page: anyNamed('page')));
      });

      test('debería manejar múltiples páginas correctamente', () async {
        // Arrange
        const nroAfiliado = 12345;
        const page = 3;
        final usuario = UsuarioEntity(
          nroAfiliado: nroAfiliado,
          apellidoNombres: 'Test User',
          cambiarPassword: false,
          username: 'testuser',
        );

        final boletas = List.generate(
          5,
          (index) => BoletaHistorialModel(
            idBoletaGenerada: '${index + 1}',
            monto: '${(index + 1) * 100}.0',
            caratula: 'Caratula ${index + 1}',
          ),
        );

        final expectedResponse = HistorialBoletasSuccessResponse(
          statusCode: 200,
          currentPage: 3,
          boletas: boletas,
          lastPage: 5,
          total: 25,
          perPage: 5,
          nextPageUrl: 'http://api.example.com/boletas?page=4',
          prevPageUrl: 'http://api.example.com/boletas?page=2',
        );

        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuario);
        when(
          mockBoletasRepository.obtenerHistorialBoletas(nroAfiliado, page: page),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await useCase.execute(page: page);

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.currentPage, equals(3));
        expect(result.boletas.length, equals(5));
        expect(result.lastPage, equals(5));
        expect(result.total, equals(25));
        expect(result.nextPageUrl, isNotNull);
        expect(result.prevPageUrl, isNotNull);
      });
    });
  });
}
