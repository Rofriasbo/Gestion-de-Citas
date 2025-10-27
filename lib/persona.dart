class Persona {
  int? idpersona;
  String nombre;
  String telefono;

  Persona({this.idpersona, required this.nombre, required this.telefono});

  Map<String, dynamic> toJSON() {
    return {
      'IDPERSONA': idpersona,
      'NOMBRE': nombre,
      'TELEFONO': telefono,
    };
  }
}
