import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

class Paso1BoletaInicioScreen extends ConsumerStatefulWidget {
  const Paso1BoletaInicioScreen({super.key});

  @override
  ConsumerState<Paso1BoletaInicioScreen> createState() => _Paso1BoletaInicioScreenState();
}

class _Paso1BoletaInicioScreenState extends ConsumerState<Paso1BoletaInicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actorController = TextEditingController();
  final _demandadoController = TextEditingController();

  final RegExp _soloLetras = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$");

  @override
  void initState() {
    super.initState();
    // Cargar datos previos si existen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(boletaInicioDataProvider);
      if (state.value?.actor != null) {
        _actorController.text = state.value!.actor!;
      }
      if (state.value?.demandado != null) {
        _demandadoController.text = state.value!.demandado!;
      }
    });
  }

  @override
  void dispose() {
    _actorController.dispose();
    _demandadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Stepper elegante
                      const BoletaStepperWidget(
                        currentStep: 1,
                        boletaType: 'Boleta de Inicio',
                        stepLabels: ['Partes', 'Datos del Juicio', 'Resumen'],
                      ),

                      const SizedBox(height: 32),

                      // Subtítulo
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Ingrese las partes del juicio',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF173664),
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.33,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Complete el nombre del actor y del\ndemandado tal como figuran en el expediente',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF173664),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              height: 1.29,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Campo Actor
                      _buildTextField(label: "Actor(es)", controller: _actorController),
                      const SizedBox(height: 16),

                      // Campo Demandado
                      _buildTextField(label: "Demandado(s)", controller: _demandadoController),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Volver
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFF194B8F), borderRadius: BorderRadius.circular(8)),
                child: const Center(
                  child: Text(
                    'Volver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.83,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Siguiente
          Expanded(
            child: InkWell(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // Guardar datos en el provider
                  ref.read(boletaInicioDataProvider.notifier).updateActor(_actorController.text.trim());
                  ref.read(boletaInicioDataProvider.notifier).updateDemandado(_demandadoController.text.trim());
                  Navigator.pushReplacementNamed(context, '/boleta-inicio-paso2');
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFF173664), borderRadius: BorderRadius.circular(8)),
                child: const Center(
                  child: Text(
                    'SIGUIENTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.83,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF173664),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.40,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "Campo obligatorio";
            }
            if (!_soloLetras.hasMatch(val)) {
              return "Solo letras y espacios permitidos";
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF194B8F), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF194B8F), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF194B8F), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
