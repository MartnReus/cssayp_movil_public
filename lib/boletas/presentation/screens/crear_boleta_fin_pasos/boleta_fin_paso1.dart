import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';

import 'dart:async';

class Paso1BoletaFinScreen extends ConsumerStatefulWidget {
  const Paso1BoletaFinScreen({super.key});

  @override
  ConsumerState<Paso1BoletaFinScreen> createState() => _Paso1BoletaFinScreenState();
}

class _Paso1BoletaFinScreenState extends ConsumerState<Paso1BoletaFinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _expedienteController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _cuijController = TextEditingController();
  final TextEditingController _busquedaCaratulaController = TextEditingController();

  // final RegExp _soloNumeros = RegExp(r'^[0-9]+$');

  Timer? _debounce;

  BoletaEntity? _boletaSeleccionada;
  bool _mostrarBusqueda = false;
  List<BoletaEntity> _boletasFiltradas = [];
  bool showCaratulaError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(boletasProvider.notifier).buscarBoletasInicioPagadas(page: 1);
      final state = ref.watch(boletasProvider);
      setState(() {
        _boletasFiltradas = state.value!.boletas;
      });
    });
  }

  @override
  void dispose() {
    _expedienteController.dispose();
    _anioController.dispose();
    _cuijController.dispose();
    _busquedaCaratulaController.dispose();
    super.dispose();
  }

  void _filtrarCaratulas(String? caratulaBuscada, {int page = 1}) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _boletasFiltradas = [];
      });

      if (caratulaBuscada == null || caratulaBuscada.isEmpty) {
        await ref.read(boletasProvider.notifier).buscarBoletasInicioPagadas(page: page);
      } else {
        await ref.read(boletasProvider.notifier).buscarBoletasInicioPagadas(caratulaBuscada: caratulaBuscada);
      }

      setState(() {
        _boletasFiltradas = ref.read(boletasProvider).value!.boletas;
      });
    });
  }

  void _seleccionarCaratula(BoletaEntity boleta) {
    setState(() {
      _boletaSeleccionada = boleta;
      _mostrarBusqueda = false;
      _busquedaCaratulaController.clear();
    });

    ref.read(boletaFinDataProvider.notifier).updateIdBoletaInicio(boleta.id);
    ref.read(boletaFinDataProvider.notifier).updateCaratula(boleta.caratula);
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
                        boletaType: 'Boleta de Finalización',
                        stepLabels: ['Datos del Expediente', 'Regulación', 'Resumen'],
                        icon: Icons.check_circle_outline,
                        iconColor: Color(0xFF2196F3),
                      ),

                      const SizedBox(height: 32),

                      // Subtítulo
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Complete los datos del expediente',
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
                            'Seleccione la carátula y complete la información\ndel expediente judicial correspondiente a la\nfinalización del juicio',
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

                      // Campos del formulario
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo Carátula (Sistema de selección mejorado)
                          _buildCaratulaSelector(),
                          const SizedBox(height: 16),

                          // Campo Número de expediente
                          _buildNumericField(
                            label: "Número de expediente (Opcional)",
                            controller: _expedienteController,
                          ),
                          const SizedBox(height: 16),

                          // Campo Año del expediente
                          _buildNumericField(label: "Año del expediente (Opcional)", controller: _anioController),
                          const SizedBox(height: 16),

                          // Campo CUIJ
                          _buildNumericField(label: "Número de C.U.I.J. (Opcional)", controller: _cuijController),

                          const SizedBox(height: 32),
                        ],
                      ),
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
                  final expediente = int.tryParse(_expedienteController.text);
                  final anio = int.tryParse(_anioController.text);
                  final cuij = int.tryParse(_cuijController.text);

                  if (_boletaSeleccionada == null) {
                    setState(() {
                      showCaratulaError = true;
                    });
                    return;
                  }

                  setState(() {
                    showCaratulaError = false;
                  });

                  ref
                      .read(boletaFinDataProvider.notifier)
                      .updateStep1Data(
                        idBoletaInicio: ref.read(boletaFinDataProvider).idBoletaInicio!,
                        caratula: ref.read(boletaFinDataProvider).caratula!,
                        expediente: expediente,
                        anio: anio,
                        cuij: cuij,
                      );

                  if (!ref.read(boletaFinDataProvider).isValidForStep1) {
                    return;
                  }

                  Navigator.pushReplacementNamed(context, '/boleta-fin-paso2');
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

  /// Selector de carátula mejorado con opciones predefinidas y búsqueda
  Widget _buildCaratulaSelector() {
    final state = ref.watch(boletasProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Carátula',
          style: TextStyle(
            color: Color(0xFF173664),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.40,
          ),
        ),
        const SizedBox(height: 4),

        // Campo de selección principal
        InkWell(
          onTap: () {
            setState(() {
              _mostrarBusqueda = !_mostrarBusqueda;
              if (!_mostrarBusqueda) {
                ref.read(boletasProvider.notifier).buscarBoletasInicioPagadas();
                _boletasFiltradas = ref.read(boletasProvider).value!.boletas;
                _busquedaCaratulaController.clear();
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: showCaratulaError ? Colors.red : const Color(0xFF194B8F), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _boletaSeleccionada?.caratula ?? 'Seleccione una carátula',
                    style: TextStyle(
                      color: _boletaSeleccionada != null ? const Color(0xFF173664) : Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Icon(
                  _mostrarBusqueda ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF194B8F),
                ),
              ],
            ),
          ),
        ),

        // Validación del campo carátula
        if (_boletaSeleccionada == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Campo obligatorio',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                color: showCaratulaError ? Colors.red : Colors.grey[600],
              ),
            ),
          ),

        // Panel de opciones y búsqueda
        if (_mostrarBusqueda) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF194B8F), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: const Color(0xFF194B8F), size: 20),
                          const SizedBox(width: 8),
                          // wrap text in a max width the container size
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            child: const Text(
                              'Puede utilizar el campo de búsqueda para encontrar más carátulas',
                              style: TextStyle(
                                color: Color(0xFF173664),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _busquedaCaratulaController,
                        onChanged: _filtrarCaratulas,
                        decoration: InputDecoration(
                          hintText: 'Buscar carátula...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF194B8F)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de carátulas filtradas
                if (_boletasFiltradas.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _boletasFiltradas.length,
                      itemBuilder: (context, index) {
                        final boleta = _boletasFiltradas[index];
                        return InkWell(
                          onTap: () => _seleccionarCaratula(boleta),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _boletaSeleccionada == boleta ? const Color(0xFFE3F2FD) : null,
                              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
                            ),
                            child: Text(
                              boleta.caratula,
                              style: TextStyle(
                                color: _boletaSeleccionada == boleta
                                    ? const Color(0xFF194B8F)
                                    : const Color(0xFF173664),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: _boletaSeleccionada == boleta ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: (state.value?.isLoading ?? false)
                        ? const LoadingIndicator()
                        : Text(
                            'No se encontraron carátulas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Campo numérico
  Widget _buildNumericField({required String label, required TextEditingController controller}) {
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
          keyboardType: TextInputType.number,
          // validator: (val) {
          //   if (val == null || val.isEmpty) return 'Campo obligatorio';
          //   if (!_soloNumeros.hasMatch(val)) return 'Solo se permiten números';
          //   return null;
          // },
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
