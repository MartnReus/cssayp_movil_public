import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';

class BoletasRepositoryImpl implements BoletasRepository {
  final BoletasDataSource boletasDataSource;
  final BoletasLocalDataSource boletasLocalDataSource;
  final JwtTokenService jwtTokenService;

  BoletasRepositoryImpl({
    required this.boletasDataSource,
    required this.boletasLocalDataSource,
    required this.jwtTokenService,
  });

  @override
  Future<CrearBoletaInicioResult> crearBoletaInicio({
    required String caratula,
    required String juzgado,
    required CircunscripcionEntity circunscripcion,
    required TipoJuicioEntity tipoJuicio,
  }) async {
    try {
      final token = await jwtTokenService.obtenerToken();
      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      final response = await boletasDataSource.crearBoletaInicio(
        token: token,
        caratula: caratula,
        circunscripcion: circunscripcion,
        juzgado: juzgado,
        tipoJuicio: tipoJuicio,
      );

      if (response is! CrearBoletaSuccessResponse) {
        throw Exception(
          'Error al crear boleta de inicio: ${(response as CrearBoletaGenericErrorResponse).errorMessage}',
        );
      }

      return CrearBoletaInicioResult(idBoleta: response.idBoleta, urlPago: response.urlPago);
    } catch (e) {
      throw Exception('Error al crear boleta de inicio: $e');
    }
  }

  @override
  Future<BoletaEntity> crearBoletaFinalizacion({
    required int nroAfiliado,
    required String caratula,
    required int idBoletaInicio,
    required double monto,
    required DateTime fechaRegulacion,
    required double honorarios,
    required double cantidadJus,
    required double valorJus,
    int? nroExpediente,
    int? anioExpediente,
    int? cuij,
  }) async {
    try {
      final digito = await jwtTokenService.obtenerDigito();
      if (digito == null) {
        throw Exception('No se pudo obtener el dígito del token de autenticación');
      }

      final response = await boletasDataSource.crearBoletaFinalizacion(
        nroAfiliado: nroAfiliado,
        digito: digito,
        caratula: caratula,
        idBoletaInicio: idBoletaInicio,
        monto: monto,
        fechaRegulacion: fechaRegulacion,
        honorarios: honorarios,
        cantidadJus: cantidadJus,
        valorJus: valorJus,
        nroExpediente: nroExpediente,
        anioExpediente: anioExpediente,
        cuij: cuij,
      );
      if (response is! CrearBoletaSuccessResponse) {
        throw Exception(
          'Error al crear boleta de finalización: ${(response as CrearBoletaGenericErrorResponse).errorMessage}',
        );
      }

      final now = DateTime.now();
      return BoletaEntity(
        id: response.idBoleta,
        tipo: BoletaTipo.finalizacion,
        monto: monto,
        fechaImpresion: now,
        fechaVencimiento: now.add(const Duration(days: 30)),
        caratula: caratula,
        nroExpediente: nroExpediente,
        anioExpediente: anioExpediente,
        cuij: cuij,
        codBarra: null,
        gastosAdministrativos: null,
        estado: '',
      );
    } catch (e) {
      throw Exception('Error al crear boleta de finalización: $e');
    }
  }

  @override
  Future<HistorialBoletasSuccessResponse> obtenerHistorialBoletas(
    int nroAfiliado, {
    int? page,
    int mostrarPagadas = 1,
  }) async {
    try {
      // Intentar primero desde API
      try {
        final response = await boletasDataSource.obtenerHistorialBoletas(
          nroAfiliado: nroAfiliado,
          page: page,
          mostrarPagadas: mostrarPagadas,
        );

        if (response is HistorialBoletasSuccessResponse) {
          return response;
        }

        throw Exception(
          'Error al obtener historial de boletas: ${(response as HistorialBoletasErrorResponse).errorMessage}',
        );
      } catch (e) {
        // Si hay error, intentar desde local
        return await _obtenerDesdeLocal(page: page);
      }
    } catch (e) {
      throw Exception('Error al obtener historial de boletas: $e');
    }
  }

  Future<HistorialBoletasSuccessResponse> _obtenerDesdeLocal({int? page}) async {
    final currentPage = page ?? 1;
    const perPage = 10;
    final offset = (currentPage - 1) * perPage;

    final boletas = await boletasLocalDataSource.obtenerBoletasLocales(limit: perPage, offset: offset);

    final total = await boletasLocalDataSource.obtenerConteoBoletasLocales();
    final lastPage = (total / perPage).ceil();

    return HistorialBoletasSuccessResponse(
      statusCode: 200,
      boletas: boletas.map((boleta) => BoletaHistorialModel.fromJson(boleta.toJson())).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
    );
  }

  @override
  Future<ParametrosBoletaInicioEntity> obtenerParametrosBoletaInicio(int nroAfiliado) async {
    try {
      final response = await boletasDataSource.obtenerParametrosBoletaInicio(nroAfiliado);
      return ParametrosBoletaInicioEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener parámetros de boleta de inicio: $e');
    }
  }

  @override
  Future<PaginatedResponseModel> buscarBoletasInicioPagadas({
    required int nroAfiliado,
    int page = 1,
    String? caratulaBuscada,
  }) async {
    try {
      // Try API first
      final response = await boletasDataSource.buscarBoletasInicioPagadas(
        nroAfiliado: nroAfiliado,
        page: page,
        caratulaBuscada: caratulaBuscada,
      );
      return response;
    } catch (e) {
      // Fallback to local search if API fails
      print('API failed for search, trying local cache: $e');
      return await _buscarEnLocal(caratulaBuscada: caratulaBuscada, page: page);
    }
  }

  /// Search local cache for boletas with caratula filter
  Future<PaginatedResponseModel> _buscarEnLocal({String? caratulaBuscada, int page = 1}) async {
    const perPage = 10;
    final offset = (page - 1) * perPage;

    final boletas = await boletasLocalDataSource.obtenerBoletasLocales(
      limit: perPage,
      offset: offset,
      caratulaFiltro: caratulaBuscada,
    );

    final total = await boletasLocalDataSource.obtenerConteoBoletasLocales(caratulaFiltro: caratulaBuscada);

    // Convert BoletaEntity to the format expected by PaginatedResponseModel
    final data = boletas
        .map(
          (boleta) => {
            'id': boleta.id,
            'caratula': boleta.caratula,
            'monto': boleta.monto,
            'fechaImpresion': boleta.fechaImpresion.toIso8601String(),
            // Add other fields as needed
          },
        )
        .toList();

    return PaginatedResponseModel(
      statusCode: 200,
      data: data,
      currentPage: page,
      lastPage: (total / perPage).ceil(),
      perPage: perPage,
      total: total,
    );
  }

  Future<bool> debeUsarCache() async {
    final hasCache = await boletasLocalDataSource.tieneBoletasEnCache();
    if (!hasCache) return false;

    final lastSync = await boletasLocalDataSource.obtenerUltimaSincronizacion();
    if (lastSync == null) return false;

    // Considerar que los datos locales son validos por 1 hora
    final cacheAge = DateTime.now().difference(lastSync);
    return cacheAge.inHours < 1;
  }

  Future<void> syncCache(int nroAfiliado) async {
    try {
      final response = await boletasDataSource.obtenerHistorialBoletas(nroAfiliado: nroAfiliado, mostrarPagadas: 1);

      if (response is HistorialBoletasSuccessResponse) {
        await boletasLocalDataSource.limpiarCache();
        await boletasLocalDataSource.guardarBoletas(
          response.boletas.map((boleta) => BoletaEntity.fromJson(boleta.toJson())).toList(),
        );
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }
}
