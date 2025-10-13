class RedLinkPaymentResponseModel {
  final String paymentUrl;
  final String tokenIdLink;
  final String referencia;
  final bool success;
  final String? error;

  const RedLinkPaymentResponseModel({
    required this.paymentUrl,
    required this.tokenIdLink,
    required this.referencia,
    required this.success,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_url': paymentUrl,
      'token_id_link': tokenIdLink,
      'referencia': referencia,
      'success': success,
      'error': error,
    };
  }

  factory RedLinkPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return RedLinkPaymentResponseModel(
      paymentUrl: json['payment_url'] as String? ?? '',
      tokenIdLink: json['token_id_link'] as String? ?? '',
      referencia: json['referencia'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
}

class RedLinkPaymentStatusModel {
  final bool pagado;
  final String? estado;
  final String? mensaje;

  const RedLinkPaymentStatusModel({required this.pagado, this.estado, this.mensaje});

  factory RedLinkPaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return RedLinkPaymentStatusModel(
      pagado: json['pagado'] == 1 || json['pagado'] == true,
      estado: json['estado'] as String?,
      mensaje: json['mensaje'] as String?,
    );
  }
}
