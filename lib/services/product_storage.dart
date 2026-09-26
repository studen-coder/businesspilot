import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class ProductStorage {
  static const String _key = 'businesspilot_products';

  static Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data);

    return decoded
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    );

    await prefs.setString(_key, data);
  }

  static Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await saveProducts(products);
  }

  static Future<void> updateProduct(Product product) async {
    final products = await getProducts();

    final index = products.indexWhere(
      (item) => item.id == product.id,
    );

    if (index >= 0) {
      products[index] = product;
      await saveProducts(products);
    }
  }

  static Future<Product?> findById(String id) async {
    final products = await getProducts();

    for (final product in products) {
      if (product.id == id) {
        return product;
      }

      for (final variant in product.variants) {
        if (variant.id == id || variant.sku == id) {
          return product;
        }
      }
    }

    return null;
  }
}
