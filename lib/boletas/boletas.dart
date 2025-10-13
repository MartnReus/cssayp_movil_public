/// Modulo Boletas - Manejo de boletas y juicios
///
/// Este modulo proporciona funcionalidad para:
/// - Crear nuevas boletas de inicio y fin
/// - Ver información de juicios asociados a boletas
/// - Ver historial de boletas creadas
library;

// Domain Layer
export 'domain/entities/boleta_entity.dart';
export 'domain/entities/boleta_tipo.dart';
export 'domain/entities/circunscripcion_entity.dart';
export 'domain/entities/crear_boleta_inicio_result.dart';
export 'domain/entities/juicio_entity.dart';
export 'domain/entities/estado_boleta.dart';
export 'domain/entities/montos_entity.dart';
export 'domain/entities/parametros_boleta_inicio_entity.dart';
export 'domain/entities/tipo_juicio_entity.dart';

export 'domain/repositories/boletas_repository.dart';
export 'domain/repositories/juicios_repository.dart';

export 'domain/usecases/buscar_boletas_inicio_pagadas_use_case.dart';
export 'domain/usecases/generar_boleta_finalizacion_use_case.dart';
export 'domain/usecases/generar_boleta_inicio_use_case.dart';
export 'domain/usecases/listar_juicios_use_case.dart';
export 'domain/usecases/obtener_historial_boletas_use_case.dart';
export 'domain/usecases/obtener_parametros_boleta_inicio_use_case.dart';

// Data Layer
export 'data/models/crear_boleta_response_models.dart';
export 'data/models/boleta_inicio_pagada_model.dart';
export 'data/models/boleta_historial_model.dart';
export 'data/models/historial_boletas_response_models.dart';

export 'data/repositories/boletas_repository_impl.dart';
export 'data/repositories/juicios_repository_impl.dart';

export 'data/datasources/boletas_data_source.dart';
export 'data/datasources/boletas_local_data_source.dart';

// Presentation Layer
export 'presentation/providers/boletas_list_provider.dart';
export 'presentation/providers/boleta_inicio_data_provider.dart';
export 'presentation/providers/boleta_fin_data_provider.dart';
export 'presentation/providers/boletas_use_cases_providers.dart';
export 'presentation/providers/juicios_provider.dart';

export 'presentation/screens/crear_boleta_inicio_pasos/boleta_inicio_paso1.dart';
export 'presentation/screens/crear_boleta_inicio_pasos/boleta_inicio_paso2.dart';
export 'presentation/screens/crear_boleta_inicio_pasos/boleta_inicio_paso3.dart';

export 'presentation/screens/crear_boleta_screen.dart';
export 'presentation/screens/historial_screen.dart';

export 'presentation/screens/boleta_generada.dart';
export 'presentation/screens/crear_boleta_fin_pasos/boleta_fin_paso1.dart';
export 'presentation/screens/crear_boleta_fin_pasos/boleta_fin_paso2.dart';
export 'presentation/screens/crear_boleta_fin_pasos/boleta_fin_paso3.dart';

export 'presentation/widgets/historial_boletas.dart';
export 'presentation/widgets/historial_juicios.dart';
