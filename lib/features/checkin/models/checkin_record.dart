class CheckinRecord {
  final String id;
  final String fecha;
  final String hora;
  final String acceso;
  final String metodo;
  final String puerta;
  final String tipo;

  CheckinRecord({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.acceso,
    required this.metodo,
    required this.puerta,
    required this.tipo,
  });

  factory CheckinRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return CheckinRecord(
      id: json["id"] ?? "",
      fecha: json["fecha"] ?? "",
      hora: json["hora"] ?? "",
      acceso: json["acceso"] ?? "",
      metodo: json["metodo"] ?? "",
      puerta: json["puerta"] ?? "",
      tipo: json["tipo"] ?? "Entrada",
    );
  }
}