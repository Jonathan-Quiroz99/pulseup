import '../../../core/utils/json_parse.dart';

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

  /// The backend sends `fecha` as an ISO date ("YYYY-MM-DD"). Returns null
  /// for any legacy/display-formatted value so callers can just skip it.
  DateTime? get date => DateTime.tryParse(fecha);

  factory CheckinRecord.fromJson(Map<String, dynamic> json) {
    return CheckinRecord(
      id: asString(json['id']),
      fecha: asString(json['fecha']),
      hora: asString(json['hora']),
      acceso: asString(json['acceso']),
      metodo: asString(json['metodo']),
      puerta: asString(json['puerta']),
      tipo: asString(json['tipo'], fallback: 'Entrada'),
    );
  }
}
