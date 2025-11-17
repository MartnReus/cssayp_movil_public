/// Modulo Comprobantes - Visualizacion y descarga de comprobantes
///
/// Este modulo proporciona funcionalidad para:
/// - Obtener informacion de comprobantes de pagos realizados
/// - Descargar comprobantes en formato PDF
library;

// Data Layer
export 'data/datasources/comprobantes_local_data_source.dart';
export 'data/datasources/comprobantes_remote_data_source.dart';
export 'data/models/datos_comprobante_model.dart';
export 'data/models/typedefs.dart';
export 'data/repositories/comprobantes_repository_impl.dart';

// Domain Layer
export 'domain/entities/comprobante_entity.dart';
export 'domain/repositories/comprobantes_repository.dart';
export 'domain/usecases/compartir_comprobante_usecase.dart';
export 'domain/usecases/descargar_comprobante_usecase.dart';
export 'domain/usecases/generar_comprobante_usecase.dart';
export 'domain/usecases/obtener_comprobante_usecase.dart';

// Presentation Layer
export 'presentation/providers/comprobantes_notifier.dart';
export 'presentation/providers/comprobantes_providers.dart';
export 'presentation/screens/comprobante_fin_screen.dart';
export 'presentation/screens/comprobante_inicio_screen.dart';
