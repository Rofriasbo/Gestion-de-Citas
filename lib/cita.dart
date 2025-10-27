class Cita {
  int? idcita;
  String lugar;
  String? fecha;
  String? hora;
  String? anotaciones;
  int idpersona;
  double? latitud;
  double? longitud;

  Cita({
    this.idcita,
    required this.lugar,
    this.latitud,
    this.longitud,
    this.fecha,
    this.hora,
    this.anotaciones,
    required this.idpersona,
  });

  Map<String, dynamic> toJSON() {
    return {
      'IDCITA': idcita,
      'LUGAR': lugar,
      'FECHA': fecha,
      'HORA': hora,
      'ANOTACIONES': anotaciones,
      'IDPERSONA': idpersona,
    };
  }
}
