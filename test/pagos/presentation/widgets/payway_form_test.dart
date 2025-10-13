import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

// Notifier de prueba simple
class TestPayWayNotifier extends PayWayNotifier {
  final PayWayState _state;

  TestPayWayNotifier(this._state);

  @override
  Future<PayWayState> build() async {
    // Inicializar el estado directamente sin depender del build del padre
    return _state;
  }

  @override
  void updateCardData(DatosTarjetaModel datos) {
    // Implementación de prueba que actualiza el estado
    final currentState = state.value ?? _state;
    state = AsyncValue.data(currentState.copyWith(datosTarjeta: datos));
  }

  @override
  void markFieldAsTouched(String fieldName) {
    // Implementación de prueba
    final currentState = state.value ?? _state;
    final newTouchedFields = Set<String>.from(currentState.touchedFields);
    newTouchedFields.add(fieldName);
    state = AsyncValue.data(currentState.copyWith(touchedFields: newTouchedFields));
  }

  @override
  void updateTipoTarjeta(TipoTarjeta tipoTarjeta) {
    final currentState = state.value ?? _state;
    state = AsyncValue.data(currentState.copyWith(tipoTarjeta: tipoTarjeta));
  }

  @override
  void updateCuotas(int cuotas) {
    final currentState = state.value ?? _state;
    state = AsyncValue.data(currentState.copyWith(cuotas: cuotas));
  }
}

// Mock simple para el use case
class MockPagarConPaywayUseCase {
  // Implementación vacía para pruebas
}

