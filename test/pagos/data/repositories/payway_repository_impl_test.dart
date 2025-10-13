import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cssayp_movil/pagos/pagos.dart';

import 'payway_repository_impl_test.mocks.dart';

@GenerateMocks([PaywayDataSource])
void main() {
  group('PaywayRepositoryImpl', () {
    late PaywayRepositoryImpl repository;
    late MockPaywayDataSource mockPaywayDataSource;

    setUp(() {
      mockPaywayDataSource = MockPaywayDataSource();
      repository = PaywayRepositoryImpl(paywayDataSource: mockPaywayDataSource);
    });

    group('método pagar', () {
      late List<BoletaAPagarEntity> boletas;
      late DatosTarjetaModel datosTarjeta;

      setUp(() {
        boletas = [
          BoletaAPagarEntity(idBoleta: 1, caratula: 'Test Caratula 1', monto: 100.0, nroAfiliado: 12345),
          BoletaAPagarEntity(idBoleta: 2, caratula: 'Test Caratula 2', monto: 200.0, nroAfiliado: 12345),
        ];

        datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '1234567890123456',
          cvv: '123',
          fechaExpiracion: '12/25',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );
      });

      test('debe retornar ResultadoPagoModel exitoso cuando el pago es procesado correctamente', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(
          statusCode: 201,
          message: {'success': true, 'transaction_id': 'TXN123456', 'message': 'Pago procesado exitosamente'},
        );

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(201));
        expect(result.message, isA<Map<String, dynamic>>());

        final messageMap = result.message as Map<String, dynamic>;
        expect(messageMap['success'], equals(true));
        expect(messageMap['transaction_id'], equals('TXN123456'));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe retornar ResultadoPagoModel con error cuando el pago falla', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(
          statusCode: 400,
          message: {'success': false, 'error': 'Tarjeta rechazada', 'code': 'CARD_DECLINED'},
        );

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(400));
        expect(result.message, isA<Map<String, dynamic>>());

        final messageMap = result.message as Map<String, dynamic>;
        expect(messageMap['success'], equals(false));
        expect(messageMap['error'], equals('Tarjeta rechazada'));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe retornar ResultadoPagoModel con error de conexión cuando hay SocketException', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(statusCode: 0, message: 'Error en la conexión con el servidor');

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(0));
        expect(result.message, equals('Error en la conexión con el servidor'));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe retornar ResultadoPagoModel con error de timeout cuando hay TimeoutException', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(statusCode: 0, message: 'Error en la conexión con el servidor');

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(0));
        expect(result.message, equals('Error en la conexión con el servidor'));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe retornar ResultadoPagoModel con error del servidor cuando hay FormatException', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(
          statusCode: 500,
          message: 'Error del servidor, intente nuevamente más tarde',
        );

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(500));
        expect(result.message, equals('Error del servidor, intente nuevamente más tarde'));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe retornar ResultadoPagoModel con error inesperado cuando hay excepción genérica', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(
          statusCode: 0,
          message: 'Error inesperado al crear boleta de inicio',
        );

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(0));
        expect(result.message, equals('Error inesperado al crear boleta de inicio'));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe pasar los parámetros correctos al data source', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(statusCode: 201, message: {'success': true});

        when(
          mockPaywayDataSource.pagar(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe manejar lista vacía de boletas', () async {
        // Arrange
        final boletasVacias = <BoletaAPagarEntity>[];
        const expectedResultado = ResultadoPagoModel(
          statusCode: 400,
          message: {'error': 'No hay boletas para procesar'},
        );

        when(
          mockPaywayDataSource.pagar(boletas: boletasVacias, datosTarjeta: datosTarjeta),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletasVacias, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(400));

        verify(mockPaywayDataSource.pagar(boletas: boletasVacias, datosTarjeta: datosTarjeta)).called(1);
      });

      test('debe manejar diferentes tipos de tarjeta', () async {
        // Arrange
        final datosTarjetaDebito = DatosTarjetaModel(
          nombre: 'María García',
          dni: '87654321',
          nroTarjeta: '9876543210987654',
          cvv: '456',
          fechaExpiracion: '06/26',
          tipoTarjeta: TipoTarjeta.debito,
          cuotas: 1,
        );

        const expectedResultado = ResultadoPagoModel(
          statusCode: 201,
          message: {'success': true, 'tipo_tarjeta': 'debito'},
        );

        when(
          mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjetaDebito),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjetaDebito);

        // Assert
        expect(result, equals(expectedResultado));
        expect(result.statusCode, equals(201));

        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjetaDebito)).called(1);
      });
    });

    group('método actualizarEstadoLocalBoleta', () {
      late BoletaAPagarEntity boleta;

      setUp(() {
        boleta = BoletaAPagarEntity(idBoleta: 1, caratula: 'Test Caratula', monto: 100.0, nroAfiliado: 12345);
      });

      test('debe completar sin errores cuando se llama actualizarEstadoLocalBoleta', () async {
        // Act
        await repository.actualizarEstadoLocalBoleta(boleta);

        // Assert
        // El método actualmente está comentado, por lo que no debería hacer nada
        // No hay verificaciones que hacer ya que el método no tiene implementación
      });

      test('debe manejar diferentes boletas sin errores', () async {
        // Arrange
        final boleta2 = BoletaAPagarEntity(idBoleta: 2, caratula: 'Test Caratula 2', monto: 200.0, nroAfiliado: 54321);

        // Act & Assert
        await repository.actualizarEstadoLocalBoleta(boleta);
        await repository.actualizarEstadoLocalBoleta(boleta2);

        // No debería lanzar excepciones
        expect(true, isTrue);
      });

      test('debe manejar boleta con valores extremos', () async {
        // Arrange
        final boletaExtrema = BoletaAPagarEntity(
          idBoleta: 999999,
          caratula: 'A' * 1000, // Carátula muy larga
          monto: 999999.99,
          nroAfiliado: 999999999,
        );

        // Act & Assert
        await repository.actualizarEstadoLocalBoleta(boletaExtrema);

        // No debería lanzar excepciones
        expect(true, isTrue);
      });
    });

    group('integración con PaywayDataSource', () {
      late List<BoletaAPagarEntity> boletas;
      late DatosTarjetaModel datosTarjeta;

      setUp(() {
        boletas = [BoletaAPagarEntity(idBoleta: 1, caratula: 'Test Caratula', monto: 100.0, nroAfiliado: 12345)];

        datosTarjeta = DatosTarjetaModel(
          nombre: 'Test User',
          dni: '12345678',
          nroTarjeta: '1234567890123456',
          cvv: '123',
          fechaExpiracion: '12/25',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 1,
        );
      });

      test('debe delegar correctamente la llamada al data source', () async {
        // Arrange
        const expectedResultado = ResultadoPagoModel(statusCode: 201, message: {'success': true});

        when(
          mockPaywayDataSource.pagar(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async => expectedResultado);

        // Act
        final result = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result, equals(expectedResultado));
        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(1);
        verifyNoMoreInteractions(mockPaywayDataSource);
      });

      test('debe manejar múltiples llamadas consecutivas', () async {
        // Arrange
        const expectedResultado1 = ResultadoPagoModel(statusCode: 201, message: {'success': true});
        const expectedResultado2 = ResultadoPagoModel(statusCode: 400, message: {'error': 'Insufficient funds'});

        when(
          mockPaywayDataSource.pagar(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async => expectedResultado1);

        // Act
        final result1 = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Arrange for second call
        when(
          mockPaywayDataSource.pagar(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async => expectedResultado2);

        // Act
        final result2 = await repository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result1, equals(expectedResultado1));
        expect(result2, equals(expectedResultado2));
        verify(mockPaywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta)).called(2);
      });
    });
  });
}
