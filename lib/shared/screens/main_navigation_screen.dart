import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/notificaciones/notificaciones.dart';
import 'package:cssayp_movil/pagos/presentation/screens/pagos_principal_screen.dart';
import 'package:cssayp_movil/pagos/presentation/screens/procesar_pago_screen.dart';
import 'package:cssayp_movil/shared/providers/navigation_provider.dart';
import 'package:cssayp_movil/shared/screens/mas_screen.dart';
import 'package:cssayp_movil/shared/screens/proximamente_screen.dart';
import 'package:cssayp_movil/shared/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider).index;
    final currentRouteName = ref.watch(navigationProvider).routeName;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final navigator = ref.watch(navigationProvider).navigatorState;
        if (navigator == null) {
          SystemNavigator.pop();
          return;
        }

        if (navigator.canPop()) {
          if (currentRouteName != null && currentRouteName != '/') {
            navigator.pop();
          }

          if (currentRouteName == '/' && currentIndex > 0) {
            ref.read(navigationProvider.notifier).selectTab(0);
          }

          if (currentRouteName == '/' && currentIndex == 0) {
            // Si ya estamos en el home y en la ruta inicial, cerrar la aplicación
            SystemNavigator.pop();
          }
        } else {
          // Si ya estamos en el home y en la ruta inicial, cerrar la aplicación
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [_buildNavigator(0), _buildNavigator(1), _buildNavigator(2), _buildNavigator(3)],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              final currentIndex = ref.read(navigationProvider).index;
              final routeName = currentIndex != index ? ref.read(navigationProvider).routeName : '/';
              ref.read(navigationProvider.notifier).selectTab(index, routeName: routeName ?? '/');
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.secondary),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.work_outline, color: Theme.of(context).colorScheme.secondary),
                selectedIcon: Icon(Icons.work),
                label: 'Vida Activa',
              ),
              NavigationDestination(
                icon: Icon(Icons.balance_outlined, color: Theme.of(context).colorScheme.secondary),
                selectedIcon: Icon(Icons.balance),
                label: 'Boletas',
              ),
              NavigationDestination(
                icon: Icon(Icons.density_medium_outlined, color: Theme.of(context).colorScheme.secondary),
                selectedIcon: Icon(Icons.density_medium),
                label: 'Más',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigator(int index) {
    final navigationKeys = ref.read(navigationProvider).navigationKeys;
    return Navigator(
      key: navigationKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => _buildRouteForTab(index, settings),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }

  Widget _buildRouteForTab(int index, RouteSettings settings) {
    switch (index) {
      case 0: // Inicio
        switch (settings.name) {
          case '/notificaciones':
            return const NotificacionesScreen();
          default:
            return const HomeScreen();
        }
      case 1: // Vida Activa
        return const ProximamenteScreen();
      case 2: // Boletas
        switch (settings.name) {
          case '/crear-boleta':
            return const CrearBoletaScreen();
          case '/boleta-generada':
            final args = settings.arguments as BoletaEntity?;
            return BoletaCreadaScreen(boleta: args);
          case '/boleta-inicio-paso1':
            return const Paso1BoletaInicioScreen();
          case '/boleta-inicio-paso2':
            return const Paso2BoletaInicioScreen();
          case '/boleta-inicio-paso3':
            return const Paso3BoletaInicioScreen();
          case '/boleta-fin-paso1':
            return const Paso1BoletaFinScreen();
          case '/boleta-fin-paso2':
            return const Paso2BoletaFinScreen();
          case '/boleta-fin-paso3':
            return const Paso3BoletaFinScreen();
          case '/ver-comprobante-inicio':
            final args = settings.arguments as ComprobanteEntity?;
            if (args == null) {
              return const HistorialScreen();
            }
            return ComprobanteInicioScreen(comprobante: args);
          case '/ver-comprobante-fin':
            final args = settings.arguments as ComprobanteEntity?;
            if (args == null) {
              return const HistorialScreen();
            }
            return ComprobanteFinScreen(comprobante: args);
          default:
            return const HistorialScreen();
        }
      case 3: // Más
        switch (settings.name) {
          case '/pagos':
            return const PagosPrincipalScreen();
          case '/procesar-pago':
            final boletas = settings.arguments as List<BoletaEntity>?;
            if (boletas != null) {
              return ProcesarPagoScreen(boletas: boletas);
            }
            return const PagosPrincipalScreen();
          case '/settings':
            return const SettingsScreen();
          default:
            if (settings.name != '/') {
              return ProximamenteScreen();
            }
            return MasScreen();
        }
      default:
        return const HomeScreen();
    }
  }
}
