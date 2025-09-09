class BoletaHistorialModel {
  final String idBoletaGenerada;
  final String monto;
  final String caratula;
  final String? idTipoTransaccion;
  final String? fechaImpresion;
  final String? gastosAdministrativos;
  final String? codBarra;
  final String? idTipoBoleta;
  final String? fechaPago;
  final String? diasVencimiento;
  final String? estado;

  const BoletaHistorialModel({
    required this.idBoletaGenerada,
    required this.monto,
    required this.caratula,
    this.idTipoTransaccion,
    this.fechaImpresion,
    this.gastosAdministrativos,
    this.codBarra,
    this.idTipoBoleta,
    this.fechaPago,
    this.diasVencimiento,
    this.estado,
  });

  factory BoletaHistorialModel.fromJson(Map<String, dynamic> json) {
    return BoletaHistorialModel(
      idBoletaGenerada: json['id_boleta_generada']?.toString() ?? '0',
      monto: json['monto']?.toString() ?? '0',
      caratula: json['caratula']?.toString() ?? '',
      idTipoTransaccion: json['id_tipo_transaccion']?.toString(),
      fechaImpresion: json['fecha_impresion']?.toString(),
      gastosAdministrativos: json['gastos_administrativos']?.toString(),
      codBarra: json['cod_barra']?.toString(),
      idTipoBoleta: json['id_tipo_boleta']?.toString(),
      fechaPago: json['fecha_pago']?.toString(),
      diasVencimiento: json['dias_vencimiento']?.toString(),
      estado: json['estado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(idBoletaGenerada) ?? 0,
      'monto': double.tryParse(monto) ?? 0.0,
      'caratula': caratula,
      'idTipoTransaccion': idTipoTransaccion,
      'tipo': idTipoTransaccion == '1' || idTipoTransaccion == '3' ? 'inicio' : 'finalizacion',
      'fechaImpresion': fechaImpresion ?? DateTime.now().toIso8601String(),
      'fechaVencimiento': fechaImpresion != null
          ? DateTime.parse(
              fechaImpresion!,
            ).add(Duration(days: int.tryParse(diasVencimiento ?? '30') ?? 30)).toIso8601String()
          : DateTime.now().add(Duration(days: 30)).toIso8601String(),
      'codBarra': codBarra,
      'idBoletaAsociada': null,
      'fechaPago': fechaPago,
      'importePago': null,
      'nroExpediente': null,
      'anioExpediente': null,
      'cuij': null,
      'gastosAdministrativos': gastosAdministrativos != null ? double.tryParse(gastosAdministrativos!) : null,
    };
  }

  bool get estaPagada => fechaPago != null && fechaPago!.isNotEmpty || estado == 'Para imputar';
}
