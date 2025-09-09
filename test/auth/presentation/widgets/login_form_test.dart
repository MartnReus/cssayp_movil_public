import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/auth/presentation/widgets/login_form.dart';
import 'package:cssayp_movil/auth/presentation/providers/auth_provider.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import '../providers/auth_provider_test.mocks.dart';

class MockAuthNotifier extends AsyncNotifier<AuthState> with Mock implements AuthNotifier {
  @override
  Future<AuthState> build() async {
    return const AuthState(status: AuthStatus.autenticadoRequiereBiometria);
  }

  @override
  Future<void> login(String username, String password) async {
    // Mock implementation that doesn't do anything
    // In a real test, you might want to set different states here
  }

  @override
  Future<void> logout() async {
    // Mock implementation
  }
}

void main() {
  late MockUsuarioRepository mockUsuarioRepository;

  setUp(() {
    mockUsuarioRepository = MockUsuarioRepository();
  });

  group('LoginForm - Estructura', () {
    testWidgets('debe mostrar el texto definido en el widget sin botón biométrico', (tester) async {
      final container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
          authProvider.overrideWith(() => MockAuthNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(
                usernameController: TextEditingController(),
                passwordController: TextEditingController(),
                showBiometricButton: false,
                onBiometricTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Ingrese usuario y contraseña'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'INGRESAR'), findsOneWidget);
      expect(find.widgetWithText(TextButton, '¿Olvidó su contraseña?'), findsOneWidget);
      // Don't expect fingerprint icon when showBiometricButton is false
      expect(find.byIcon(Icons.fingerprint), findsNothing);
    });

    testWidgets('debe mostrar el botón biométrico cuando showBiometricButton es true', (tester) async {
      final container = ProviderContainer(
        overrides: [
          usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
          authProvider.overrideWith(() => MockAuthNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(
                usernameController: TextEditingController(),
                passwordController: TextEditingController(),
                showBiometricButton: true,
                onBiometricTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Ingrese usuario y contraseña'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'INGRESAR'), findsOneWidget);
      expect(find.widgetWithText(TextButton, '¿Olvidó su contraseña?'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });
  });

  group('LoginForm - Funcionalidad', () {
    testWidgets('debe mostrar errores de validación si los campos están vacíos', (tester) async {
      final usernameController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
            authProvider.overrideWith(() => MockAuthNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                showBiometricButton: false,
                onBiometricTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('El usuario es requerido'), findsOneWidget);
      expect(find.text('La contraseña es requerida'), findsOneWidget);
    });

    testWidgets('debe mostrar error de validación para usuario muy corto', (tester) async {
      final usernameController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
            authProvider.overrideWith(() => MockAuthNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                showBiometricButton: false,
                onBiometricTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'ab');
      await tester.enterText(find.byType(TextFormField).at(1), 'validpass');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('El usuario debe tener al menos 3 caracteres'), findsOneWidget);
      expect(find.text('La contraseña es requerida'), findsNothing);
      expect(find.text('La contraseña debe tener al menos 4 caracteres'), findsNothing);
    });

    testWidgets('debe mostrar error de validación para contraseña muy corta', (tester) async {
      final usernameController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
            authProvider.overrideWith(() => MockAuthNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                showBiometricButton: false,
                onBiometricTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'validuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'abc');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('La contraseña debe tener al menos 4 caracteres'), findsOneWidget);
      expect(find.text('El usuario es requerido'), findsNothing);
      expect(find.text('El usuario debe tener al menos 3 caracteres'), findsNothing);
    });

    testWidgets('no debe mostrar errores de validación con datos válidos', (tester) async {
      final usernameController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
            authProvider.overrideWith(() => MockAuthNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LoginForm(
                usernameController: usernameController,
                passwordController: passwordController,
                showBiometricButton: false,
                onBiometricTap: () {},
              ),
            ),
            routes: {'/home': (context) => const Scaffold(body: Center(child: Text('Home Screen')))},
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'validuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'validpass');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('El usuario es requerido'), findsNothing);
      expect(find.text('La contraseña es requerida'), findsNothing);
      expect(find.text('El usuario debe tener al menos 3 caracteres'), findsNothing);
      expect(find.text('La contraseña debe tener al menos 4 caracteres'), findsNothing);
    });

    testWidgets(
      'debe navegar a la pantalla de recuperación de contraseña cuando se presiona el botón de olvidó su contraseña',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              usuarioRepositoryProvider.overrideWith((ref) async => mockUsuarioRepository),
              authProvider.overrideWith(() => MockAuthNotifier()),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: LoginForm(
                  usernameController: TextEditingController(),
                  passwordController: TextEditingController(),
                  showBiometricButton: false,
                  onBiometricTap: () {},
                ),
              ),
              routes: {
                '/recuperar-password': (context) =>
                    const Scaffold(body: Center(child: Text('Recuperar Password Screen'))),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, '¿Olvidó su contraseña?'));
        await tester.pumpAndSettle();

        expect(find.text('Recuperar Password Screen'), findsOneWidget);
      },
    );
  });
}
