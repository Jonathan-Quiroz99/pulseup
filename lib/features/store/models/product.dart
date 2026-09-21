import '../../../core/utils/json_parse.dart';

class Product {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final String descripcion;
  final int stock;

  Product({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: asString(json['id']),
      nombre: asString(json['nombre']),
      categoria: asString(json['categoria']),
      // El backend manda el precio como texto tipo "$1,200".
      precio: asMoney(json['precio']),
      descripcion: asString(json['descripcion']),
      stock: asInt(json['stock']),
    );
  }

  double get priceValue => precio;
}
