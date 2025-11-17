import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/comprobantes/comprobantes.dart';

import 'comprobantes_notifier_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ObtenerComprobanteUseCase>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ComprobantesState', () {
    test('debería crear un state con comprobante', () {
      // Arrange
      final comprobante = ComprobanteEntity(
        id: 123,
        fecha: '2025-10-26',
        importe: '1500.00',
        externalReferenceId: 'REF-123',
        boletasPagadas: [],
      );

      // Act
      final state = ComprobantesState(comprobante: comprobante);

      // Assert
      expect(state.comprobante, comprobante);
      expect(state.comprobante.id, 123);
    });

    test('copyWith debería devolver un nuevo state con el comprobante actualizado', () {
      // Arrange
      final originalComprobante = ComprobanteEntity(
        id: 123,
        fecha: '2025-10-26',
        importe: '1500.00',
        externalReferenceId: 'REF-123',
        boletasPagadas: [],
      );
      final newComprobante = ComprobanteEntity(
        id: 456,
        fecha: '2025-10-27',
        importe: '2500.00',
        externalReferenceId: 'REF-456',
        boletasPagadas: [],
      );
      final state = ComprobantesState(comprobante: originalComprobante);

      // Act
      final newState = state.copyWith(comprobante: newComprobante);

      // Assert
      expect(newState.comprobante, newComprobante);
      expect(newState.comprobante.id, 456);
      expect(state.comprobante.id, 123); // Original unchanged
    });

    test('copyWith debería devolver un state con el comprobante existente cuando se pasa null', () {
      // Arrange
      final comprobante = ComprobanteEntity(
        id: 123,
        fecha: '2025-10-26',
        importe: '1500.00',
        externalReferenceId: 'REF-123',
        boletasPagadas: [],
      );
      final state = ComprobantesState(comprobante: comprobante);

      // Act
      final newState = state.copyWith();

      // Assert
      expect(newState.comprobante, comprobante);
      expect(newState.comprobante.id, 123);
    });
  });

  group('ComprobantesNotifier', () {
    late ProviderContainer container;
    late MockObtenerComprobanteUseCase mockObtenerComprobanteUseCase;

    setUp(() {
      mockObtenerComprobanteUseCase = MockObtenerComprobanteUseCase();

      container = ProviderContainer(
        overrides: [
          obtenerComprobanteUseCaseProvider.overrideWithValue(AsyncValue.data(mockObtenerComprobanteUseCase)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      reset(mockObtenerComprobanteUseCase);
    });

    test('debería inicializarse con un state vacío por defecto', () async {
      // Act
      final state = await container.read(comprobantesProvider.future);

      // Assert
      expect(state.comprobante.id, 0);
      expect(state.comprobante.fecha, '');
      expect(state.comprobante.externalReferenceId, '');
      expect(state.comprobante.importe, '0');
      expect(state.comprobante.boletasPagadas, isEmpty);
    });

    test('obtenerComprobante debería actualizar el state con el comprobante en caso de éxito', () async {
      // Arrange
      const testIdBoleta = 123;
      final testComprobante = ComprobanteEntity(
        id: 456,
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

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenAnswer((_) async => testComprobante);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      await notifier.obtenerComprobante(testIdBoleta);

      // Assert
      final state = container.read(comprobantesProvider);
      expect(state.hasValue, true);
      expect(state.value!.comprobante.id, 456);
      expect(state.value!.comprobante.fecha, '2025-10-26');
      expect(state.value!.comprobante.importe, '1500.00');
      expect(state.value!.comprobante.boletasPagadas.length, 1);
      expect(state.value!.comprobante.comprobanteLink, 'https://example.com/comprobante.pdf');
      verify(mockObtenerComprobanteUseCase.execute(testIdBoleta)).called(1);
    });

    test(
      'obtenerComprobante debería establecer el state en AsyncError cuando el use case lanza una excepción',
      () async {
      // Arrange
      const testIdBoleta = 123;
      final testException = Exception('Error al obtener comprobante');

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenThrow(testException);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      await notifier.obtenerComprobante(testIdBoleta);

      // Assert
      final state = container.read(comprobantesProvider);
      expect(state.hasError, true);
      expect(state.error, testException);
      verify(mockObtenerComprobanteUseCase.execute(testIdBoleta)).called(1);
    });

    test('obtenerComprobante debería pasar el idBoletaPagada correcto al use case', () async {
      // Arrange
      const testIdBoleta = 999;
      final testComprobante = ComprobanteEntity(
        id: 999,
        fecha: '2025-10-26',
        importe: '100.00',
        externalReferenceId: 'REF-999',
        boletasPagadas: [],
      );

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenAnswer((_) async => testComprobante);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      await notifier.obtenerComprobante(testIdBoleta);

      // Assert
      verify(mockObtenerComprobanteUseCase.execute(testIdBoleta)).called(1);
      verifyNoMoreInteractions(mockObtenerComprobanteUseCase);
    });

    test('obtenerComprobante debería manejar múltiples llamadas de forma independiente', () async {
      // Arrange
      const firstId = 111;
      const secondId = 222;

      final firstComprobante = ComprobanteEntity(
        id: 111,
        fecha: '2025-10-26',
        importe: '100.00',
        externalReferenceId: 'REF-111',
        boletasPagadas: [],
      );

      final secondComprobante = ComprobanteEntity(
        id: 222,
        fecha: '2025-10-27',
        importe: '200.00',
        externalReferenceId: 'REF-222',
        boletasPagadas: [],
      );

      when(mockObtenerComprobanteUseCase.execute(firstId)).thenAnswer((_) async => firstComprobante);
      when(mockObtenerComprobanteUseCase.execute(secondId)).thenAnswer((_) async => secondComprobante);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act - First call
      await notifier.obtenerComprobante(firstId);
      final firstState = container.read(comprobantesProvider);

      // Act - Second call
      await notifier.obtenerComprobante(secondId);
      final secondState = container.read(comprobantesProvider);

      // Assert
      expect(firstState.value!.comprobante.id, 111);
      expect(secondState.value!.comprobante.id, 222);
      verify(mockObtenerComprobanteUseCase.execute(firstId)).called(1);
      verify(mockObtenerComprobanteUseCase.execute(secondId)).called(1);
    });

    test('obtenerComprobante debería actualizar el state con todos los campos del comprobante', () async {
      // Arrange
      const testIdBoleta = 123;
      final testComprobante = ComprobanteEntity(
        id: 456,
        fecha: '2025-10-26',
        importe: '2500.50',
        externalReferenceId: 'REF-XYZ-789',
        boletasPagadas: [
          (
            id: 100,
            importe: '1000.00',
            caratula: 'Caratula 1',
            mvc: 'MVC-001',
            tipoJuicio: 'Penal',
            montosOrganismos: [(circunscripcion: 1, organismo: 'Organismo 1', monto: 1000.0)],
          ),
          (
            id: 200,
            importe: '1500.50',
            caratula: 'Caratula 2',
            mvc: 'MVC-002',
            tipoJuicio: 'Civil',
            montosOrganismos: null,
          ),
        ],
        comprobanteLink: 'https://example.com/comprobante-123.pdf',
        metodoPago: 'Transferencia bancaria',
      );

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenAnswer((_) async => testComprobante);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      await notifier.obtenerComprobante(testIdBoleta);

      // Assert
      final state = container.read(comprobantesProvider);
      final comprobante = state.value!.comprobante;

      expect(comprobante.id, 456);
      expect(comprobante.fecha, '2025-10-26');
      expect(comprobante.importe, '2500.50');
      expect(comprobante.externalReferenceId, 'REF-XYZ-789');
      expect(comprobante.boletasPagadas.length, 2);
      expect(comprobante.boletasPagadas[0].id, 100);
      expect(comprobante.boletasPagadas[0].caratula, 'Caratula 1');
      expect(comprobante.boletasPagadas[1].id, 200);
      expect(comprobante.boletasPagadas[1].mvc, 'MVC-002');
      expect(comprobante.comprobanteLink, 'https://example.com/comprobante-123.pdf');
      expect(comprobante.metodoPago, 'Transferencia bancaria');
    });

    test('obtenerComprobante debería manejar un comprobante con una lista vacía de boletas', () async {
      // Arrange
      const testIdBoleta = 123;
      final testComprobante = ComprobanteEntity(
        id: 456,
        fecha: '2025-10-26',
        importe: '0.00',
        externalReferenceId: 'REF-EMPTY',
        boletasPagadas: [],
        comprobanteLink: null,
        metodoPago: null,
      );

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenAnswer((_) async => testComprobante);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      await notifier.obtenerComprobante(testIdBoleta);

      // Assert
      final state = container.read(comprobantesProvider);
      expect(state.value!.comprobante.boletasPagadas, isEmpty);
      expect(state.value!.comprobante.comprobanteLink, isNull);
      expect(state.value!.comprobante.metodoPago, isNull);
    });

    test('obtenerComprobante debería manejar diferentes tipos de error', () async {
      // Arrange
      const testIdBoleta = 123;
      const errorMessage = 'Network error';

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenThrow(Exception(errorMessage));

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      await notifier.obtenerComprobante(testIdBoleta);

      // Assert
      final state = container.read(comprobantesProvider);
      expect(state.hasError, true);
      expect(state.error.toString(), contains(errorMessage));
    });

    test('el state debería tener un estado loading durante la obtención', () async {
      // Arrange
      const testIdBoleta = 123;
      final testComprobante = ComprobanteEntity(
        id: 456,
        fecha: '2025-10-26',
        importe: '1500.00',
        externalReferenceId: 'REF-123',
        boletasPagadas: [],
      );

      when(mockObtenerComprobanteUseCase.execute(testIdBoleta)).thenAnswer((_) async => testComprobante);

      final notifier = container.read(comprobantesProvider.notifier);

      // Act
      final future = notifier.obtenerComprobante(testIdBoleta);

      // Check loading state immediately after calling
      final loadingState = container.read(comprobantesProvider);
      expect(loadingState.isLoading, true);

      // Wait for completion
      await future;

      // Assert final state
      final finalState = container.read(comprobantesProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value!.comprobante.id, 456);
    });
  });
}
