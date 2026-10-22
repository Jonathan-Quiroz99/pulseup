import 'dart:convert';
import 'dart:typed_data';

import '../../../core/utils/json_parse.dart';

class ProgressPhoto {
  final String id;
  final String date;

  /// Bytes JPEG ya decodificados del data URI que manda el backend.
  final Uint8List bytes;

  ProgressPhoto({required this.id, required this.date, required this.bytes});

  DateTime? get dateTime => DateTime.tryParse(date);

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    final uri = asString(json['imagen']);
    final comma = uri.indexOf(',');
    return ProgressPhoto(
      id: asString(json['id']),
      date: asString(json['fecha']),
      bytes: base64Decode(comma >= 0 ? uri.substring(comma + 1) : uri),
    );
  }
}
