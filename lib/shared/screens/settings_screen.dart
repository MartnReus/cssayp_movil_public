import 'package:cssayp_movil/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2), spreadRadius: 0),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Seguridad',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4D4D4D),
                    ),
                  ),
                  leading: const Icon(Icons.security, color: Color(0xFF4D4D4D)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(
                    'Usar biometría para iniciar sesión',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4D4D4D),
                    ),
                  ),
                  subtitle: const Text(
                    'Activa la autenticación biométrica para incrementar la seguridad de tu cuenta',
                    style: TextStyle(fontSize: 12, fontFamily: 'Inter', color: Color(0xFF828282)),
                  ),
                  value: utilizarBiometriaLogin,
                  onChanged: (value) {
                    ref.read(authProvider.notifier).actualizarPreferenciaBiometria(value);
                    ref.read(authProvider.notifier).getBiometriaHabilitada().then((value) {
                      setState(() {
                        utilizarBiometriaLogin = value;
                      });
                    });
                  },
                  secondary: const Icon(Icons.fingerprint, color: Color(0xFF4D4D4D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
