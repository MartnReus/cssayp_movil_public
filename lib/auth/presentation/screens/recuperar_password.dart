// recuperar password screen
import 'package:cssayp_movil/shared/exceptions/generic_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/auth/presentation/providers/password_recovery_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecuperarPasswordScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<RecuperarPasswordScreen> createState() => _RecuperarScreenState();

  const RecuperarPasswordScreen({super.key});
}

class _RecuperarScreenState extends ConsumerState<RecuperarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final dniOrNroAfiliadoController = TextEditingController();
  final emailController = TextEditingController();

  String? _validateNroAfiliadoOrDni(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI o número de afiliado es requerido';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Solo se permiten números';
    }
    if (value.length > 8) {
      return 'El número de documento debe tener máximo 8 dígitos';
    }
    if (value.length > 5 && value.length < 7) {
      return 'El número de afiliado debe tener máximo 5 dígitos';
    }
    return null;
  }

  // Validador para email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback: show a snackbar with the email address
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el cliente de correo. Email: $email'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    ref.listen<AsyncValue<PasswordRecoveryState>>(passwordRecoveryProvider, (previous, next) {
      next.when(
        data: (state) {
          if (state.isSuccess) {
            Navigator.pushReplacementNamed(context, '/enviar-email');
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          String errorMessage = (error as GenericException).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Center(
                child: Text(errorMessage, style: const TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    // Form section
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Recuperación de Contraseña',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 18,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    height: 1.33,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Al completar los datos le enviaremos un correo electrónico con una contraseña temporal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    height: 1.29,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Form fields
                            Column(
                              children: [
                                // DNI o Nro de Afiliado field
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: dniOrNroAfiliadoController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(8),
                                    ],
                                    validator: _validateNroAfiliadoOrDni,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText: 'DNI o Nro de Afiliado',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                      errorStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Email field
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText: 'Correo Electrónico',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                      errorStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Confirmar button
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final passwordRecoveryState = ref.watch(passwordRecoveryProvider);
                                      final isLoading = passwordRecoveryState.isLoading;

                                      return ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                if (_formKey.currentState!.validate()) {
                                                  ref
                                                      .read(passwordRecoveryProvider.notifier)
                                                      .recuperarPassword(
                                                        dniOrNroAfiliadoController.text,
                                                        emailController.text,
                                                      );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 4,
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context).colorScheme.onPrimary,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                'Confirmar',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                  fontSize: 12,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.83,
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Si tiene problemas para recuperar su contraseña puede comunicarse con Mesa de Entradas a través de los correos:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    height: 1.29,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _launchEmail('mesa.sfe@capsantafe.org.ar'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'mesa.sfe@capsantafe.org.ar',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 13,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              height: 1.29,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _launchEmail('mesadeentradasrosario@capsantafe.org.ar'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'mesadeentradasrosario@capsantafe.org.ar',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 13,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              height: 1.29,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dniOrNroAfiliadoController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
