import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:cssayp_movil/boletas/presentation/widgets/historial_boletas.dart';

void main() {
  setUpAll(() async {
    // Inicializar localización para evitar errores con DateFormat
    await initializeDateFormatting('es_AR', null);
  });

  group('HistorialBoletasWidget - Tests Básicos', () {
    testWidgets('debe poder instanciar el widget sin errores', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      // Verificar que el widget se puede instanciar
      expect(find.byType(HistorialBoletasWidget), findsOneWidget);
    });

    testWidgets('debe mostrar el estado de carga inicialmente', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      await tester.pump();

      // Verificar que se muestra el indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando boletas...'), findsOneWidget);

      // Verificar que NO están presentes elementos del estado con datos
      expect(find.text('Filtrar por carátula'), findsNothing);
      expect(find.text('No se encontraron boletas'), findsNothing);
    });

    testWidgets('debe tener el color de fondo correcto', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      await tester.pump();

      // Verificar que el Scaffold tiene el color de fondo correcto
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);

      final scaffolds = tester.widgetList<Scaffold>(scaffoldFinder);
      final hasCorrectColor = scaffolds.any((scaffold) => scaffold.backgroundColor == const Color(0xFFEEF9FF));
      expect(hasCorrectColor, isTrue);
    });

    testWidgets('debe contener un ListView en estado de carga', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      await tester.pump();

      // En estado de carga, no hay ListView, solo CircularProgressIndicator
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('debe ser un ConsumerStatefulWidget', () {
      expect(HistorialBoletasWidget(), isA<ConsumerStatefulWidget>());
    });

    test('debe tener un key opcional', () {
      const widget = HistorialBoletasWidget();
      expect(widget.key, isNull);
    });

    test('debe poder crear con key personalizado', () {
      const key = Key('test_key');
      const widget = HistorialBoletasWidget(key: key);
      expect(widget.key, key);
    });
  });

  group('HistorialBoletasWidget - Tests de Propiedades Visuales', () {
    testWidgets('debe mostrar el indicador de carga con el color correcto', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      await tester.pump();

      // Verificar que el CircularProgressIndicator tiene el color correcto
      final progressIndicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(progressIndicator.valueColor?.value, const Color(0xFF173664));
    });

    testWidgets('debe mostrar el texto de carga con la fuente correcta', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      await tester.pump();

      // Verificar que el texto de carga tiene las propiedades correctas
      final textWidget = tester.widget<Text>(find.text('Cargando boletas...'));
      expect(textWidget.style?.fontFamily, 'Montserrat');
      expect(textWidget.style?.fontSize, 16);
      expect(textWidget.style?.color, const Color(0xFF173664));
    });
  });

  group('HistorialBoletasWidget - Tests de Comportamiento', () {
    testWidgets('debe inicializar correctamente sin errores', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      // Verificar que no hay excepciones durante la inicialización
      expect(tester.takeException(), isNull);

      await tester.pump();

      // Verificar que después del pump tampoco hay errores
      expect(tester.takeException(), isNull);
    });

    testWidgets('debe poder reconstruirse sin problemas', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: HistorialBoletasWidget())),
        ),
      );

      await tester.pump();

      // Forzar una reconstrucción
      await tester.pump();

      // Verificar que no hay errores después de la reconstrucción
      expect(tester.takeException(), isNull);
      expect(find.byType(HistorialBoletasWidget), findsOneWidget);
    });
  });
}
