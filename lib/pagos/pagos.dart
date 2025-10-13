/// Modulo Pagos - Manejo de pagos
///
/// Este modulo proporciona funcionalidad para:
/// - Iniciar pagos con tarjeta
/// - Ver historial de pagos
library;

// Data Layer
export 'data/models/datos_tarjeta_model.dart';
export 'data/models/resultado_pago_model.dart';
export 'data/models/red_link_payment_request_model.dart';
export 'data/models/red_link_payment_response_model.dart';
export 'data/datasources/payway_data_source.dart';
export 'data/datasources/red_link_data_source.dart';
export 'data/repositories/payway_repository_impl.dart';
export 'data/repositories/red_link_repository_impl.dart';

// Domain Layer
export 'domain/entities/boleta_a_pagar_entity.dart';
export 'domain/repositories/base_pago_repository.dart';
export 'domain/repositories/payway_repository.dart';
export 'domain/repositories/red_link_repository.dart';
export 'domain/usecases/pagar_con_payway_use_case.dart';
export 'domain/usecases/pagar_con_red_link_use_case.dart';

// Presentation Layer
export 'presentation/screens/pagos_screens.dart';
export 'presentation/screens/red_link_payment_screen.dart';
export 'presentation/screens/pago_exitoso_screen.dart';
export 'presentation/providers/metodo_pago_selector_provider.dart';
export 'presentation/providers/payment_states.dart';
export 'presentation/providers/payway_notifier.dart';
export 'presentation/providers/red_link_notifier.dart';
export 'presentation/providers/pagos_providers.dart';
export 'presentation/providers/pagos_use_cases_providers.dart';
export 'presentation/widgets/metodo_de_pago_selector.dart';
export 'presentation/widgets/payway_form.dart';
