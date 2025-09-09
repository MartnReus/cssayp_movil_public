import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/presentation/screens/historial_screen.dart';
import 'package:cssayp_movil/boletas/presentation/screens/boleta_generada.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_screen.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_inicio_pasos/boleta_inicio_paso1.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_inicio_pasos/boleta_inicio_paso2.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_inicio_pasos/boleta_inicio_paso3.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_fin_pasos/boleta_fin_paso1.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_fin_pasos/boleta_fin_paso2.dart';
import 'package:cssayp_movil/boletas/presentation/screens/crear_boleta_fin_pasos/boleta_fin_paso3.dart';
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
  final List<GlobalKey<NavigatorState>> _navigationKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigator = _navigationKeys[currentIndex].currentState;

        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          // Si no hay mas rutas en el stack actual, volver al home
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
              ref.read(navigationProvider.notifier).selectTab(index);
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
    return Navigator(
      key: _navigationKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (context) => _buildRouteForTab(index, settings));
      },
    );
  }

  Widget _buildRouteForTab(int index, RouteSettings settings) {
    switch (index) {
      case 0: // Home
        switch (settings.name) {
          case '/crear-boleta':
            return const CrearBoletaScreen();
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
          case '/boleta-generada':
            return const BoletaCreadaScreen();
          default:
            return const HomeScreen();
        }
      case 1: // Historial Boletas
        switch (settings.name) {
          case '/boleta-generada':
            return const BoletaCreadaScreen();
          default:
            return const HistorialScreen();
        }
      case 2: // Pagos
      case 3: // Más
        return const ProximamenteScreen();
      default:
        return const HomeScreen();
    }
  }
}
