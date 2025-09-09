import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      if (next.hasValue && next.value?.status == AuthStatus.autenticadoNoRequiereBiometria) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (next.hasValue && next.value?.status == AuthStatus.autenticadoRequiereBiometria) {
        Navigator.of(context).pushReplacementNamed('/login', arguments: LoginScreenArguments(showBiometricLogin: true));
      } else if (next.hasValue && next.value?.status == AuthStatus.noAutenticado) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
