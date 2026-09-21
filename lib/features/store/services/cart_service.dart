import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import '../../../core/http_helpers.dart';
import '../../../features/auth/user_session.dart';
import '../controllers/cart_controller.dart';

class CartService {
  /// [estado] should be "Pagado" only once payment is actually confirmed
  /// (e.g. after MercadoPago checkout) — "Pendiente" for cash purchases
  /// that staff will collect and confirm in person.
  Future<void> checkout({
    required String metodo,
    String estado = "Pagado",
  }) async {
    final cart = CartController.instance;

    // El backend espera "cantidad", no "quantity" — con la llave equivocada
    // Pydantic la ignoraba en silencio y siempre asumia 1 unidad por producto.
    final items = cart.items.value.entries.map((e) {
      return {
        "product_id": e.key,
        "cantidad": e.value,
      };
    }).toList();

    final res = await http.post(
      Uri.parse('${ApiConfig.fullUrl}/products/cart'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${UserSession.token}",
      },
      body: jsonEncode({
        // El schema del backend (CartCheckout) no tiene "member_id": ese
        // campo se ignoraba y el pago quedaba sin comprador. El campo
        // correcto es "comprador" (texto libre para el registro de venta).
        "comprador": UserSession.fullName,
        "items": items,
        "metodo": metodo,
        "estado": estado,
      }),
    ).timeout(apiTimeout);

    await checkAuthResponse(res);

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Checkout error: ${res.body}");
    }
  }
}