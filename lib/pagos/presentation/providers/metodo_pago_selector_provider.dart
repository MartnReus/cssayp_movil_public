import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado para el selector de métodos de pago
enum MetodoPago { botonPago, linkPago, tarjeta, redLink }

class MetodoPagoState {
  final MetodoPago? selectedMethod;

  const MetodoPagoState({this.selectedMethod});

  MetodoPagoState copyWith({MetodoPago? selectedMethod}) {
    return MetodoPagoState(selectedMethod: selectedMethod ?? this.selectedMethod);
  }

  bool get canProceedWithPayment => selectedMethod != null;
}

class MetodoPagoSelectorNotifier extends Notifier<MetodoPagoState> {
  @override
  MetodoPagoState build() {
    return const MetodoPagoState();
  }

  void selectMethod(MetodoPago method) {
    state = state.copyWith(selectedMethod: method);
  }
}

final metodoPagoSelectorProvider = NotifierProvider<MetodoPagoSelectorNotifier, MetodoPagoState>(
  () => MetodoPagoSelectorNotifier(),
);
