// login screen
import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreenArguments {
  final bool showBiometricLogin;

  LoginScreenArguments({required this.showBiometricLogin});
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.arguments});
  final LoginScreenArguments arguments;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool showBiometricButton = false;
  bool showBiometricLoginSection = false;

  @override
  void initState() {
    super.initState();
    showBiometricButton = widget.arguments.showBiometricLogin;
    showBiometricLoginSection = widget.arguments.showBiometricLogin;

    // Llamar a la autenticacion biometrica despues de que se haya construido el widget
    if (showBiometricButton) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkBiometric();
      });
    }
  }

  Future<void> _checkBiometric() async {
    if (showBiometricButton) {
      final biometricAuth = ref.read(biometricAuthServiceProvider);
      final result = await biometricAuth.autenticar();
      if (result == BiometricAuthResult.success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        if (previous?.error != next.error) {
          String errorMessage;

          if (next.error is AuthException) {
            errorMessage = (next.error as AuthException).message;
          } else {
            errorMessage = next.error.toString();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Center(
                child: Text(errorMessage, style: const TextStyle(color: Colors.white)),
              ),
            ),
          );
        }
      }

      if (next.hasValue && next.value?.status == AuthStatus.autenticadoNoRequiereBiometria) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (next.value?.usuario?.cambiarPassword == true) {
            Navigator.of(context).pushReplacementNamed('/cambiar-password');
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      } else if (next.hasValue && next.value?.status == AuthStatus.autenticadoRequiereBiometria) {
        usernameController.text = next.value?.usuario?.username ?? '';
      }
    });

    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          elevation: 0,
          title: const Text('Inicio de sesión'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo de la Caja
                      Container(
                        width: screenSize.width * 0.6, // 60% of screen width
                        height: screenSize.width * 0.6, // Keep it square
                        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
                        decoration: ShapeDecoration(
                          image: const DecorationImage(
                            image: AssetImage("assets/images/LogoCaja.png"),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 3, color: Theme.of(context).colorScheme.surfaceContainerHigh),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Formulario de login
                      if (!showBiometricLoginSection)
                        LoginForm(
                          usernameController: usernameController,
                          passwordController: passwordController,
                          showBiometricButton: showBiometricButton,
                          onBiometricTap: () {
                            setState(() {
                              showBiometricLoginSection = true;
                            });
                            _checkBiometric();
                          },
                        ),

                      // Seccion de biometria
                      if (showBiometricButton && showBiometricLoginSection)
                        LoginBiometric(
                          onUseCredentials: () {
                            setState(() {
                              showBiometricLoginSection = false;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
