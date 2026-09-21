import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../core/http_helpers.dart';
import '../models/checkin_record.dart';

class CheckinService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<CheckinRecord>>
      fetchMyCheckins(String token) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/mobile/me/checkins",
      ),

      headers: {
        "Authorization": "Bearer $token",
      },
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

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