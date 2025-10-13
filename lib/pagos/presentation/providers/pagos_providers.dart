import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

// Provider para el estado general de pagos
class PagosNotifier extends Notifier<PagosState> {
  @override
  PagosState build() {
    return const PagosState();
  }

  void selectBoletas(List<int> boletaIds) {
    state = state.copyWith(selectedBoletaIds: boletaIds);
  }

  void clearSelection() {
    state = state.copyWith(selectedBoletaIds: []);
  }

  void setProcessingPayment(bool isProcessing) {
    state = state.copyWith(isProcessing: isProcessing);
  }
}

class PagosState {
  final List<int> selectedBoletaIds;
  final bool isProcessing;

  const PagosState({this.selectedBoletaIds = const [], this.isProcessing = false});

  PagosState copyWith({List<int>? selectedBoletaIds, bool? isProcessing}) {
    return PagosState(
      selectedBoletaIds: selectedBoletaIds ?? this.selectedBoletaIds,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

final pagosNotifierProvider = NotifierProvider<PagosNotifier, PagosState>(() => PagosNotifier());

// Red Link Providers
final redLinkDataSourceProvider = Provider<RedLinkDataSource>((ref) {
  return RedLinkDataSource(client: ref.read(httpClientProvider));
});

final redLinkRepositoryProvider = Provider<RedLinkRepository>((ref) {
  return RedLinkRepositoryImpl(dataSource: ref.read(redLinkDataSourceProvider));
});

final pagarConRedLinkUseCaseProvider = Provider<PagarConRedLinkUseCase>((ref) {
  return PagarConRedLinkUseCase(repository: ref.read(redLinkRepositoryProvider));
});
