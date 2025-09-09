import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_tipo.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';
import 'package:cssayp_movil/boletas/domain/usecases/generar_boleta_finalizacion_use_case.dart';

import 'generar_boleta_finalizacion_use_case_test.mocks.dart';

@GenerateMocks([BoletasRepository, UsuarioRepository])
void main() {
  late GenerarBoletaFinalizacionUseCase useCase;
  late MockBoletasRepository mockBoletasRepository;
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockBoletasRepository = MockBoletasRepository();
    mockUsuarioRepository = MockUsuarioRepository();
    useCase = GenerarBoletaFinalizacionUseCase(
      boletasRepository: mockBoletasRepository,
      usuarioRepository: mockUsuarioRepository,
    );
  });

  group('GenerarBoletaFinalizacionUseCase', () {
    const int testIdBoletaInicio = 123;
    const double testMonto = 1500.50;
    final DateTime testFechaRegulacion = DateTime(2024, 1, 15);
    const double testHonorarios = 500.25;
    const String testCaratula = 'Test vs Test S.A.';
    const double testCantidadJus = 2.0;
    const double testValorJus = 100.0;
    const int testNroExpediente = 456;
    const int testAnioExpediente = 2024;
    const int testCuij = 789;

    final UsuarioEntity testUsuario = UsuarioEntity(
      nroAfiliado: 12345,
      apellidoNombres: 'Test User',
      cambiarPassword: false,
      username: 'testuser',
    );

    final BoletaEntity testBoleta = BoletaEntity(
      id: 999,
      tipo: BoletaTipo.finalizacion,
      monto: testMonto,
      fechaImpresion: DateTime.now(),
      fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
      caratula: testCaratula,
      idBoletaAsociada: testIdBoletaInicio,
    );

    test('debería generar boleta de finalización exitosamente cuando hay usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: testUsuario.nroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        ),
      ).thenAnswer((_) async => testBoleta);

      // Act
      final result = await useCase.execute(
        idBoletaInicio: testIdBoletaInicio,
        monto: testMonto,
        fechaRegulacion: testFechaRegulacion,
        honorarios: testHonorarios,
        caratula: testCaratula,
        cantidadJus: testCantidadJus,
        valorJus: testValorJus,
        nroExpediente: testNroExpediente,
        anioExpediente: testAnioExpediente,
        cuij: testCuij,
      );

      // Assert
      expect(result, equals(testBoleta));
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: testUsuario.nroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        ),
      ).called(1);
    });

    test('debería generar boleta de finalización exitosamente sin campos opcionales', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: testUsuario.nroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).thenAnswer((_) async => testBoleta);

      // Act
      final result = await useCase.execute(
        idBoletaInicio: testIdBoletaInicio,
        monto: testMonto,
        fechaRegulacion: testFechaRegulacion,
        honorarios: testHonorarios,
        caratula: testCaratula,
        cantidadJus: testCantidadJus,
        valorJus: testValorJus,
      );

      // Assert
      expect(result, equals(testBoleta));
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: testUsuario.nroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).called(1);
    });

    test('debería lanzar excepción cuando no hay usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute(
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          caratula: testCaratula,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('No hay usuario autenticado'))),
      );

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: anyNamed('nroAfiliado'),
          caratula: anyNamed('caratula'),
          idBoletaInicio: anyNamed('idBoletaInicio'),
          monto: anyNamed('monto'),
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: anyNamed('honorarios'),
          cantidadJus: anyNamed('cantidadJus'),
          valorJus: anyNamed('valorJus'),
          nroExpediente: anyNamed('nroExpediente'),
          anioExpediente: anyNamed('anioExpediente'),
          cuij: anyNamed('cuij'),
        ),
      );
    });

    test('debería propagar excepción del repositorio de boletas', () async {
      // Arrange
      const String errorMessage = 'Error del repositorio';
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: testUsuario.nroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).thenThrow(Exception(errorMessage));

      // Act & Assert
      try {
        await useCase.execute(
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          caratula: testCaratula,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
        );
        fail('Se esperaba que se lance una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains(errorMessage));
      }

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: testUsuario.nroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).called(1);
    });

    test('debería propagar excepción del repositorio de usuario', () async {
      // Arrange
      const String errorMessage = 'Error del repositorio de usuario';
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenThrow(Exception(errorMessage));

      // Act & Assert
      try {
        await useCase.execute(
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          caratula: testCaratula,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
        );
        fail('Se esperaba que se lance una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains(errorMessage));
      }

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockBoletasRepository.crearBoletaFinalizacion(
          nroAfiliado: anyNamed('nroAfiliado'),
          caratula: anyNamed('caratula'),
          idBoletaInicio: anyNamed('idBoletaInicio'),
          monto: anyNamed('monto'),
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: anyNamed('honorarios'),
          cantidadJus: anyNamed('cantidadJus'),
          valorJus: anyNamed('valorJus'),
          nroExpediente: anyNamed('nroExpediente'),
          anioExpediente: anyNamed('anioExpediente'),
          cuij: anyNamed('cuij'),
        ),
      );
    });
  });
}
