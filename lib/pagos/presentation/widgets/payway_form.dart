import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

class PayWayForm extends ConsumerStatefulWidget {
  final VoidCallback? onFormValidationChanged;

  const PayWayForm({super.key, this.onFormValidationChanged});

  @override
  ConsumerState<PayWayForm> createState() => _PayWayFormState();
}

class _PayWayFormState extends ConsumerState<PayWayForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _nroTarjetaController = TextEditingController();
  final _cvvController = TextEditingController();
  final _fechaExpiracionController = TextEditingController();

  final _nombreFocusNode = FocusNode();
  final _dniFocusNode = FocusNode();
  final _nroTarjetaFocusNode = FocusNode();
  final _cvvFocusNode = FocusNode();
  final _fechaExpiracionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _nombreController.addListener(_updateCardData);
    _dniController.addListener(_updateCardData);
    _nroTarjetaController.addListener(_updateCardData);
    _cvvController.addListener(_updateCardData);
    _fechaExpiracionController.addListener(_updateCardData);
  }

  void _updateCardData() {
    final payWayState = ref.read(payWayNotifierProvider).value;
    final datos = DatosTarjetaModel(
      nombre: _nombreController.text,
      dni: _dniController.text,
      nroTarjeta: _nroTarjetaController.text,
      cvv: _cvvController.text,
      fechaExpiracion: _fechaExpiracionController.text,
      tipoTarjeta: payWayState?.tipoTarjeta ?? TipoTarjeta.debito,
      cuotas: payWayState?.cuotas ?? 1,
    );

    ref.read(payWayNotifierProvider.notifier).updateCardData(datos);
    widget.onFormValidationChanged?.call();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _nroTarjetaController.dispose();
    _cvvController.dispose();
    _fechaExpiracionController.dispose();

    _nombreFocusNode.dispose();
    _dniFocusNode.dispose();
    _nroTarjetaFocusNode.dispose();
    _cvvFocusNode.dispose();
    _fechaExpiracionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payWayState = ref.watch(payWayNotifierProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Datos de la Tarjeta',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF173664),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nombre del titular
            _buildTextField(
              controller: _nombreController,
              focusNode: _nombreFocusNode,
              label: 'Nombre del titular',
              hint: 'Ingrese el nombre como aparece en la tarjeta',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              errorText: payWayState.value?.validationErrors['nombre'],
              fieldName: 'nombre',
            ),
            const SizedBox(height: 16),

            // DNI
            _buildTextField(
              controller: _dniController,
              focusNode: _dniFocusNode,
              label: 'DNI',
              hint: 'Ingrese su DNI sin puntos',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
              errorText: payWayState.value?.validationErrors['dni'],
              fieldName: 'dni',
            ),
            const SizedBox(height: 16),

            // Tipo de tarjeta (Débito/Crédito)
            _buildTipoTarjetaSelector(payWayState.value?.tipoTarjeta ?? TipoTarjeta.debito),
            const SizedBox(height: 16),

            // Cuotas (solo para crédito)
            if (payWayState.value?.tipoTarjeta == TipoTarjeta.credito) ...[
              _buildCuotasSelector(payWayState.value?.cuotas ?? 1),
              const SizedBox(height: 16),
            ],

            // Número de tarjeta
            _buildTextField(
              controller: _nroTarjetaController,
              focusNode: _nroTarjetaFocusNode,
              label: 'Número de tarjeta',
              hint: '1234 5678 9012 3456',
              icon: Icons.credit_card_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                _CardNumberInputFormatter(),
              ],
              errorText: payWayState.value?.validationErrors['nroTarjeta'],
              fieldName: 'nroTarjeta',
            ),
            const SizedBox(height: 16),

            // CVV y Fecha de expiración en la misma fila
            Row(
              children: [
                // CVV
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _cvvController,
                    focusNode: _cvvFocusNode,
                    label: 'CVV',
                    hint: '123',
                    icon: Icons.security_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    errorText: payWayState.value?.validationErrors['cvv'],
                    fieldName: 'cvv',
                  ),
                ),
                const SizedBox(width: 16),
                // Fecha de expiración
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _fechaExpiracionController,
                    focusNode: _fechaExpiracionFocusNode,
                    label: 'Vencimiento',
                    hint: 'MM/YY',
                    icon: Icons.calendar_month_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateInputFormatter(),
                    ],
                    errorText: payWayState.value?.validationErrors['fechaExpiracion'],
                    fieldName: 'fechaExpiracion',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String fieldName,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF173664),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          inputFormatters: inputFormatters,
          onTap: () {
            ref.read(payWayNotifierProvider.notifier).markFieldAsTouched(fieldName);
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF173664)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF173664), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey[50],
            errorText: errorText,
            errorStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 12),
          ),
          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTipoTarjetaSelector(TipoTarjeta selectedTipo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de tarjeta',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF173664),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTipoTarjetaOption(
                tipo: TipoTarjeta.debito,
                label: 'Débito',
                icon: Icons.account_balance_wallet_outlined,
                isSelected: selectedTipo == TipoTarjeta.debito,
                onTap: () {
                  ref.read(payWayNotifierProvider.notifier).updateTipoTarjeta(TipoTarjeta.debito);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTipoTarjetaOption(
                tipo: TipoTarjeta.credito,
                label: 'Crédito',
                icon: Icons.credit_card_outlined,
                isSelected: selectedTipo == TipoTarjeta.credito,
                onTap: () {
                  ref.read(payWayNotifierProvider.notifier).updateTipoTarjeta(TipoTarjeta.credito);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipoTarjetaOption({
    required TipoTarjeta tipo,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF173664) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF173664) : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF173664), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isSelected ? Colors.white : const Color(0xFF173664),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuotasSelector(int selectedCuotas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuotas',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF173664),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedCuotas,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF173664)),
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF173664)),
              items: List.generate(12, (index) {
                final cuotas = index + 1;
                return DropdownMenuItem<int>(value: cuotas, child: Text('$cuotas ${cuotas == 1 ? 'cuota' : 'cuotas'}'));
              }),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  ref.read(payWayNotifierProvider.notifier).updateCuotas(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Formateador para número de tarjeta (agregar espacios cada 4 dígitos)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\s+'), '');
    final formattedText = _addSpaces(text);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _addSpaces(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

// Formateador para fecha de expiración (agregar / después de MM)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formattedText = text;

    if (text.length >= 2) {
      formattedText = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
