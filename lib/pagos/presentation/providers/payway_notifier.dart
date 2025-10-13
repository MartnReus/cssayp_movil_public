import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

class PayWayNotifier extends AsyncNotifier<PayWayState> {
  late final PagarConPaywayUseCase _pagarConPaywayUseCase;

  @override
  Future<PayWayState> build() async {
    _pagarConPaywayUseCase = await ref.read(pagarConPaywayUseCaseProvider.future);
    return const AsyncValue.data(PayWayState()).value!;
  }

  // Validación de campos de tarjeta
  Map<String, String> _validateCardData(DatosTarjetaModel datos) {
    final errors = <String, String>{};

    // Validar nombre
    if (datos.nombre.trim().isEmpty) {
      errors['nombre'] = 'El nombre es requerido';
    } else if (datos.nombre.trim().length < 2) {
      errors['nombre'] = 'El nombre debe tener al menos 2 caracteres';
    }

    // Validar DNI
    if (datos.dni.trim().isEmpty) {
      errors['dni'] = 'El DNI es requerido';
    } else if (!RegExp(r'^\d{7,8}$').hasMatch(datos.dni.trim())) {
      errors['dni'] = 'El DNI debe tener 7 u 8 dígitos';
    }

    // Validar número de tarjeta
    if (datos.nroTarjeta.trim().isEmpty) {
      errors['nroTarjeta'] = 'El número de tarjeta es requerido';
    } else {
      final cleanCardNumber = datos.nroTarjeta.replaceAll(RegExp(r'\s+'), '');
      if (!RegExp(r'^\d{13,19}$').hasMatch(cleanCardNumber)) {
        errors['nroTarjeta'] = 'Número de tarjeta inválido';
      } else if (!_luhnCheck(cleanCardNumber)) {
        errors['nroTarjeta'] = 'Número de tarjeta inválido';
      }
    }

    // Validar CVV
    if (datos.cvv.trim().isEmpty) {
      errors['cvv'] = 'El CVV es requerido';
    } else if (!RegExp(r'^\d{3,4}$').hasMatch(datos.cvv.trim())) {
      errors['cvv'] = 'El CVV debe tener 3 o 4 dígitos';
    }

    // Validar fecha de expiración
    if (datos.fechaExpiracion.trim().isEmpty) {
      errors['fechaExpiracion'] = 'La fecha de expiración es requerida';
    } else if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(datos.fechaExpiracion.trim())) {
      errors['fechaExpiracion'] = 'Formato inválido (MM/YY)';
    } else {
      final parts = datos.fechaExpiracion.split('/');
      if (parts.length == 2) {
        final month = int.tryParse(parts[0]);
        final year = int.tryParse(parts[1]);
        final currentYear = DateTime.now().year % 100;
        final currentMonth = DateTime.now().month;

        if (month == null || year == null) {
          errors['fechaExpiracion'] = 'Fecha inválida';
        } else if (year < currentYear || (year == currentYear && month < currentMonth)) {
          errors['fechaExpiracion'] = 'La tarjeta está vencida';
        }
      }
    }

