import 'package:shared_preferences/shared_preferences.dart';

class IdGenerator {
  static Future<String> _nextNumber(String key) async {
    final prefs = await SharedPreferences.getInstance();

    final current = prefs.getInt(key) ?? 0;
    final next = current + 1;

    await prefs.setInt(key, next);

    return next.toString().padLeft(6, '0');
  }

  static Future<String> productId() async {
    return 'BP-P-${await _nextNumber('product_counter')}';
  }

  static Future<String> variantId() async {
    return 'BP-V-${await _nextNumber('variant_counter')}';
  }

  static Future<String> invoiceId() async {
    final number = await _nextNumber('invoice_counter');
    final year = DateTime.now().year;

    return 'BP-INV-$year-$number';
  }
}
