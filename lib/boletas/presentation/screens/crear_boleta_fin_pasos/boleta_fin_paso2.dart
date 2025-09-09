import 'package:cssayp_movil/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

class Paso2BoletaFinScreen extends ConsumerStatefulWidget {
  const Paso2BoletaFinScreen({super.key});

  @override
  ConsumerState<Paso2BoletaFinScreen> createState() => _Paso2BoletaFinScreenState();
}

class _Paso2BoletaFinScreenState extends ConsumerState<Paso2BoletaFinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cantidadJusController = TextEditingController();
  DateTime? _fechaRegulacion;

  double _valorJus = 0;
  double _honorarios = 0;
  double _montoValido = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar los campos con los datos del provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boletaFinData = ref.read(boletaFinDataProvider);
      if (boletaFinData.fechaRegulacion != null) {
        _fechaRegulacion = boletaFinData.fechaRegulacion;
      }
      if (boletaFinData.cantidadJus != null) {
        final formatter = NumberFormat('#,##0.0#', 'es_AR');
        _cantidadJusController.text = formatter.format(boletaFinData.cantidadJus!);
        _calcularValores();
      }
    });
  }

  @override
  void dispose() {
    _cantidadJusController.dispose();
    super.dispose();
  }

  void _calcularValores() {
    final normalizedText = _cantidadJusController.text.replaceAll(',', '.');
    final cantidad = double.tryParse(normalizedText) ?? 0;
    setState(() {
      _valorJus = AppConfig.valorJus;
      _honorarios = _valorJus * cantidad;
      _montoValido = _honorarios / 5;
    });
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaRegulacion ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'AR'),
    );
    if (picked != null) {
      setState(() {
        _fechaRegulacion = picked;
        _calcularValores();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      const BoletaStepperWidget(
                        currentStep: 2,
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
                            'Ingrese los datos de regulación final',
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
                            'Complete la fecha de regulación y la cantidad de JUS. Los valores se calcularán automáticamente según la normativa vigente',
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

                      // Fecha de Regulación Final
                      _buildDateField(),

                      const SizedBox(height: 16),

                      _buildNumericField(label: 'Cantidad JUS', controller: _cantidadJusController),

                      const SizedBox(height: 24),

                      _buildResultField('Valor JUS', _valorJus),
                      _buildResultField('Honorarios', _honorarios),
                      _buildResultField('Monto válido', _montoValido),

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
                Navigator.pushReplacementNamed(context, '/boleta-fin-paso1');
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
                  _calcularValores();

                  // Normalizar el separador decimal (comma a dot) para el parsing
                  final normalizedText = _cantidadJusController.text.replaceAll(',', '.');
                  final cantidadJus = double.tryParse(normalizedText);
                  if (cantidadJus != null) {
                    ref
                        .read(boletaFinDataProvider.notifier)
                        .updateStep2Data(
                          fechaRegulacion: _fechaRegulacion!,
                          cantidadJus: cantidadJus,
                          valorJus: _valorJus,
                          honorarios: _honorarios,
                          montoValido: _montoValido,
                        );
                  }

                  if (!ref.read(boletaFinDataProvider).isValidForStep2) {
                    return;
                  }

                  Navigator.pushReplacementNamed(context, '/boleta-fin-paso3');
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

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _seleccionarFecha(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: _fechaRegulacion != null
                ? DateFormat('dd/MM/yyyy').format(_fechaRegulacion!)
                : 'Seleccione fecha',
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
          validator: (val) => _fechaRegulacion == null ? 'Campo obligatorio' : null,
        ),
      ),
    );
  }

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
          validator: (val) {
            if (val == null || val.isEmpty) return 'Campo obligatorio';
            if (!RegExp(r'^[0-9]+([.,][0-9]+)?$').hasMatch(val)) return 'Solo números permitidos (ej: 1,5 o 1.5)';
            return null;
          },
          onChanged: (_) => _calcularValores(),
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

  Widget _buildResultField(String label, double value) {
    final formatter = NumberFormat('#,##0.00', 'es_AR');
    final formattedValue = formatter.format(value);

    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFF111112),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.29,
              ),
            ),
            TextSpan(
              text: '\$ $formattedValue',
              style: const TextStyle(
                color: Color(0xFF111112),
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
