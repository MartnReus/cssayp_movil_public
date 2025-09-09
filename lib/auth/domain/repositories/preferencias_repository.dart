abstract interface class PreferenciasRepository {
  Future<void> guardarPreferenciaBiometria(bool valor);
  Future<bool> obtenerPreferenciaBiometria();
}
