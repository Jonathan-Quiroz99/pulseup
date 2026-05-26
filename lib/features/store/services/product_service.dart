import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl;

  ProductService(this.baseUrl);

  Future<List<Product>> getProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/api/products'));

    if (res.statusCode != 200) {
      throw Exception("Error cargando productos");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }
}