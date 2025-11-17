import 'package:cssayp_movil/auth/data/datasources/preferencias_data_source.dart';
import 'package:cssayp_movil/auth/domain/repositories/preferencias_repository.dart';

class PreferenciasRepositoryImpl implements PreferenciasRepository {
  final PreferenciasDataSource _preferenciasDataSource;

  PreferenciasRepositoryImpl({required PreferenciasDataSource preferenciasDataSource})
    : _preferenciasDataSource = preferenciasDataSource;

  @override
  Future<void> guardarPreferenciaBiometria(bool valor) async {
    await _preferenciasDataSource.guardarPreferenciaBiometria(valor);
  }

  @override
  Future<bool> obtenerPreferenciaBiometria() async {
    return await _preferenciasDataSource.obtenerPreferenciaBiometria();
  }
}
