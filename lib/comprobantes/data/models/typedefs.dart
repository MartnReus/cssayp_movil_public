typedef BoletaPagada = ({
  int id,
  String importe,
  String caratula,
  String mvc,
  String? tipoJuicio,
  List<MontoOrganismo>? montosOrganismos,
});

typedef MontoOrganismo = ({int circunscripcion, double monto, String organismo});
