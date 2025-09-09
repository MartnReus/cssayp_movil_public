import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cssayp_movil/boletas/domain/usecases/buscar_boletas_inicio_pagadas_use_case.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';

import 'buscar_boletas_inicio_pagadas_use_case_test.mocks.dart';

@GenerateMocks([BoletasRepository, UsuarioRepository])
void main() {
  late BuscarBoletasInicioPagadasUseCase useCase;
  late MockBoletasRepository mockBoletasRepository;
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockBoletasRepository = MockBoletasRepository();
    mockUsuarioRepository = MockUsuarioRepository();
    useCase = BuscarBoletasInicioPagadasUseCase(
      boletasRepository: mockBoletasRepository,
      usuarioRepository: mockUsuarioRepository,
    );
  });

  group('BuscarBoletasInicioPagadasUseCase', () {
    const testNroAfiliado = 12345;
    final testUsuario = UsuarioEntity(
      nroAfiliado: testNroAfiliado,
      apellidoNombres: 'Test User',
      cambiarPassword: false,
      username: 'testuser',
    );

    final testPaginatedResponse = PaginatedResponseModel(
      statusCode: 200,
      data: [
        {'id': 1, 'caratula': 'Test Boleta 1', 'monto': 1000.0, 'fecha': '2024-01-01'},
        {'id': 2, 'caratula': 'Test Boleta 2', 'monto': 2000.0, 'fecha': '2024-01-02'},
      ],
      currentPage: 1,
      lastPage: 3,
      total: 25,
      perPage: 10,
    );

    test('debería ejecutar correctamente cuando hay usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).thenAnswer((_) async => testPaginatedResponse);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(testPaginatedResponse));
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).called(1);
    });

    test('debería ejecutar correctamente con parámetros personalizados', () async {
      // Arrange
      const customPage = 2;
      const customCaratula = 'Test Search';

      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: customPage,
          caratulaBuscada: customCaratula,
        ),
      ).thenAnswer((_) async => testPaginatedResponse);

      // Act
      final result = await useCase.execute(page: customPage, caratulaBuscada: customCaratula);

      // Assert
      expect(result, equals(testPaginatedResponse));
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: customPage,
          caratulaBuscada: customCaratula,
        ),
      ).called(1);
    });

    test('debería lanzar excepción cuando no hay usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('No hay usuario autenticado'))),
      );

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockBoletasRepository.buscarBoletasInicioPagadas(
          nroAfiliado: anyNamed('nroAfiliado'),
          page: anyNamed('page'),
          caratulaBuscada: anyNamed('caratulaBuscada'),
        ),
      );
    });

    test('debería propagar excepción del repositorio de boletas', () async {
      // Arrange
      const errorMessage = 'Error del servidor';
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).thenThrow(Exception(errorMessage));

      // Act & Assert
      try {
        await useCase.execute();
        fail('Se esperaba que se lanzara una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains(errorMessage));
      }

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).called(1);
    });

    test('debería propagar excepción del repositorio de usuario', () async {
      // Arrange
      const errorMessage = 'Error de conexión';
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenThrow(Exception(errorMessage));

      // Act & Assert
      try {
        await useCase.execute();
        fail('Se esperaba que se lanzara una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains(errorMessage));
      }

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockBoletasRepository.buscarBoletasInicioPagadas(
          nroAfiliado: anyNamed('nroAfiliado'),
          page: anyNamed('page'),
          caratulaBuscada: anyNamed('caratulaBuscada'),
        ),
      );
    });

    test('debería usar valores por defecto correctos', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).thenAnswer((_) async => testPaginatedResponse);

      // Act
      await useCase.execute();

      // Assert
      verify(
        mockBoletasRepository.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: 1, // valor por defecto
          caratulaBuscada: null, // valor por defecto
        ),
      ).called(1);
    });

    test('debería manejar respuesta vacía correctamente', () async {
      // Arrange
      final emptyResponse = PaginatedResponseModel(
        statusCode: 200,
        data: [],
        currentPage: 1,
        lastPage: 1,
        total: 0,
        perPage: 10,
      );

      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).thenAnswer((_) async => emptyResponse);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(emptyResponse));
      expect(result.data, isEmpty);
      expect(result.total, equals(0));
    });

    test('debería manejar caratulaBuscada como null cuando no se proporciona', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).thenAnswer((_) async => testPaginatedResponse);

      // Act
      await useCase.execute(page: 1);

      // Assert
      verify(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).called(1);
    });

    test('debería manejar caratulaBuscada como string vacío', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: ''),
      ).thenAnswer((_) async => testPaginatedResponse);

      // Act
      await useCase.execute(caratulaBuscada: '');

      // Assert
      verify(
        mockBoletasRepository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: ''),
      ).called(1);
    });
  });
}
