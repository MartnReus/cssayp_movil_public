import 'package:cssayp_movil/auth/presentation/providers/auth_provider.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';
import 'package:cssayp_movil/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginForm extends ConsumerStatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool showBiometricButton;
  final VoidCallback onBiometricTap;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.showBiometricButton,
    required this.onBiometricTap,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Validador para usuario
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El usuario es requerido';
    }
    if (value.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null;
  }

  // Validador para contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 4) {
      return 'La contraseña debe tener al menos 4 caracteres';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Titulo y descripcion
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Iniciar Sesión',
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
                  'Ingrese usuario y contraseña',
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

            // Campos
            Column(
              children: [
                // Usuario
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: TextFormField(
                    controller: widget.usernameController,
                    enabled: !isLoading,
                    validator: _validateUsername,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
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
                      labelText: 'Usuario',
                      labelStyle: TextStyle(
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

                // Contraseña
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: TextFormField(
                    controller: widget.passwordController,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
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
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                      ),
                      errorStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de login y biometria
                Row(
                  children: [
                    // Botón de login
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final oldState = ref.read(authProvider);
                                    await ref
                                        .read(authProvider.notifier)
                                        .login(widget.usernameController.text, widget.passwordController.text);
                                    final nuevoEstado = ref.read(authProvider);
                                    if (context.mounted &&
                                        oldState.value?.status == AuthStatus.autenticadoRequiereBiometria &&
                                        nuevoEstado.value?.status == AuthStatus.autenticadoRequiereBiometria) {
                                      Navigator.pushNamed(context, '/home');
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? const LoadingIndicator()
                              : Text(
                                  'INGRESAR',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    height: 1.83,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Botón de biometria
                    if (widget.showBiometricButton) const SizedBox(width: 12),
                    if (widget.showBiometricButton)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: isLoading
                              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
                              : Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          shadows: const [
                            BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4), spreadRadius: 0),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isLoading ? null : widget.onBiometricTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Icon(Icons.fingerprint, color: Theme.of(context).colorScheme.onPrimary, size: 28),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Forgot password link
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/recuperar-password');
                        },
                  child: Text(
                    '¿Olvidó su contraseña?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isLoading
                          ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.83,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
