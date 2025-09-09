import 'package:flutter/material.dart';

class LoginBiometric extends StatelessWidget {
  final VoidCallback onUseCredentials;

  const LoginBiometric({super.key, required this.onUseCredentials});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey("login_fingerprint"),
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text(
                'Confirmar su identidad',
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
                'La aplicación necesita verificar su identidad',
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
          const SizedBox(height: 65),
          Icon(Icons.fingerprint, size: 75, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            'Toque el sensor de huella digital',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.29,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onUseCredentials,
            child: Text(
              'Usar credenciales',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                height: 1.83,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
