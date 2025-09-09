import 'package:shared_preferences/shared_preferences.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

class PreferenciasDataSource {
  final SharedPreferences _prefs;

  PreferenciasDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> guardarPreferenciaBiometria(bool valor) async {
    try {
      await _prefs.setBool('utilizar_biometria', valor);
    } catch (e) {
      throw AuthPreferencesWriteException('Error al guardar preferencia biométrica: $e');
    }
  }

  Future<bool> obtenerPreferenciaBiometria() async {
    try {
      return _prefs.getBool('utilizar_biometria') ?? false;
    } catch (e) {
      throw AuthPreferencesReadException('Error al leer preferencia biométrica: $e');
    }
  }

  Future<String?> obtenerValor(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw AuthPreferencesReadException('Error al leer valor de preferencias ($key): $e');
    }
  }

  Future<void> guardarValor(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw AuthPreferencesWriteException('Error al guardar valor en preferencias ($key): $e');
    }
  }
}
