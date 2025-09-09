// Cambiar password screen
import 'package:cssayp_movil/auth/presentation/providers/cambiar_password_provider.dart';
import 'package:cssayp_movil/shared/exceptions/generic_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CambiarPasswordScreen extends ConsumerStatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  ConsumerState<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends ConsumerState<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordActualController = TextEditingController();
  final TextEditingController _passwordNuevaController = TextEditingController();
  final TextEditingController _passwordRepetirController = TextEditingController();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 4) {
      return 'La contraseña debe tener al menos 4 caracteres';
    }
    return null;
  }

  String? _validatePasswordRepetir(String? passwordRepetir) {
    final passwordNueva = _passwordNuevaController.text;
    final validPassword = _validatePassword(passwordNueva);

    if (validPassword != null) {
      return validPassword;
    }
    if (passwordNueva != passwordRepetir) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Escuchar el estado del password recovery provider
    ref.listen<AsyncValue<CambiarPasswordState>>(cambiarPasswordProvider, (previous, next) {
      next.when(
        data: (state) {
          if (state.isSuccess) {
            // Navegar automáticamente a la pantalla de password actualizada
            Navigator.pushReplacementNamed(context, '/password-actualizada');
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
        elevation: 0,
        title: const Text('Establecer nueva contraseña'),
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
                                  'Establecer nueva contraseña',
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
                                  'Cree una nueva contraseña para finalizar el proceso de recuperacón',
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
                            // Contraseña actual
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _passwordActualController,
                                    validator: _validatePassword,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelText: 'Contraseña actual',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Nueva contraseña
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _passwordNuevaController,
                                    validator: _validatePassword,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelText: 'Nueva contraseña',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Repetir contraseña
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _passwordRepetirController,
                                    validator: _validatePasswordRepetir,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelText: 'Repetir nueva contraseña',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Confirmar button
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        ref
                                            .read(cambiarPasswordProvider.notifier)
                                            .cambiarPassword(
                                              _passwordActualController.text,
                                              _passwordNuevaController.text,
                                            );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 4,
                                    ),
                                    child: Text(
                                      'Confirmar',
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
}
