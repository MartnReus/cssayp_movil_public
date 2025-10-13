import 'package:cssayp_movil/auth/presentation/providers/auth_provider.dart';
import 'package:cssayp_movil/shared/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool utilizarBiometriaLogin = false;

  @override
  void initState() {
    super.initState();
    ref.read(authProvider.notifier).getBiometriaHabilitada().then((value) {
      setState(() {
        utilizarBiometriaLogin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFE6E1D3),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.density_medium, color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                'CSSAyP Móvil',
                style: TextStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                _showLogoutDialog(context, ref);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SafeArea(
          child: authState.when(
            data: (authState) => _buildHomeContent(context, authState, screenSize),
            loading: () => const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4D4D4D))),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFF4D4D4D)),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar información',
                    style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(authProvider.notifier).refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, AuthState authState, Size screenSize) {
    final usuario = authState.usuario;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Welcome section with logo
            Container(
              width: screenSize.width * 0.4,
              height: screenSize.width * 0.4,
              constraints: const BoxConstraints(maxWidth: 160, maxHeight: 160),
              decoration: ShapeDecoration(
                image: const DecorationImage(image: AssetImage("assets/images/LogoCaja.png"), fit: BoxFit.cover),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(color: Color(0x26000000), blurRadius: 15, offset: Offset(0, 0), spreadRadius: 0),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Welcome message
            Text(
              '¡Bienvenido!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4D4D4D),
                fontSize: 24,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Switch(
              value: utilizarBiometriaLogin,
              onChanged: (value) {
                ref.read(authProvider.notifier).actualizarPreferenciaBiometria(value);
                ref.read(authProvider.notifier).getBiometriaHabilitada().then((value) {
                  setState(() {
                    utilizarBiometriaLogin = value;
                  });
                });
              },
            ),

            const SizedBox(height: 8),

            if (usuario != null) ...[
              Text(
                usuario.apellidoNombres,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // User info card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2), spreadRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Información Personal',
                          style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Número de Afiliado', usuario.nroAfiliado.toString()),
                    const SizedBox(height: 12),
                    _buildInfoRow('Nombre Completo', usuario.apellidoNombres),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick actions section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2), spreadRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dashboard, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Acciones Rápidas',
                          style: TextStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.post_add,
                            label: 'Nueva boleta',
                            onPressed: () {
                              ref.read(navigationProvider.notifier).selectTab(1, routeName: '/crear-boleta');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.payment,
                            label: 'Pagos',
                            onPressed: () {
                              ref.read(navigationProvider.notifier).selectTab(2);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.history,
                            label: 'Boletas',
                            onPressed: () {
                              Navigator.pushNamed(context, '/historial-boletas');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.settings,
                            label: 'Configuración',
                            onPressed: () {
                              _showComingSoonDialog(context, 'Configuración');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(color: Color(0xFF828282), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Color(0xFF4D4D4D), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Color(0xFF4D4D4D), fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '¿Está seguro que desea cerrar sesión?',
          style: TextStyle(color: Color(0xFF4D4D4D), fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF828282))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              // Navigate to login screen after logout
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D4D4D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          feature,
          style: TextStyle(color: Color(0xFF4D4D4D), fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.',
          style: TextStyle(color: Color(0xFF4D4D4D), fontFamily: 'Inter'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D4D4D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
