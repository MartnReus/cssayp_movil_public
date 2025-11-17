import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/domain/entities/usuario_entity.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/shared/services/pdf_service.dart';

import 'generar_comprobante_usecase_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PdfService>(), MockSpec<UsuarioRepository>()])
void main() {
  late GenerarComprobanteUseCase useCase;
  late MockPdfService mockPdfService;
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockPdfService = MockPdfService();
    mockUsuarioRepository = MockUsuarioRepository();

    useCase = GenerarComprobanteUseCase(pdfService: mockPdfService, usuarioRepository: mockUsuarioRepository);
  });

  group('execute', () {
    final testUsuario = UsuarioEntity(
      nroAfiliado: 12345,
      apellidoNombres: 'Test Usuario',
      cambiarPassword: false,
      username: 'testuser',
    );

    final testComprobante = ComprobanteEntity(
      id: 123,
      fecha: '2025-10-26',
      importe: '1500.00',
      externalReferenceId: 'REF-123',
      boletasPagadas: [
        (
          id: 789,
          importe: '1500.00',
          caratula: 'Test Caratula',
          mvc: 'TEST-123',
          tipoJuicio: 'Civil',
          montosOrganismos: null,
        ),
      ],
      comprobanteLink: 'https://example.com/comprobante.pdf',
      metodoPago: 'Tarjeta de crédito',
    );

    const testFilePath = '/path/to/comprobante.pdf';

    test(
      'debería devolver la ruta del archivo cuando el usuario está autenticado y el PDF se genera correctamente',
      () async {
        // Arrange
        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
        when(
          mockPdfService.generarPdfComprobante(comprobante: testComprobante, usuario: testUsuario),
        ).thenAnswer((_) async => testFilePath);

        // Act
        final result = await useCase.execute(testComprobante);

        // Assert
        expect(result, testFilePath);
        verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
        verify(mockPdfService.generarPdfComprobante(comprobante: testComprobante, usuario: testUsuario)).called(1);
      },
    );

    test('debería lanzar una excepción cuando no hay un usuario autenticado', () async {
      // Arrange
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.execute(testComprobante),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', 'Exception: No hay usuario autenticado')),
      );
      verify(mockUsuarioRepository.obtenerUsuarioActual()).called(1);
      verifyNever(
        mockPdfService.generarPdfComprobante(comprobante: anyNamed('comprobante'), usuario: anyNamed('usuario')),
      );
    });

    test('debería propagar la excepción cuando el PDF service lanza una excepción', () async {
      // Arrange
      final testException = Exception('PDF generation failed');
      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUsuario);
      when(
        mockPdfService.generarPdfComprobante(comprobante: testComprobante, usuario: testUsuario),
      ).thenThrow(testException);

      // Act & Assert
      await expectLater(useCase.execute(testComprobante), throwsA(testException));
    });

    test('debería pasar los parámetros correctos al PDF service', () async {
      // Arrange
      final differentComprobante = ComprobanteEntity(
        id: 999,
        fecha: '2025-01-15',
        importe: '2500.00',
        externalReferenceId: 'REF-999',
        boletasPagadas: [],
      );
      final differentUsuario = UsuarioEntity(
        nroAfiliado: 99999,
        apellidoNombres: 'Different User',
        cambiarPassword: false,
        username: 'differentuser',
      );

      when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => differentUsuario);
      when(
        mockPdfService.generarPdfComprobante(comprobante: differentComprobante, usuario: differentUsuario),
      ).thenAnswer((_) async => '/different/path.pdf');

      // Act
      await useCase.execute(differentComprobante);

      // Assert
      verify(
        mockPdfService.generarPdfComprobante(comprobante: differentComprobante, usuario: differentUsuario),
      ).called(1);
    });
  });
}
