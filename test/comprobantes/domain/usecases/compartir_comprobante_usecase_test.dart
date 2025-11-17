import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:share_plus/share_plus.dart';

import 'package:cssayp_movil/comprobantes/comprobantes.dart';

import 'compartir_comprobante_usecase_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GenerarComprobanteUseCase>(), MockSpec<SharePlus>()])
void main() {
  late CompartirComprobanteUseCase useCase;
  late MockGenerarComprobanteUseCase mockGenerarComprobanteUseCase;
  late MockSharePlus mockSharePlus;

  setUp(() {
    mockGenerarComprobanteUseCase = MockGenerarComprobanteUseCase();
    mockSharePlus = MockSharePlus();

    useCase = CompartirComprobanteUseCase(
      generarComprobanteUseCase: mockGenerarComprobanteUseCase,
      sharePlus: mockSharePlus,
    );
  });

  group('execute', () {
    final testComprobante = ComprobanteEntity(
      id: 123,
      fecha: '2025-10-26',
      importe: '1500.00',
      externalReferenceId: 'REF-123',
      boletasPagadas: [],
    );

    const testFilePath = '/path/to/comprobante.pdf';

    test('debería generar el PDF y compartirlo exitosamente', () async {
      // Arrange
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async => testFilePath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.success));

      // Act
      await useCase.execute(testComprobante);

      // Assert
      verify(mockGenerarComprobanteUseCase.execute(testComprobante)).called(1);
      verify(mockSharePlus.share(any)).called(1);
    });

    test('debería llamar a share con los parámetros correctos', () async {
      // Arrange
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async => testFilePath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.success));

      // Act
      await useCase.execute(testComprobante);

      // Assert
      final captured = verify(mockSharePlus.share(captureAny)).captured.single as ShareParams;
      expect(captured.text, 'Comprobante de pago #123');
      expect(captured.subject, 'Comprobante CSSAyP');
      expect(captured.files?.length, 1);
      expect(captured.files?.first.path, testFilePath);
    });

    test('debería cuando share es "dismissed"', () async {
      // Arrange
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async => testFilePath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.dismissed));

      // Act - Should not throw
      await useCase.execute(testComprobante);

      // Assert
      verify(mockSharePlus.share(any)).called(1);
    });

    test('no debería llamar a share cuando la generación del PDF falla', () async {
      // Arrange
      final testException = Exception('PDF generation failed');
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenThrow(testException);

      // Act & Assert
      await expectLater(useCase.execute(testComprobante), throwsA(testException));
      verifyNever(mockSharePlus.share(any));
    });

    test('debería usar el ID correcto del comprobante en el texto para diferentes IDs', () async {
      // Arrange
      final comprobante1 = ComprobanteEntity(
        id: 999,
        fecha: '2025-10-26',
        importe: '1500.00',
        externalReferenceId: 'REF-999',
        boletasPagadas: [],
      );

      when(mockGenerarComprobanteUseCase.execute(comprobante1)).thenAnswer((_) async => testFilePath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.success));

      // Act
      await useCase.execute(comprobante1);

      // Assert
      final captured = verify(mockSharePlus.share(captureAny)).captured.single as ShareParams;
      expect(captured.text, 'Comprobante de pago #999');
    });

    test('debería verificar el orden de ejecución: PDF -> share', () async {
      // Arrange
      final callOrder = <String>[];

      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async {
        callOrder.add('pdf');
        return testFilePath;
      });
      when(mockSharePlus.share(any)).thenAnswer((_) async {
        callOrder.add('share');
        return const ShareResult('', ShareResultStatus.success);
      });

      // Act
      await useCase.execute(testComprobante);

      // Assert
      expect(callOrder, ['pdf', 'share']);
    });

    test('debería manejar share con estado "unavailable"', () async {
      // Arrange
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async => testFilePath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.unavailable));

      // Act - Should not throw
      await useCase.execute(testComprobante);
      // Assert
      verify(mockSharePlus.share(any)).called(1);
    });

    test('debería incluir el asunto correcto en los parámetros de compartir', () async {
      // Arrange
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async => testFilePath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.success));

      // Act
      await useCase.execute(testComprobante);

      // Assert
      final captured = verify(mockSharePlus.share(captureAny)).captured.single as ShareParams;
      expect(captured.subject, 'Comprobante CSSAyP');
    });

    test('debería pasar el archivo como XFile con la ruta correcta', () async {
      // Arrange
      const customPath = '/custom/path/to/file.pdf';
      when(mockGenerarComprobanteUseCase.execute(testComprobante)).thenAnswer((_) async => customPath);
      when(mockSharePlus.share(any)).thenAnswer((_) async => const ShareResult('', ShareResultStatus.success));

      // Act
      await useCase.execute(testComprobante);
      // Assert
      final captured = verify(mockSharePlus.share(captureAny)).captured.single as ShareParams;
      expect(captured.files?.length, 1);
      expect(captured.files?.first.path, customPath);
    });
  });
}
