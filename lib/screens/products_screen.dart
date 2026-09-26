import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/product.dart';
import '../services/id_generator.dart';
import '../services/product_storage.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final savedProducts = await ProductStorage.getProducts();

    if (!mounted) return;

    setState(() {
      products = savedProducts;
      loading = false;
    });
  }

  Future<void> addProduct() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final skuController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU / Product Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock quantity *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final category = categoryController.text.trim();
                final sku = skuController.text.trim();
                final price = double.tryParse(
                  priceController.text.trim(),
                );
                final stock = int.tryParse(
                  stockController.text.trim(),
                );

                if (name.isEmpty || price == null || stock == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter product name, price and stock',
                      ),
                    ),
                  );
                  return;
                }

                final id = await IdGenerator.productId();

                final product = Product(
                  id: id,
                  name: name,
                  category: category,
                  sku: sku.isEmpty ? id : sku,
                  price: price,
                  stock: stock,
                );

                await ProductStorage.addProduct(product);

                if (!mounted) return;

                Navigator.of(context).pop(true);
              },
              child: const Text('Save Product'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    categoryController.dispose();
    skuController.dispose();
    priceController.dispose();
    stockController.dispose();

    if (result == true) {
      await loadProducts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product saved successfully'),
        ),
      );
    }
  }

  void showProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name),
          content: SingleChildScrollView(
            child: Column(
              children: [
                QrImageView(
                  data: product.id,
                  size: 220,
                ),
                const SizedBox(height: 12),
                Text(
                  product.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text('SKU: ${product.sku}'),
                Text(
                  'Price: ₹${product.price.toStringAsFixed(2)}',
                ),
                Text('Stock: ${product.stock}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No products yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap + to add your first product',
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      child: ListTile(
                        leading: QrImageView(
                          data: product.id,
                          size: 55,
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${product.id}\n'
                          'SKU: ${product.sku}\n'
                          '₹${product.price.toStringAsFixed(2)} • '
                          'Stock: ${product.stock}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.qr_code_2,
                        ),
                        onTap: () => showProduct(product),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
