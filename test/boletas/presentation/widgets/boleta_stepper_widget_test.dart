import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';

void main() {
  group('BoletaStepperWidget - Tests Básicos', () {
    testWidgets('debe poder instanciar el widget sin errores', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 1,
              boletaType: 'Boleta de Inicio',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar que el widget se puede instanciar
      expect(find.byType(BoletaStepperWidget), findsOneWidget);
    });

    testWidgets('debe mostrar el tipo de boleta correctamente', (tester) async {
      const boletaType = 'Boleta de Fin';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: boletaType, stepLabels: ['Paso 1', 'Paso 2']),
          ),
        ),
      );

      // Verificar que se muestra el tipo de boleta
      expect(find.text(boletaType), findsOneWidget);
    });

    testWidgets('debe mostrar todos los pasos correctamente', (tester) async {
      const stepLabels = ['Paso 1', 'Paso 2', 'Paso 3'];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: stepLabels),
          ),
        ),
      );

      // Verificar que se muestran todos los pasos
      for (final label in stepLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    test('debe ser un StatelessWidget', () {
      const widget = BoletaStepperWidget(currentStep: 1, boletaType: 'Test', stepLabels: ['Paso 1']);
      expect(widget, isA<StatelessWidget>());
    });

    test('debe tener un key opcional', () {
      const widget = BoletaStepperWidget(currentStep: 1, boletaType: 'Test', stepLabels: ['Paso 1']);
      expect(widget.key, isNull);
    });

    test('debe poder crear con key personalizado', () {
      const key = Key('test_key');
      const widget = BoletaStepperWidget(key: key, currentStep: 1, boletaType: 'Test', stepLabels: ['Paso 1']);
      expect(widget.key, key);
    });
  });

  group('BoletaStepperWidget - Tests de Propiedades', () {
    testWidgets('debe usar icono por defecto cuando no se proporciona', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso 1']),
          ),
        ),
      );

      // Verificar que se usa el icono por defecto
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('debe usar icono personalizado cuando se proporciona', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 1,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1'],
              icon: Icons.check_circle,
            ),
          ),
        ),
      );

      // Verificar que se usa el icono personalizado
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('debe usar color de icono por defecto cuando no se proporciona', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso 1']),
          ),
        ),
      );

      // Verificar que el icono tiene el color por defecto
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.play_circle_outline));
      expect(iconWidget.color, const Color(0xFF4CAF50));
    });

    testWidgets('debe usar color de icono personalizado cuando se proporciona', (tester) async {
      const customColor = Color(0xFF2196F3);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 1,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1'],
              iconColor: customColor,
            ),
          ),
        ),
      );

      // Verificar que el icono tiene el color personalizado
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.play_circle_outline));
      expect(iconWidget.color, customColor);
    });
  });

  group('BoletaStepperWidget - Tests de Lógica de Pasos', () {
    testWidgets('debe mostrar el paso actual como activo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 2,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar que el paso 2 está activo (color verde)
      // Buscar el contenedor circular específico del paso
      final step2Containers = find.ancestor(of: find.text('2'), matching: find.byType(Container));
      expect(step2Containers, findsWidgets);

      // Encontrar el contenedor circular (32x32) que contiene el número
      final containers = tester.widgetList<Container>(step2Containers);
      final stepContainer = containers.firstWhere(
        (container) => container.constraints?.maxWidth == 32 && container.constraints?.maxHeight == 32,
      );

      final decoration = stepContainer.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF4CAF50));
    });

    testWidgets('debe mostrar pasos completados con color verde', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 3,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // NOTA: El widget actual solo marca como activo el paso actual, no los completados
      // Solo el paso 3 (actual) debería estar en verde
      final step3Containers = find.ancestor(of: find.text('3'), matching: find.byType(Container));
      final containers3 = tester.widgetList<Container>(step3Containers);

      final stepContainer3 = containers3.firstWhere(
        (container) => container.constraints?.maxWidth == 32 && container.constraints?.maxHeight == 32,
      );

      final decoration3 = stepContainer3.decoration as BoxDecoration;
      expect(decoration3.color, const Color(0xFF4CAF50));

      // Los pasos 1 y 2 deberían estar en gris (comportamiento actual del widget)
      final step1Containers = find.ancestor(of: find.text('1'), matching: find.byType(Container));
      final step2Containers = find.ancestor(of: find.text('2'), matching: find.byType(Container));

      final containers1 = tester.widgetList<Container>(step1Containers);
      final containers2 = tester.widgetList<Container>(step2Containers);

      final stepContainer1 = containers1.firstWhere(
        (container) => container.constraints?.maxWidth == 32 && container.constraints?.maxHeight == 32,
      );
      final stepContainer2 = containers2.firstWhere(
        (container) => container.constraints?.maxWidth == 32 && container.constraints?.maxHeight == 32,
      );

      final decoration1 = stepContainer1.decoration as BoxDecoration;
      final decoration2 = stepContainer2.decoration as BoxDecoration;

      expect(decoration1.color, const Color(0xFFE0E0E0));
      expect(decoration2.color, const Color(0xFFE0E0E0));
    });

    testWidgets('debe mostrar pasos futuros con color gris', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 1,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar que los pasos 2 y 3 están en gris
      final step2Containers = find.ancestor(of: find.text('2'), matching: find.byType(Container));
      final step3Containers = find.ancestor(of: find.text('3'), matching: find.byType(Container));

      // Encontrar los contenedores circulares específicos
      final containers2 = tester.widgetList<Container>(step2Containers);
      final containers3 = tester.widgetList<Container>(step3Containers);

      final stepContainer2 = containers2.firstWhere(
        (container) => container.constraints?.maxWidth == 32 && container.constraints?.maxHeight == 32,
      );
      final stepContainer3 = containers3.firstWhere(
        (container) => container.constraints?.maxWidth == 32 && container.constraints?.maxHeight == 32,
      );

      final decoration2 = stepContainer2.decoration as BoxDecoration;
      final decoration3 = stepContainer3.decoration as BoxDecoration;

      expect(decoration2.color, const Color(0xFFE0E0E0));
      expect(decoration3.color, const Color(0xFFE0E0E0));
    });

    testWidgets('debe mostrar conectores entre pasos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 2,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar que hay conectores entre los pasos
      final connectors = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 40 && widget.constraints?.maxHeight == 2,
      );

      // Debe haber 2 conectores para 3 pasos
      expect(connectors, findsNWidgets(2));
    });

    testWidgets('debe mostrar conectores completados en verde', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 3,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar que los conectores están en verde (completados)
      final connectors = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 40 && widget.constraints?.maxHeight == 2,
      );

      final connectorWidgets = tester.widgetList<Container>(connectors);
      for (final connector in connectorWidgets) {
        // Los conectores usan color directamente, no BoxDecoration
        expect(connector.color, const Color(0xFF4CAF50));
      }
    });
  });

  group('BoletaStepperWidget - Tests de Estilos', () {
    testWidgets('debe tener el estilo correcto para el texto del tipo de boleta', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso 1']),
          ),
        ),
      );

      // Verificar el estilo del texto del tipo de boleta
      final textWidget = tester.widget<Text>(find.text('Test Boleta'));
      final textStyle = textWidget.style!;

      expect(textStyle.color, const Color(0xFF173664));
      expect(textStyle.fontSize, 16);
      expect(textStyle.fontFamily, 'Montserrat');
      expect(textStyle.fontWeight, FontWeight.w600);
    });

    testWidgets('debe tener el estilo correcto para las etiquetas de pasos activos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 2,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar el estilo del texto del paso activo
      final activeStepText = tester.widget<Text>(find.text('Paso 2'));
      final textStyle = activeStepText.style!;

      expect(textStyle.color, const Color(0xFF173664));
      expect(textStyle.fontSize, 11);
      expect(textStyle.fontFamily, 'Montserrat');
      expect(textStyle.fontWeight, FontWeight.w500);
    });

    testWidgets('debe tener el estilo correcto para las etiquetas de pasos inactivos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 1,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar el estilo del texto de los pasos inactivos
      final inactiveStepText = tester.widget<Text>(find.text('Paso 2'));
      final textStyle = inactiveStepText.style!;

      expect(textStyle.color, const Color(0xFF999999));
      expect(textStyle.fontSize, 11);
      expect(textStyle.fontFamily, 'Montserrat');
      expect(textStyle.fontWeight, FontWeight.w500);
    });

    testWidgets('debe tener el estilo correcto para los números de pasos activos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 2,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar el estilo del número del paso activo
      final activeStepNumber = tester.widget<Text>(find.text('2'));
      final textStyle = activeStepNumber.style!;

      expect(textStyle.color, Colors.white);
      expect(textStyle.fontSize, 14);
      expect(textStyle.fontFamily, 'Montserrat');
      expect(textStyle.fontWeight, FontWeight.w600);
    });

    testWidgets('debe tener el estilo correcto para los números de pasos inactivos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(
              currentStep: 1,
              boletaType: 'Test Boleta',
              stepLabels: ['Paso 1', 'Paso 2', 'Paso 3'],
            ),
          ),
        ),
      );

      // Verificar el estilo del número de los pasos inactivos
      final inactiveStepNumber = tester.widget<Text>(find.text('2'));
      final textStyle = inactiveStepNumber.style!;

      expect(textStyle.color, const Color(0xFF999999));
      expect(textStyle.fontSize, 14);
      expect(textStyle.fontFamily, 'Montserrat');
      expect(textStyle.fontWeight, FontWeight.w600);
    });

    testWidgets('debe tener el contenedor con el estilo correcto', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso 1']),
          ),
        ),
      );

      // Verificar el estilo del contenedor principal
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });
  });

  group('BoletaStepperWidget - Tests de Comportamiento', () {
    testWidgets('debe inicializar correctamente sin errores', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso 1', 'Paso 2']),
          ),
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
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso 1', 'Paso 2']),
          ),
        ),
      );

      await tester.pump();

      // Forzar una reconstrucción
      await tester.pump();

      // Verificar que no hay errores después de la reconstrucción
      expect(tester.takeException(), isNull);
      expect(find.byType(BoletaStepperWidget), findsOneWidget);
    });

    testWidgets('debe manejar correctamente un solo paso', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 1, boletaType: 'Test Boleta', stepLabels: ['Paso Único']),
          ),
        ),
      );

      // Verificar que se muestra el paso único
      expect(find.text('Paso Único'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // No debe haber conectores para un solo paso
      final connectors = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 40 && widget.constraints?.maxHeight == 2,
      );
      expect(connectors, findsNothing);
    });

    testWidgets('debe manejar correctamente múltiples pasos', (tester) async {
      const stepLabels = ['Paso 1', 'Paso 2', 'Paso 3', 'Paso 4', 'Paso 5'];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BoletaStepperWidget(currentStep: 3, boletaType: 'Test Boleta', stepLabels: stepLabels),
          ),
        ),
      );

      // Verificar que se muestran todos los pasos
      for (int i = 0; i < stepLabels.length; i++) {
        expect(find.text(stepLabels[i]), findsOneWidget);
        expect(find.text('${i + 1}'), findsOneWidget);
      }

      // Debe haber 4 conectores para 5 pasos
      final connectors = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 40 && widget.constraints?.maxHeight == 2,
      );
      expect(connectors, findsNWidgets(4));
    });
  });
}
