import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/checkin_record.dart';

class CheckinService {
  final String baseUrl =
      "https://membersync-byso.onrender.com";

  Future<List<CheckinRecord>>
      fetchMyCheckins(String token) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/mobile/me/checkins",
      ),

      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List data =
          jsonDecode(response.body);

      return data
          .map(
            (e) => CheckinRecord.fromJson(e),
          )
          .toList();
    }

    throw Exception(
      "Error loading checkins",
    );
  }
}