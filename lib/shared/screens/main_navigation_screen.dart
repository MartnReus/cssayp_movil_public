import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/presentation/screens/pagos_principal_screen.dart';
import 'package:cssayp_movil/shared/providers/navigation_provider.dart';
import 'package:cssayp_movil/shared/screens/proximamente_screen.dart';
import 'package:flutter/material.dart';
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final navigator = ref.watch(navigationProvider).navigatorState;
        if (navigator == null) return;

        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // Si no hay más rutas en el stack actual, volver al home
          if (currentIndex > 0) {
            ref.read(navigationProvider.notifier).selectTab(0);
          } else {
            // Si ya estamos en el home, cerrar la aplicación
            Navigator.of(context).pop();
          }
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
                icon: Icon(Icons.balance_outlined, color: Theme.of(context).colorScheme.secondary),
                selectedIcon: Icon(Icons.balance),
                label: 'Boletas',
              ),
              NavigationDestination(
                icon: Icon(Icons.payment_outlined, color: Theme.of(context).colorScheme.secondary),
                selectedIcon: Icon(Icons.payment),
                label: 'Pagos',
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
        return MaterialPageRoute(builder: (context) => _buildRouteForTab(index, settings));
      },
    );
  }

  Widget _buildRouteForTab(int index, RouteSettings settings) {
    final int currentIndex = ref.read(navigationProvider).index;
    if (currentIndex != index) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF173664))),
      );
    }

    switch (index) {
      case 0: // Home
        switch (settings.name) {
          default:
            return const HomeScreen();
        }
      case 1: // Historial Boletas
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
          default:
            return const HistorialScreen();
        }
      case 2: // Pagos
        switch (settings.name) {
          case '/procesar-pago':
            // Aquí se pasaría la lista de boletas seleccionadas
            return const PagosPrincipalScreen();
          default:
            return const PagosPrincipalScreen();
        }
      case 3: // Más
        return const ProximamenteScreen();
      default:
        return const HomeScreen();
    }
  }
}
