import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'package:pulseup/core/http_helpers.dart';
import 'package:pulseup/features/auth/user_session.dart';

class ProductService {
  final String baseUrl;

  ProductService(this.baseUrl);

  Future<List<Product>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (UserSession.isLoggedIn) {
      headers['Authorization'] = 'Bearer ${UserSession.token}';
    }

    final res = await http.get(url, headers: headers).timeout(apiTimeout);

    if (kDebugMode) {
      debugPrint('GET $url -> ${res.statusCode}');
    }

    await checkAuthResponse(res);

    if (res.statusCode != 200) {
      throw Exception('Error cargando productos (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }
}
