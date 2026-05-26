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
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      precio: double.parse(json['precio'].toString()),
      descripcion: json['descripcion'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }
}