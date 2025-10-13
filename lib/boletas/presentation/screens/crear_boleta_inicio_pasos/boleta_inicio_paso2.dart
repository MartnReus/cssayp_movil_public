import 'package:cssayp_movil/shared/widgets/loading_indicator.dart';
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
  final _juzgadoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar datos previos si existen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(boletaInicioDataProvider);
      if (state.value?.causa != null) {
        _causaController.text = state.value!.causa!;
      }
      if (state.value?.juzgado != null) {
        _juzgadoController.text = state.value!.juzgado!;
      }
    });
  }

  @override
  void dispose() {
    _causaController.dispose();
    _juzgadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boletaInicioDataProvider);
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.hasError) {
      return const Scaffold(body: Center(child: Text('Error al cargar los datos')));
    }

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
                            'Datos del Juicio',
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
                            'Complete los datos del juicio para generar\ncorrectamente la boleta',
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

                      // Campo de tipo de juicio
                      _buildTipoJuicioField(),
                      const SizedBox(height: 32),

                      // Campo de circunscripción
                      _buildCircunscripcionField(),
                      const SizedBox(height: 32),

                      // Campo de texto para Juzgado
                      _buildJuzgadoField(),
                      const SizedBox(height: 32),

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
                  ref.read(boletaInicioDataProvider.notifier).updateJuzgado(_juzgadoController.text.trim());
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

  Widget _buildTipoJuicioField() {
    final state = ref.watch(boletaInicioDataProvider).value;
    // select de tipo de juicio
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de Juicio'),
        DropdownButtonFormField<TipoJuicioEntity>(
          isExpanded: true,
          initialValue: state?.tipoJuicio,
          itemHeight: 60,
          items:
              state?.parametrosBoletaInicio.tiposJuicio
                  .map(
                    (e) => DropdownMenuItem<TipoJuicioEntity>(
                      value: e,
                      child: Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.descripcion,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  )
                  .toList() ??
              [],
          onChanged: (value) {
            if (value != null) {
              ref.read(boletaInicioDataProvider.notifier).updateTipoJuicio(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCircunscripcionField() {
    final state = ref.watch(boletaInicioDataProvider).value;
    // select de circunscripción
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Circunscripción'),
        DropdownButtonFormField<CircunscripcionEntity>(
          isExpanded: true,
          initialValue: state?.circunscripcion,
          itemHeight: 60,
          items:
              state?.parametrosBoletaInicio.circunscripciones
                  .map(
                    (e) => DropdownMenuItem<CircunscripcionEntity>(
                      value: e,
                      child: Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          e.descripcion,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  )
                  .toList() ??
              [],
          onChanged: (value) {
            if (value != null) {
              ref.read(boletaInicioDataProvider.notifier).updateCircunscripcion(value);
            }
          },
        ),
      ],
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

  Widget _buildJuzgadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Juzgado',
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
          controller: _juzgadoController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El juzgado es obligatorio';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Ingrese el juzgado',
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
        ),
      ],
    );
  }
}
