import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cssayp_movil/shared/providers/connectivity_provider.dart';
import 'package:cssayp_movil/shared/widgets/offline_notification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Estilos del sistema operativo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFE6E1D3),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityProvider);
    final isOffline = connectivityStatus.value == ConnectivityStatus.offline;

    return MaterialApp(
      title: 'CSSAyP',
      theme: theme,
      home: const SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'AR'), Locale('en', 'US')],
      routes: {
        '/login': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as LoginScreenArguments?;
          return LoginScreen(arguments: args ?? LoginScreenArguments(showBiometricLogin: false));
        },
        '/home': (context) => MainNavigationScreen(),
        '/recuperar-password': (context) => RecuperarPasswordScreen(),
        '/cambiar-password': (context) => CambiarPasswordScreen(),
        '/enviar-email': (context) => EnvioEmailScreen(),
        '/password-actualizada': (context) => PasswordActualizadaScreen(),
        '/boleta-generada': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as BoletaEntity?;
          return BoletaCreadaScreen(boleta: args);
        },
        '/historial_boletas_juicios': (context) => HistorialScreen(),
      },
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: isOffline ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (isOffline) const OfflineNotification(),
                Expanded(child: child!),
              ],
            ),
          ),
        );
      },
    );
  }
}

final colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xFF173664),
  onPrimary: Colors.white,
  secondary: const Color(0xFF194B8F),
  onSecondary: Colors.white,
  tertiary: const Color(0xFF194B8F),
  onTertiary: Colors.white,
  error: const Color(0xFFD54654),
  onError: Colors.white,
  surface: const Color(0xFFEEF9FF),
  onSurface: const Color(0xFF173664),
  outline: const Color(0xFF194B8F),
  outlineVariant: const Color(0xFF194B8F),
  surfaceContainerHigh: Colors.white,
  onSurfaceVariant: const Color(0xFF173664),
);

// Documentación de los roles de los colores:
// https://m3.material.io/styles/color/roles
final ThemeData theme = ThemeData(
  colorScheme: colorScheme,
  useMaterial3: true,
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    labelTextStyle: WidgetStateProperty.all(TextStyle(color: colorScheme.secondary)),
    surfaceTintColor: colorScheme.surface,
    shadowColor: Colors.black,
  ),
);
