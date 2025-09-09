import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_tipo.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';
import 'package:cssayp_movil/boletas/domain/usecases/generar_boleta_inicio_use_case.dart';

import 'generar_boleta_inicio_use_case_test.mocks.dart';

@GenerateMocks([BoletasRepository, UsuarioRepository])
void main() {
  late GenerarBoletaInicioUseCase useCase;
  late MockBoletasRepository mockBoletasRepository;
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockBoletasRepository = MockBoletasRepository();
    mockUsuarioRepository = MockUsuarioRepository();
    useCase = GenerarBoletaInicioUseCase(
      boletasRepository: mockBoletasRepository,
      usuarioRepository: mockUsuarioRepository,
    );
  });

  group('GenerarBoletaInicioUseCase', () {
    const String caratula = 'Test Caratula';
    const double monto = 1000.50;
    const int nroAfiliado = 12345;

    final UsuarioEntity usuarioMock = UsuarioEntity(
      nroAfiliado: nroAfiliado,
      apellidoNombres: 'Test User',
      cambiarPassword: false,
      username: 'testuser',
    );

    final BoletaEntity boletaMock = BoletaEntity(
      id: 1,
      tipo: BoletaTipo.inicio,
      monto: monto,
      fechaImpresion: DateTime(2024, 1, 1),
      fechaVencimiento: DateTime(2024, 1, 31),
      caratula: caratula,
    );

    test('debería generar una boleta de inicio exitosamente cuando hay usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuarioMock);
      when(
        mockBoletasRepository.crearBoletaInicio(caratula: caratula, monto: monto, nroAfiliado: nroAfiliado),
      ).thenAnswer((_) async => boletaMock);

      // Act
      final result = await useCase.execute(caratula: caratula, monto: monto);

      // Assert
      expect(result, equals(boletaMock));
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.crearBoletaInicio(caratula: caratula, monto: monto, nroAfiliado: nroAfiliado),
      ).called(1);
    });

    test('debería lanzar excepción cuando no hay usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute(caratula: caratula, monto: monto),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('No hay usuario autenticado'))),
      );

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockBoletasRepository.crearBoletaInicio(
          caratula: anyNamed('caratula'),
          monto: anyNamed('monto'),
          nroAfiliado: anyNamed('nroAfiliado'),
        ),
      );
    });

    test('debería propagar excepción cuando el repositorio de boletas falla', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuarioMock);
      when(
        mockBoletasRepository.crearBoletaInicio(caratula: caratula, monto: monto, nroAfiliado: nroAfiliado),
      ).thenThrow(Exception('Error del repositorio'));

      // Act & Assert
      try {
        await useCase.execute(caratula: caratula, monto: monto);
        fail('Se esperaba que se lance una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error del repositorio'));
      }

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verify(
        mockBoletasRepository.crearBoletaInicio(caratula: caratula, monto: monto, nroAfiliado: nroAfiliado),
      ).called(1);
    });

    test('debería propagar excepción cuando el repositorio de usuario falla', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenThrow(Exception('Error de autenticación'));

      // Act & Assert
      try {
        await useCase.execute(caratula: caratula, monto: monto);
        fail('Se esperaba que se lance una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error de autenticación'));
      }

      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockBoletasRepository.crearBoletaInicio(
          caratula: anyNamed('caratula'),
          monto: anyNamed('monto'),
          nroAfiliado: anyNamed('nroAfiliado'),
        ),
      );
    });

    test('debería manejar correctamente diferentes valores de monto', () async {
      // Arrange
      const double montoDecimal = 1234.56;
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuarioMock);
      when(
        mockBoletasRepository.crearBoletaInicio(caratula: caratula, monto: montoDecimal, nroAfiliado: nroAfiliado),
      ).thenAnswer((_) async => boletaMock);

      // Act
      final result = await useCase.execute(caratula: caratula, monto: montoDecimal);

      // Assert
      expect(result, equals(boletaMock));
      verify(
        mockBoletasRepository.crearBoletaInicio(caratula: caratula, monto: montoDecimal, nroAfiliado: nroAfiliado),
      ).called(1);
    });

    test('debería manejar correctamente diferentes valores de caratula', () async {
      // Arrange
      const String caratulaEspecial = 'C/12345/2024 - JUAN PEREZ C/ EMPRESA S.A.';
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => usuarioMock);
      when(
        mockBoletasRepository.crearBoletaInicio(caratula: caratulaEspecial, monto: monto, nroAfiliado: nroAfiliado),
      ).thenAnswer((_) async => boletaMock);

      // Act
      final result = await useCase.execute(caratula: caratulaEspecial, monto: monto);

      // Assert
      expect(result, equals(boletaMock));
      verify(
        mockBoletasRepository.crearBoletaInicio(caratula: caratulaEspecial, monto: monto, nroAfiliado: nroAfiliado),
      ).called(1);
    });
  });
}
