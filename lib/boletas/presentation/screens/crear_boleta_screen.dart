import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_tipo.dart';

class CrearBoletaScreen extends ConsumerStatefulWidget {
  const CrearBoletaScreen({super.key});

  @override
  ConsumerState<CrearBoletaScreen> createState() => _CrearBoletaScreenState();
}

class _CrearBoletaScreenState extends ConsumerState<CrearBoletaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crear Boleta',
          style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _buildTipoSelector(),
    );
  }

  Widget _buildTipoSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Seleccione el tipo de boleta',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF173664),
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Elija el tipo de boleta que desea crear según el estado del proceso judicial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF173664),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 40),

          _buildTipoCard(
            tipo: BoletaTipo.inicio,
            titulo: 'Boleta de Inicio',
            descripcion: 'Para juicios que están comenzando.\nRequiere datos del proceso y las partes.',
            icono: Icons.play_circle_outline,
            color: const Color(0xFF4CAF50),
          ),

          const SizedBox(height: 20),

          _buildTipoCard(
            tipo: BoletaTipo.finalizacion,
            titulo: 'Boleta de Finalización',
            descripcion: 'Para juicios que están finalizando.\nRequiere datos de regulación de honorarios.',
            icono: Icons.check_circle_outline,
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoCard({
    required BoletaTipo tipo,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navegar directamente a la ruta correspondiente
          if (tipo == BoletaTipo.inicio) {
            Navigator.pushNamed(context, '/boleta-inicio-paso1');
          } else {
            Navigator.pushNamed(context, '/boleta-fin-paso1');
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Icono
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icono, size: 40, color: color),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                titulo,
                style: TextStyle(
                  color: const Color(0xFF173664),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Seleccionar',
                  style: TextStyle(color: color, fontSize: 12, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
