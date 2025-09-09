import 'package:flutter/material.dart';

class OfflineNotification extends StatelessWidget {
  const OfflineNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: const Text(
        'Estás en modo sin conexión, algunas funcionalidades pueden no estar disponibles',
        style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
        textAlign: TextAlign.left,
      ),
    );
  }
}
