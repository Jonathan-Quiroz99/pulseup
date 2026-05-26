import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../features/auth/user_session.dart';
import '../controllers/cart_controller.dart';

class CartService {
  Future<void> checkout() async {
    final cart = CartController.instance;

    final items = cart.items.value.entries.map((e) {
      return {
        "product_id": e.key,
        "quantity": e.value,
      };
    }).toList();

    final res = await http.post(
      Uri.parse('${ApiConfig.fullUrl}/products/cart'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${UserSession.token}",
      },
      body: jsonEncode({
        "member_id": UserSession.memberId,
        "items": items,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Checkout error: ${res.body}");
    }
  }
}