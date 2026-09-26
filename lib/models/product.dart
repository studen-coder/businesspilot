class ProductVariant {
  final String id;
  String name;
  String sku;
  double price;
  int stock;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'price': price,
        'stock': stock,
      };

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
    );
  }
}

class Product {
  final String id;
  String name;
  String category;
  String sku;
  double price;
  int stock;
  List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.price,
    required this.stock,
    this.variants = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sku': sku,
        'price': price,
        'stock': stock,
        'variants': variants.map((v) => v.toJson()).toList(),
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      variants: (json['variants'] as List? ?? [])
          .map((v) => ProductVariant.fromJson(
                Map<String, dynamic>.from(v),
              ))
          .toList(),
    );
  }
}
