typedef BoletaPagada = ({
  int id,
  int idBoletaGenerada,
  String importe,
  String caratula,
  String mvc,
  String? tipoJuicio,
  List<MontoOrganismo>? montosOrganismos,
});

typedef MontoOrganismo = ({int circunscripcion, double monto, String organismo});
