import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

//--------- Use Cases Providers ----------------

final pagarConPaywayUseCaseProvider = FutureProvider<PagarConPaywayUseCase>(
  (ref) async => PagarConPaywayUseCase(paywayRepository: await ref.read(paywayRepositoryProvider.future)),
);
