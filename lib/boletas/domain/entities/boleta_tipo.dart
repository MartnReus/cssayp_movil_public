enum BoletaTipo {
  inicio,
  finalizacion,
  completarAportes,
  convenioLey13553,
  convenioAnioVencido,
  convenioRegulacionHonorarios,
  causaExtrajudicial,
  desconocido;

  static BoletaTipo fromId(int idTipoTransaccion) {
    return switch (idTipoTransaccion) {
      1 || 3 => BoletaTipo.inicio,
      2 || 4 => BoletaTipo.finalizacion,
      5 => BoletaTipo.completarAportes,
      6 => BoletaTipo.convenioLey13553,
      7 => BoletaTipo.convenioAnioVencido,
      8 => BoletaTipo.convenioRegulacionHonorarios,
      9 => BoletaTipo.causaExtrajudicial,
      _ => BoletaTipo.desconocido,
    };
  }

  static BoletaTipo fromCodigo(String codigo) {
    return switch (codigo) {
      'INICIO' => BoletaTipo.inicio,
      'FINALIZACION' => BoletaTipo.finalizacion,
      'COMPLETAR_APORTES' => BoletaTipo.completarAportes,
      'CONVENIO_LEY_13553' => BoletaTipo.convenioLey13553,
      'CONVENIO_ANIO_VENCIDO' => BoletaTipo.convenioAnioVencido,
      'CONVENIO_REGULACION_HONORARIOS' => BoletaTipo.convenioRegulacionHonorarios,
      'CAUSA_EXTRAJUDICIAL' => BoletaTipo.causaExtrajudicial,
      _ => BoletaTipo.desconocido,
    };
  }

  String get displayName {
    return switch (this) {
      BoletaTipo.inicio => 'Inicio',
      BoletaTipo.finalizacion => 'Finalización',
      BoletaTipo.completarAportes => 'Completar Aportes',
      BoletaTipo.convenioLey13553 => 'Convenio Ley 13553',
      BoletaTipo.convenioAnioVencido => 'Convenio Año Vencido',
      BoletaTipo.convenioRegulacionHonorarios => 'Convenio Regulación de Honorarios',
      BoletaTipo.causaExtrajudicial => 'Causa Extrajudicial',
      BoletaTipo.desconocido => 'Desconocida',
    };
  }

  String get codigo {
    return switch (this) {
      BoletaTipo.inicio => 'INICIO',
      BoletaTipo.finalizacion => 'FINALIZACION',
      BoletaTipo.completarAportes => 'COMPLETAR_APORTES',
      BoletaTipo.convenioLey13553 => 'CONVENIO_LEY_13553',
      BoletaTipo.convenioAnioVencido => 'CONVENIO_ANIO_VENCIDO',
      BoletaTipo.convenioRegulacionHonorarios => 'CONVENIO_REGULACION_HONORARIOS',
      BoletaTipo.causaExtrajudicial => 'CAUSA_EXTRAJUDICIAL',
      BoletaTipo.desconocido => 'DESCONOCIDO',
    };
  }
}