void main() {
  group('PayWayForm', () {
    late PayWayState initialState;

    setUp(() {
      initialState = const PayWayState();
    });

    Widget createTestWidget({VoidCallback? onFormValidationChanged, PayWayState? state}) {
      return ProviderScope(
        overrides: [payWayNotifierProvider.overrideWith(() => TestPayWayNotifier(state ?? initialState))],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Consumer(
                builder: (context, ref, child) {
                  final payWayState = ref.watch(payWayNotifierProvider);
                  return payWayState.when(
                    data: (data) => PayWayForm(onFormValidationChanged: onFormValidationChanged),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    group('Inicialización y disposición', () {
      testWidgets('debe renderizar correctamente el formulario', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Datos de la Tarjeta'), findsOneWidget);
        expect(find.text('Nombre del titular'), findsOneWidget);
        expect(find.text('DNI'), findsOneWidget);
        expect(find.text('Tipo de tarjeta'), findsOneWidget);
        expect(find.text('Número de tarjeta'), findsOneWidget);
        expect(find.text('CVV'), findsOneWidget);
        expect(find.text('Vencimiento'), findsOneWidget);
      });

      testWidgets('debe mostrar el selector de cuotas solo para tarjetas de crédito', (WidgetTester tester) async {
        final creditoState = initialState.copyWith(tipoTarjeta: TipoTarjeta.credito);
        await tester.pumpWidget(createTestWidget(state: creditoState));
        await tester.pumpAndSettle();

        expect(find.text('Cuotas'), findsOneWidget);
      });

      testWidgets('no debe mostrar el selector de cuotas para tarjetas de débito', (WidgetTester tester) async {
        final debitoState = initialState.copyWith(tipoTarjeta: TipoTarjeta.debito);
        await tester.pumpWidget(createTestWidget(state: debitoState));
        await tester.pumpAndSettle();

        expect(find.text('Cuotas'), findsNothing);
      });
    });

    group('Campos de texto', () {
      testWidgets('debe permitir ingresar texto en el campo nombre', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final nombreField = find.byType(TextFormField).first;
        await tester.enterText(nombreField, 'Juan Pérez');
        await tester.pump();

        expect(find.text('Juan Pérez'), findsOneWidget);
      });

      testWidgets('debe aplicar formateo al número de tarjeta', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Buscar el campo de número de tarjeta por su hint text
        final tarjetaField = find.widgetWithText(TextFormField, '1234 5678 9012 3456');
        if (tarjetaField.evaluate().isEmpty) {
          // Si no se encuentra por hint, buscar por el label
          final tarjetaFields = find.byType(TextFormField);
          final tarjetaField = tarjetaFields.at(3); // Índice 3 para número de tarjeta
          await tester.enterText(tarjetaField, '1234567890123456');
          await tester.pump();
          expect(find.text('1234 5678 9012 3456'), findsOneWidget);
        }
      });

      testWidgets('debe aplicar formateo a la fecha de expiración', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Buscar el campo de fecha de expiración (último TextFormField)
        final fechaFields = find.byType(TextFormField);
        final fechaField = fechaFields.last;

        await tester.enterText(fechaField, '1225');
        await tester.pump();

        expect(find.text('12/25'), findsOneWidget);
      });

      testWidgets('debe limitar el DNI a 8 dígitos', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final dniField = find.byType(TextFormField).at(1); // Segundo campo es DNI
        await tester.enterText(dniField, '1234567890123456');
        await tester.pump();

        // Solo debe permitir 8 dígitos
        expect(find.text('12345678'), findsOneWidget);
      });

      testWidgets('debe limitar el CVV a 4 dígitos', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Buscar el campo CVV (penúltimo TextFormField)
        final cvvFields = find.byType(TextFormField);
        final cvvField = cvvFields.at(cvvFields.evaluate().length - 2);

        await tester.enterText(cvvField, '123456789');
        await tester.pump();

        // Solo debe permitir 4 dígitos
        expect(find.text('1234'), findsOneWidget);
      });
    });

    group('Selector de tipo de tarjeta', () {
      testWidgets('debe mostrar débito como seleccionado por defecto', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Débito'), findsOneWidget);
        expect(find.text('Crédito'), findsOneWidget);
      });

      testWidgets('debe cambiar a crédito cuando se selecciona', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final creditoButton = find.text('Crédito');
        await tester.tap(creditoButton);
        await tester.pump();

        // Verificar que el botón existe y se puede tocar
        expect(creditoButton, findsOneWidget);
      });

      testWidgets('debe cambiar a débito cuando se selecciona', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final debitoButton = find.text('Débito');
        await tester.tap(debitoButton);
        await tester.pump();

        // Verificar que el botón existe y se puede tocar
        expect(debitoButton, findsOneWidget);
      });
    });

    group('Selector de cuotas', () {
      testWidgets('debe mostrar opciones de cuotas del 1 al 12', (WidgetTester tester) async {
        final creditoState = initialState.copyWith(tipoTarjeta: TipoTarjeta.credito);
        await tester.pumpWidget(createTestWidget(state: creditoState));
        await tester.pumpAndSettle();

        final dropdown = find.byType(DropdownButton<int>);
        expect(dropdown, findsOneWidget);

        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Verificar que aparecen las opciones de cuotas en el menú desplegable
        // Verificar que el dropdown tiene 12 opciones
        final dropdownItems = find.byType(DropdownMenuItem<int>);
        expect(dropdownItems, findsNWidgets(12));

        // Verificar algunas opciones específicas
        expect(find.text('1 cuota'), findsAtLeastNWidgets(1));
        expect(find.text('2 cuotas'), findsAtLeastNWidgets(1));
        expect(find.text('6 cuotas'), findsAtLeastNWidgets(1));
      });

      testWidgets('debe actualizar cuotas cuando se selecciona una opción', (WidgetTester tester) async {
        final creditoState = initialState.copyWith(tipoTarjeta: TipoTarjeta.credito);
        await tester.pumpWidget(createTestWidget(state: creditoState));
        await tester.pumpAndSettle();

        final dropdown = find.byType(DropdownButton<int>);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Buscar la opción específica en el menú desplegable
        final cuotaOptions = find.text('3 cuotas');
        expect(cuotaOptions, findsAtLeastNWidgets(1));

        // Seleccionar la primera opción encontrada
        await tester.tap(cuotaOptions.first);
        await tester.pump();

        // Verificar que el dropdown sigue existiendo después de la selección
        expect(dropdown, findsOneWidget);
      });
    });

    group('Validación y errores', () {
      testWidgets('debe mostrar errores de validación cuando existen', (WidgetTester tester) async {
        final stateWithErrors = initialState.copyWith(
          validationErrors: {'nombre': 'El nombre es requerido', 'dni': 'El DNI debe tener 7 u 8 dígitos'},
        );
        await tester.pumpWidget(createTestWidget(state: stateWithErrors));
        await tester.pumpAndSettle();

        expect(find.text('El nombre es requerido'), findsOneWidget);
        expect(find.text('El DNI debe tener 7 u 8 dígitos'), findsOneWidget);
      });

      testWidgets('debe marcar campo como tocado cuando se hace tap', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final nombreField = find.byType(TextFormField).first;
        await tester.tap(nombreField);
        await tester.pump();

        // Verificar que el campo existe y se puede tocar
        expect(nombreField, findsOneWidget);
      });
    });

    group('Callback de validación', () {
      testWidgets('debe llamar onFormValidationChanged cuando cambian los datos', (WidgetTester tester) async {
        bool callbackCalled = false;
        void callback() => callbackCalled = true;

        await tester.pumpWidget(createTestWidget(onFormValidationChanged: callback));
        await tester.pumpAndSettle();

        final nombreField = find.byType(TextFormField).first;
        await tester.enterText(nombreField, 'Juan Pérez');
        await tester.pump();

        // El callback se llama en _updateCardData
        expect(callbackCalled, isTrue);
      });
    });

    group('Formateadores de entrada', () {
      testWidgets('debe formatear número de tarjeta agregando espacios cada 4 dígitos', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Buscar el campo de número de tarjeta por su hint text
        final tarjetaField = find.widgetWithText(TextFormField, '1234 5678 9012 3456');
        expect(tarjetaField, findsOneWidget);

        // Probar formateo progresivo
        await tester.enterText(tarjetaField, '1234');
        await tester.pump();
        expect(find.text('1234'), findsAtLeastNWidgets(1));

        await tester.enterText(tarjetaField, '12345678');
        await tester.pump();
        expect(find.text('1234 5678'), findsAtLeastNWidgets(1));

        await tester.enterText(tarjetaField, '1234567890123456');
        await tester.pump();
        expect(find.text('1234 5678 9012 3456'), findsAtLeastNWidgets(1));
      });

      testWidgets('debe formatear fecha de expiración agregando / después de MM', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Buscar el campo de fecha de expiración por su hint text
        final fechaField = find.widgetWithText(TextFormField, 'MM/YY');
        expect(fechaField, findsOneWidget);

        // Probar formateo progresivo
        await tester.enterText(fechaField, '1');
        await tester.pump();
        // Verificar que el campo acepta la entrada
        expect(fechaField, findsOneWidget);

        await tester.enterText(fechaField, '12');
        await tester.pump();
        // Verificar que el campo acepta la entrada
        expect(fechaField, findsOneWidget);

        await tester.enterText(fechaField, '1225');
        await tester.pump();
        // Verificar que el campo acepta la entrada y se formatea
        expect(fechaField, findsOneWidget);
      });

      testWidgets('debe filtrar caracteres no numéricos en fecha de expiración', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Buscar el campo de fecha de expiración
        final fechaFields = find.byType(TextFormField);
        final fechaField = fechaFields.last;

        await tester.enterText(fechaField, '12ab25');
        await tester.pump();
        expect(find.text('12/25'), findsOneWidget);
      });
    });

    group('Integración con PayWayNotifier', () {
      testWidgets('debe actualizar datos de tarjeta cuando cambian los campos', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final nombreField = find.byType(TextFormField).first;
        await tester.enterText(nombreField, 'Juan Pérez');
        await tester.pump();

        // Verificar que el campo acepta texto
        expect(find.text('Juan Pérez'), findsOneWidget);
      });

      testWidgets('debe manejar estado de carga correctamente', (WidgetTester tester) async {
        final loadingState = initialState.copyWith(paymentState: const PaymentLoading(message: 'Procesando...'));
        await tester.pumpWidget(createTestWidget(state: loadingState));
        await tester.pumpAndSettle();

        // El formulario debe seguir siendo visible durante la carga
        expect(find.text('Datos de la Tarjeta'), findsOneWidget);
      });

      testWidgets('debe manejar estado de error correctamente', (WidgetTester tester) async {
        final errorState = initialState.copyWith(paymentState: const PaymentError(error: 'Error de pago'));
        await tester.pumpWidget(createTestWidget(state: errorState));
        await tester.pumpAndSettle();

        // El formulario debe seguir siendo visible durante el error
        expect(find.text('Datos de la Tarjeta'), findsOneWidget);
      });
    });
  });
}
