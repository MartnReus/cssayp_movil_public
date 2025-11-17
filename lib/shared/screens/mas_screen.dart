import 'package:flutter/material.dart';

class MasScreen extends StatelessWidget {
  MasScreen({super.key});

  final List<Map<String, String>> listaOpciones = [
    {'title': 'Pagos', 'route': '/pagos'},
    {'title': 'Configuración', 'route': '/settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Más opciones',
          style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          for (var opcion in listaOpciones)
            ListTile(
              title: Text(opcion['title']!),
              onTap: () {
                Navigator.of(context).pushNamed(opcion['route']!);
              },
            ),
        ],
      ),
    );
  }
}
