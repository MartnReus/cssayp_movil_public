import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/shared/providers/navigation_provider.dart';

class HistorialScreen extends ConsumerStatefulWidget {
  const HistorialScreen({super.key});

  @override
  ConsumerState<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends ConsumerState<HistorialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final navigator = ref.read(navigationProvider).navigatorState;
          if (navigator != null) {
            navigator.pushNamed("/crear-boleta");
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Título principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            color: const Color(0xFF173664),
            child: const Text(
              "Historial",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),

          // TabBar
          Container(
            color: const Color(0xFF194B8F),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Boletas'),
                Tab(text: 'Juicios'),
              ],
            ),
          ),

          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab de Boletas
                HistorialBoletasWidget(),

                // Tab de Juicios
                HistorialJuiciosWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
