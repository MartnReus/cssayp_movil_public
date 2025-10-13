import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';
import 'package:cssayp_movil/pagos/data/models/resultado_pago_model.dart';
import 'package:cssayp_movil/pagos/domain/usecases/pagar_con_red_link_use_case.dart';
import 'package:cssayp_movil/pagos/presentation/providers/payment_states.dart';
import 'package:cssayp_movil/pagos/presentation/providers/pagos_providers.dart';

class RedLinkState {
  final PaymentState paymentState;
  final String? paymentUrl;
  final String? tokenIdLink;
  final String? referencia;
  final int? boletaId;

  const RedLinkState({
    this.paymentState = const PaymentInitial(),
    this.paymentUrl,
    this.tokenIdLink,
    this.referencia,
    this.boletaId,
  });

  RedLinkState copyWith({
    PaymentState? paymentState,
    String? paymentUrl,
    String? tokenIdLink,
    String? referencia,
    int? boletaId,
  }) {
    return RedLinkState(
      paymentState: paymentState ?? this.paymentState,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      tokenIdLink: tokenIdLink ?? this.tokenIdLink,
      referencia: referencia ?? this.referencia,
      boletaId: boletaId ?? this.boletaId,
    );
  }

  bool get isPaymentUrlAvailable => paymentUrl != null && paymentUrl!.isNotEmpty;
  bool get isMonitoringPayment => paymentState is PaymentLoading;
}

class RedLinkNotifier extends AsyncNotifier<RedLinkState> {
  late final PagarConRedLinkUseCase _pagarConRedLinkUseCase;
  StreamSubscription<RedLinkPaymentStatusModel>? _paymentSubscription;

  @override
  RedLinkState build() {
    _pagarConRedLinkUseCase = ref.read(pagarConRedLinkUseCaseProvider);
    return const RedLinkState();
  }

  /// Inicia el proceso de pago con Red Link
  Future<void> iniciarPago({required int idBoleta}) async {
    try {
      state = AsyncValue.data(
        state.value!.copyWith(
          paymentState: const PaymentLoading(message: 'Generando URL de pago...'),
          boletaId: idBoleta,
        ),
      );

      final response = await _pagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta);

      if (response.success) {
        state = AsyncValue.data(
          state.value!.copyWith(
            paymentState: const PaymentLoading(message: 'URL de pago generada. Abriendo Red Link...'),
            paymentUrl: response.paymentUrl,
            tokenIdLink: response.tokenIdLink,
            referencia: response.referencia,
          ),
        );
      } else {
        state = AsyncValue.data(
          state.value!.copyWith(paymentState: PaymentError(error: response.error ?? 'Error al generar URL de pago')),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(paymentState: PaymentError(error: 'Error inesperado: ${e.toString()}')),
      );
    }
  }

  /// Inicia el monitoreo del pago
  void iniciarMonitoreo() {
    if (state.value?.boletaId == null) return;

    final boletaId = state.value!.boletaId!;

    state = AsyncValue.data(
      state.value!.copyWith(paymentState: const PaymentLoading(message: 'Esperando confirmación del pago...')),
    );

    // Cancelar suscripción anterior si existe
    _paymentSubscription?.cancel();

    // Iniciar nuevo monitoreo
    _paymentSubscription = _pagarConRedLinkUseCase
        .monitorearPago(
          idBoleta: boletaId,
          intervalo: const Duration(seconds: 5),
          maxIntentos: 120, // 10 minutos máximo (120 * 5 segundos)
        )
        .listen(
          (statusModel) {
            if (statusModel.pagado) {
              state = AsyncValue.data(
                state.value!.copyWith(
                  paymentState: PaymentSuccess(
                    resultado: ResultadoPagoModel(statusCode: 200, message: 'Pago realizado exitosamente'),
                  ),
                ),
              );
              _paymentSubscription?.cancel();
            } else if (statusModel.mensaje != null && statusModel.mensaje!.contains('Error')) {
              state = AsyncValue.data(state.value!.copyWith(paymentState: PaymentError(error: statusModel.mensaje!)));
              _paymentSubscription?.cancel();
            }
            // Si no está pagado y no hay error, continúa monitoreando
          },
          onError: (error) {
            state = AsyncValue.data(
              state.value!.copyWith(paymentState: PaymentError(error: 'Error al monitorear pago: ${error.toString()}')),
            );
            _paymentSubscription?.cancel();
          },
        );
  }

  /// Detiene el monitoreo del pago
  void detenerMonitoreo() {
    _paymentSubscription?.cancel();
    _paymentSubscription = null;
  }

  /// Verifica el estado del pago manualmente
  Future<void> verificarEstadoPago() async {
    if (state.value?.boletaId == null) return;

    try {
      final statusModel = await _pagarConRedLinkUseCase.verificarEstado(idBoleta: state.value!.boletaId!);

      if (statusModel.pagado) {
        state = AsyncValue.data(
          state.value!.copyWith(
            paymentState: PaymentSuccess(
              resultado: ResultadoPagoModel(statusCode: 200, message: 'Pago realizado exitosamente'),
            ),
          ),
        );
      } else {
        state = AsyncValue.data(
          state.value!.copyWith(
            paymentState: PaymentLoading(message: statusModel.mensaje ?? 'Esperando confirmación del pago...'),
          ),
        );
      }
    } catch (e) {
      state = AsyncValue.data(
        state.value!.copyWith(paymentState: PaymentError(error: 'Error al verificar estado: ${e.toString()}')),
      );
    }
  }

  /// Reinicia el estado
  void resetState() {
    _paymentSubscription?.cancel();
    _paymentSubscription = null;
    state = const AsyncValue.data(RedLinkState());
  }

  /// Limpia solo el estado de pago manteniendo la URL
  void clearPaymentState() {
    state = AsyncValue.data(state.value!.copyWith(paymentState: const PaymentInitial()));
  }
}

final redLinkNotifierProvider = AsyncNotifierProvider<RedLinkNotifier, RedLinkState>(() => RedLinkNotifier());