    return errors;
  }

  // Algoritmo de Luhn para validar número de tarjeta
  bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  // Marcar campo como tocado
  void markFieldAsTouched(String fieldName) {
    final newTouchedFields = Set<String>.from(state.value!.touchedFields);
    newTouchedFields.add(fieldName);

    state = AsyncValue.data(state.value!.copyWith(touchedFields: newTouchedFields));
  }

  // Actualizar datos de tarjeta y validar solo campos tocados
  void updateCardData(DatosTarjetaModel datos) {
    final allValidationErrors = _validateCardData(datos);

    // Solo mostrar errores para campos que han sido tocados
    final validationErrors = <String, String>{};
    for (final fieldName in state.value!.touchedFields) {
      if (allValidationErrors.containsKey(fieldName)) {
        validationErrors[fieldName] = allValidationErrors[fieldName]!;
      }
    }

    final isValid = allValidationErrors.isEmpty;

    state = AsyncValue.data(
      state.value!.copyWith(
        datosTarjeta: datos,
        validationErrors: validationErrors,
        isFormValid: isValid,
        tipoTarjeta: datos.tipoTarjeta,
        cuotas: datos.cuotas,
      ),
    );
  }

  // Actualizar tipo de tarjeta
  void updateTipoTarjeta(TipoTarjeta tipoTarjeta) {
    final currentDatos = state.value!.datosTarjeta;
    if (currentDatos != null) {
      final newDatos = DatosTarjetaModel(
        nombre: currentDatos.nombre,
        dni: currentDatos.dni,
        nroTarjeta: currentDatos.nroTarjeta.replaceAll(' ', ''),
        cvv: currentDatos.cvv,
        fechaExpiracion: currentDatos.fechaExpiracion,
        tipoTarjeta: tipoTarjeta,
        cuotas: tipoTarjeta == TipoTarjeta.credito ? state.value!.cuotas : 1,
      );
      updateCardData(newDatos);
    } else {
      state = AsyncValue.data(state.value!.copyWith(tipoTarjeta: tipoTarjeta));
    }
  }

  // Actualizar número de cuotas
  void updateCuotas(int cuotas) {
    final currentDatos = state.value!.datosTarjeta;
    if (currentDatos != null) {
      final newDatos = DatosTarjetaModel(
        nombre: currentDatos.nombre,
        dni: currentDatos.dni,
        nroTarjeta: currentDatos.nroTarjeta.replaceAll(' ', ''),
        cvv: currentDatos.cvv,
        fechaExpiracion: currentDatos.fechaExpiracion,
        tipoTarjeta: currentDatos.tipoTarjeta,
        cuotas: cuotas,
      );
      updateCardData(newDatos);
    } else {
      state = AsyncValue.data(state.value!.copyWith(cuotas: cuotas));
    }
  }

  // Limpiar errores de un campo específico
  void clearFieldError(String fieldName) {
    if (state.value!.validationErrors.containsKey(fieldName)) {
      final newErrors = Map<String, String>.from(state.value!.validationErrors);
      newErrors.remove(fieldName);

      state = AsyncValue.data(state.value!.copyWith(validationErrors: newErrors));
    }
  }

  // Procesar pago con PayWay
  Future<void> procesarPago(List<BoletaAPagarEntity> boletas) async {
    if (!state.value!.isFormValid || state.value!.datosTarjeta == null) {
      state = AsyncValue.data(
        state.value!.copyWith(
          paymentState: const PaymentError(error: 'Por favor complete todos los campos correctamente'),
        ),
      );
      return;
    }

    try {
      state = AsyncValue.data(
        state.value!.copyWith(paymentState: const PaymentLoading(message: 'Procesando pago con tarjeta...')),
      );

      final datosTarjetaLimpios = DatosTarjetaModel(
        nombre: state.value!.datosTarjeta!.nombre,
        dni: state.value!.datosTarjeta!.dni,
        nroTarjeta: state.value!.datosTarjeta!.nroTarjeta.replaceAll(RegExp(r'\s+'), ''),
        cvv: state.value!.datosTarjeta!.cvv,
        fechaExpiracion: state.value!.datosTarjeta!.fechaExpiracion,
        tipoTarjeta: state.value!.datosTarjeta!.tipoTarjeta,
        cuotas: state.value!.datosTarjeta!.cuotas,
      );

      final resultado = await _pagarConPaywayUseCase.execute(boletas: boletas, datosTarjeta: datosTarjetaLimpios);

      // Verificar si el pago fue exitoso basándose en el statusCode
      if (resultado.statusCode == 200) {
        state = AsyncValue.data(state.value!.copyWith(paymentState: PaymentSuccess(resultado: resultado)));
      } else {
        // Extraer mensaje de error del resultado
        String errorMessage = 'Error al procesar el pago';
        if (resultado.message is String) {
          errorMessage = resultado.message as String;
        } else if (resultado.message is Map) {
          final messageMap = resultado.message as Map<String, dynamic>;
          errorMessage =
              messageMap['mensaje']?.toString() ??
              messageMap['message']?.toString() ??
              messageMap['error']?.toString() ??
              'Error al procesar el pago';
        }
        state = AsyncValue.data(state.value!.copyWith(paymentState: PaymentError(error: errorMessage)));
      }
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(paymentState: PaymentError(error: 'Error al procesar el pago: ${e.toString()}')),
      );
    }
  }

  // Reiniciar estado
  void resetState() {
    state = const AsyncValue.data(PayWayState());
  }

  // Limpiar solo el estado de pago (mantener datos del formulario)
  void clearPaymentState() {
    state = AsyncValue.data(state.value!.copyWith(paymentState: const PaymentInitial()));
  }
}

final payWayNotifierProvider = AsyncNotifierProvider<PayWayNotifier, PayWayState>(() => PayWayNotifier());
