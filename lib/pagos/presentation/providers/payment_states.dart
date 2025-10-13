import 'package:cssayp_movil/pagos/data/models/datos_tarjeta_model.dart';
import 'package:cssayp_movil/pagos/data/models/resultado_pago_model.dart';

// Estados base para el manejo de pagos
abstract class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  final String message;

  const PaymentLoading({this.message = 'Procesando pago...'});
}

class PaymentSuccess extends PaymentState {
  final ResultadoPagoModel resultado;

  const PaymentSuccess({required this.resultado});
}

class PaymentError extends PaymentState {
  final String error;

  const PaymentError({required this.error});
}

class PayWayState {
  final PaymentState paymentState;
  final DatosTarjetaModel? datosTarjeta;
  final Map<String, String> validationErrors;
  final Set<String> touchedFields;
  final bool isFormValid;
  final TipoTarjeta tipoTarjeta;
  final int cuotas;

  const PayWayState({
    this.paymentState = const PaymentInitial(),
    this.datosTarjeta,
    this.validationErrors = const {},
    this.touchedFields = const {},
    this.isFormValid = false,
    this.tipoTarjeta = TipoTarjeta.debito,
    this.cuotas = 1,
  });

  PayWayState copyWith({
    PaymentState? paymentState,
    DatosTarjetaModel? datosTarjeta,
    Map<String, String>? validationErrors,
    Set<String>? touchedFields,
    bool? isFormValid,
    TipoTarjeta? tipoTarjeta,
    int? cuotas,
  }) {
    return PayWayState(
      paymentState: paymentState ?? this.paymentState,
      datosTarjeta: datosTarjeta ?? this.datosTarjeta,
      validationErrors: validationErrors ?? this.validationErrors,
      touchedFields: touchedFields ?? this.touchedFields,
      isFormValid: isFormValid ?? this.isFormValid,
      tipoTarjeta: tipoTarjeta ?? this.tipoTarjeta,
      cuotas: cuotas ?? this.cuotas,
    );
  }
}
