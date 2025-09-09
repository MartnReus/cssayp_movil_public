import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

class Paso2BoletaInicioScreen extends ConsumerStatefulWidget {
  const Paso2BoletaInicioScreen({super.key});

  @override
  ConsumerState<Paso2BoletaInicioScreen> createState() => _Paso2BoletaInicioScreenState();
}

class _Paso2BoletaInicioScreenState extends ConsumerState<Paso2BoletaInicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _causaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar datos previos si existen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(boletaInicioDataProvider);
      if (state.causa != null) {
        _causaController.text = state.causa!;
      }
    });
  }

  @override
  void dispose() {
    _causaController.dispose();
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
                        currentStep: 2,
                        boletaType: 'Boleta de Inicio',
                        stepLabels: ['Partes', 'Datos del Juicio', 'Resumen'],
                      ),

                      const SizedBox(height: 32),

                      // Subtítulo
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Ingrese la causa',
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
                            'Estos datos permiten identificar correctamente\nel expediente judicial',
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

                      // Campo de texto para Causa
                      _buildCausaField(),
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
                Navigator.pushReplacementNamed(context, '/boleta-inicio-paso1');
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
                  ref.read(boletaInicioDataProvider.notifier).updateCausa(_causaController.text.trim());
                  Navigator.pushReplacementNamed(context, '/boleta-inicio-paso3');
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

  Widget _buildCausaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Causa',
          style: TextStyle(
            color: Color(0xFF173664),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.40,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _causaController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La causa es obligatoria';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Ingrese la causa del juicio',
            hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14, fontFamily: 'Inter'),
            filled: true,
            fillColor: Colors.white,
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
              borderSide: const BorderSide(color: Color(0xFF194B8F), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(color: Color(0xFF173664), fontSize: 14, fontFamily: 'Inter'),
          maxLines: 3,
          minLines: 1,
        ),
      ],
    );
  }
}
