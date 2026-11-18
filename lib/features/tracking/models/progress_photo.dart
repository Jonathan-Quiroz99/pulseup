import 'dart:convert';
import 'dart:typed_data';

import '../../../core/utils/json_parse.dart';

class ProgressPhoto {
  final String id;
  final String date;

  /// Bytes JPEG ya decodificados del data URI que manda el backend.
  final Uint8List bytes;

  /// Registro de peso/medidas al que pertenece la foto (se liga al subirla).
  /// null en fotos viejas o si ese registro se borró.
  final String? measurementId;

  ProgressPhoto({
    required this.id,
    required this.date,
    required this.bytes,
    this.measurementId,
  });

  ProgressPhoto withMeasurement(String? id) =>
      ProgressPhoto(id: this.id, date: date, bytes: bytes, measurementId: id);

  DateTime? get dateTime => DateTime.tryParse(date);

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    final uri = asString(json['imagen']);
    final comma = uri.indexOf(',');
    return ProgressPhoto(
      id: asString(json['id']),
      date: asString(json['fecha']),
      bytes: base64Decode(comma >= 0 ? uri.substring(comma + 1) : uri),
      measurementId: switch (asString(json['medida_id'])) {
        '' => null,
        final id => id,
      },
    );
  }
}
