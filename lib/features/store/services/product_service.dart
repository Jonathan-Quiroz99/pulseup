import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'package:pulseup/core/api_config.dart';
import 'package:pulseup/features/auth/user_session.dart';

class ProductService {
  final String baseUrl;

  ProductService(this.baseUrl);

  Future<List<Product>> getProducts() async {
    try {
      final url = Uri.parse('$baseUrl/products');
      
      // Preparar headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      // 🔥 IMPORTANTE: Usar la propiedad isLoggedIn de UserSession
      if (UserSession.isLoggedIn) {
        headers['Authorization'] = 'Bearer ${UserSession.token}';
        print("✅ Token presente: ${UserSession.token?.substring(0, 20)}...");
      } else {
        print("⚠️ Usuario no autenticado");
      }

      print("🌐 URL: $url");
      print("📡 Enviando petición...");

      final res = await http.get(url, headers: headers);

      print("📡 Status code: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        print("✅ Productos cargados exitosamente");
        print("📦 Primeros 100 chars: ${res.body.substring(0, res.body.length > 100 ? 100 : res.body.length)}");
      } else {
        print("❌ Error: ${res.body}");
      }

      // Manejo de errores mejorado
      if (res.statusCode == 401) {
        throw Exception("Sesión expirada. Por favor, inicia sesión nuevamente.");
      }

      if (res.statusCode != 200) {
        throw Exception("Error cargando productos (${res.statusCode}): ${res.body}");
      }

      final List data = jsonDecode(res.body);
      print("✅ Total de productos: ${data.length}");
      
      return data.map((e) => Product.fromJson(e)).toList();
      
    } catch (e) {
      print("❌ Excepción en getProducts: $e");
      throw Exception("Error al cargar productos: $e");
    }
  }
}