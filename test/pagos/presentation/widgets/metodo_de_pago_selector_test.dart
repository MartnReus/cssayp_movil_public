import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/pagos/presentation/widgets/metodo_de_pago_selector.dart';

void main() {
  group('MetodoDePagoSelector - Tests Básicos', () {
    testWidgets('debe poder instanciar el widget sin errores', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: true)),
          ),
        ),
      );

      // Verificar que el widget se puede instanciar
      expect(find.byType(MetodoDePagoSelector), findsOneWidget);
    });

    testWidgets('debe mostrar el título "Método de pago"', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: true)),
          ),
        ),
      );

      // Verificar que se muestra el título
      expect(find.text('Método de pago'), findsOneWidget);
    });

    testWidgets('debe mostrar métodos de pago para boletas de inicio cuando tieneBoletasInicio es true', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: false)),
          ),
        ),
      );

      expect(find.text('Red Link'), findsOneWidget);
    });

    testWidgets('debe mostrar métodos de pago para boletas de fin cuando tieneBoletasFin es true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: true)),
          ),
        ),
      );

      // Verificar que se muestran los métodos de pago para boletas de fin
      expect(find.text('Tarjeta de crédito/débito'), findsOneWidget);
    });

    testWidgets('no debe mostrar métodos cuando ambos flags son false', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: false)),
          ),
        ),
      );

      // Verificar que no se muestran métodos de pago
      expect(find.text('Red Link'), findsNothing);
      expect(find.text('Home Banking (Directo)'), findsNothing);
      expect(find.text('Home Banking'), findsNothing);
      expect(find.text('Tarjeta de crédito/débito'), findsNothing);
    });
  });

  group('MetodoDePagoSelector - Interacciones', () {
    testWidgets('debe permitir seleccionar un método de pago', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: true)),
          ),
        ),
      );

      // Buscar y tocar el radio button de Red Link
      final redLinkOption = find.widgetWithText(GestureDetector, 'Red Link');
      expect(redLinkOption, findsOneWidget);

      await tester.tap(redLinkOption);
      await tester.pump();

      // Verificar que el radio button está seleccionado
      final selected = find.widgetWithIcon(GestureDetector, Icons.check);
      expect(selected, findsOneWidget);
    });

    testWidgets('debe llamar onSelectionChanged cuando se selecciona un método', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MetodoDePagoSelector(
                tieneBoletasInicio: true,
                tieneBoletasFin: false,
                onSelectionChanged: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Buscar y tocar el radio button de Red Link
      final redLinkRadio = find.text('Red Link');
      await tester.tap(redLinkRadio);
      await tester.pump();

      // Verificar que se llamó el callback
      expect(callbackCalled, isTrue);
    });

    testWidgets('no debe llamar onSelectionChanged cuando es null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: false, onSelectionChanged: null),
            ),
          ),
        ),
      );

      final redLinkRadio = find.text('Red Link');
      await tester.tap(redLinkRadio);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('debe cambiar la selección al tocar otro método', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: true)),
          ),
        ),
      );

      // Seleccionar Red Link primero
      final redLinkRadio = find.text('Red Link');
      await tester.tap(redLinkRadio);
      await tester.pump();

      // Seleccionar Tarjeta después
      final tarjetaRadio = find.text('Tarjeta de crédito/débito');
      await tester.tap(tarjetaRadio);
      await tester.pump();

      // Verificar que el radio button está seleccionado
      final selected = find.widgetWithIcon(GestureDetector, Icons.check);
      expect(selected, findsOneWidget);
    });
  });

  group('MetodoDePagoSelector - Estilos y UI', () {
    testWidgets('debe mostrar iconos correctos para cada método', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: true)),
          ),
        ),
      );

      // Verificar que se muestran los iconos
      expect(find.widgetWithIcon(GestureDetector, Icons.account_balance), findsAny); // Red Link
      expect(find.widgetWithIcon(GestureDetector, Icons.credit_card), findsAny); // Tarjeta
    });

    testWidgets('debe mostrar cards con elevación correcta', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: true)),
          ),
        ),
      );

      // Verificar que las cards tienen la elevación correcta
      final cards = tester.widgetList<Card>(find.byType(Card));
      for (var card in cards) {
        expect(card.elevation, 2);
      }
    });

    testWidgets('debe mostrar check icon cuando un método está seleccionado', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: false)),
          ),
        ),
      );

      // Seleccionar Red Link
      final redLinkRadio = find.text('Red Link').first;
      await tester.tap(redLinkRadio);
      await tester.pump();

      // Verificar que se muestra el icono de check
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('MetodoDePagoSelector - Casos Edge', () {
    testWidgets('debe manejar selección rápida de múltiples métodos', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: true)),
          ),
        ),
      );

      // Seleccionar múltiples métodos rápidamente
      final redLinkRadio = find.text('Red Link').first;
      final tarjetaRadio = find.text('Tarjeta de crédito/débito').first;

      await tester.tap(redLinkRadio);
      await tester.pump();
      await tester.tap(tarjetaRadio);
      await tester.pump();

      // Verificar que el último método seleccionado está activo
      expect(find.widgetWithIcon(GestureDetector, Icons.check), findsOneWidget);
    });

    testWidgets('debe manejar callback múltiples veces', (tester) async {
      int callbackCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MetodoDePagoSelector(
                tieneBoletasInicio: false,
                tieneBoletasFin: true,
                onSelectionChanged: () {
                  callbackCount++;
                },
              ),
            ),
          ),
        ),
      );

      // Seleccionar múltiples métodos
      final redLinkRadio = find.text('Red Link');
      final tarjetaRadio = find.text('Tarjeta de crédito/débito');

      await tester.tap(redLinkRadio);
      await tester.pump();
      await tester.tap(tarjetaRadio);
      await tester.pump();

      // Verificar que se llamó el callback dos veces
      expect(callbackCount, equals(2));
    });

    testWidgets('debe mostrar correctamente cuando solo tiene boletas de inicio', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: true, tieneBoletasFin: false)),
          ),
        ),
      );

      // Verificar que solo se muestran métodos de inicio
      expect(find.text('Red Link'), findsOneWidget);
      expect(find.text('Tarjeta de crédito/débito'), findsNothing);
    });

    testWidgets('debe mostrar correctamente cuando solo tiene boletas de fin', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MetodoDePagoSelector(tieneBoletasInicio: false, tieneBoletasFin: true)),
          ),
        ),
      );

      // Verificar que solo se muestran métodos de fin
      expect(find.text('Red Link'), findsOneWidget);
      expect(find.text('Tarjeta de crédito/débito'), findsOneWidget);
    });
  });
}
