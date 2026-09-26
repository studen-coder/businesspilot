import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/id_generator.dart';
import '../services/product_storage.dart';
import 'qr_scanner_screen.dart';

class _CartItem {
  final Product product;
  int quantity = 1;

  _CartItem({
    required this.product,
  });

  double get total => product.price * quantity;
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final List<_CartItem> cart = [];

  double get subtotal {
    return cart.fold(
      0,
      (total, item) => total + item.total,
    );
  }

  Future<void> scanProduct() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (!mounted || result == null || result.isEmpty) return;

    final product = await ProductStorage.findById(result);

    if (!mounted) return;

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not found'),
        ),
      );
      return;
    }

    addProductToCart(product);
  }

  void addProductToCart(Product product) {
    final existingIndex = cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final item = cart[existingIndex];

      if (item.quantity >= product.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough stock available'),
          ),
        );
        return;
      }

      setState(() {
        item.quantity++;
      });
      return;
    }

    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is out of stock'),
        ),
      );
      return;
    }

    setState(() {
      cart.add(_CartItem(product: product));
    });
  }

  void changeQuantity(int index, int change) {
    final item = cart[index];
    final newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      setState(() {
        cart.removeAt(index);
      });
      return;
    }

    if (newQuantity > item.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity cannot exceed available stock'),
        ),
      );
      return;
    }

    setState(() {
      item.quantity = newQuantity;
    });
  }

  Future<void> checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one product'),
        ),
      );
      return;
    }

    final paidController = TextEditingController(
      text: subtotal.toStringAsFixed(2),
    );

    String paymentMethod = 'Cash';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Complete Payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total: ₹${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment method',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Cash',
                          child: Text('Cash'),
                        ),
                        DropdownMenuItem(
                          value: 'UPI',
                          child: Text('UPI'),
                        ),
                        DropdownMenuItem(
                          value: 'Card',
                          child: Text('Card'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            paymentMethod = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount paid',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final paid = double.tryParse(
                      paidController.text.trim(),
                    );

                    if (paid == null || paid < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid payment amount'),
                        ),
                      );
                      return;
                    }

                    if (paid > subtotal) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Payment cannot be greater than the bill total',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      {
                        'paid': paid,
                        'method': paymentMethod,
                      },
                    );
                  },
                  child: const Text('Complete Sale'),
                ),
              ],
            );
          },
        );
      },
    );

    paidController.dispose();

    if (!mounted || result == null) return;

    final paid = result['paid'] as double;
    final method = result['method'] as String;

    final invoiceNumber = await IdGenerator.invoiceId();

    if (!mounted) return;

    for (final item in cart) {
      item.product.stock -= item.quantity;
      await ProductStorage.updateProduct(item.product);
    }

    if (!mounted) return;

    final due = subtotal - paid;

    setState(() {
      cart.clear();
    });

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sale Completed'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice: $invoiceNumber'),
                const SizedBox(height: 12),
                Text('Total: ₹${subtotal.toStringAsFixed(2)}'),
                Text('Paid: ₹${paid.toStringAsFixed(2)}'),
                Text('Due: ₹${due.toStringAsFixed(2)}'),
                Text('Payment: $method'),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
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
        title: const Text('Billing'),
        actions: [
          IconButton(
            tooltip: 'Scan QR',
            onPressed: scanProduct,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 80,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No items in bill',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Scan a product QR code to add it',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      return Card(
                        child: ListTile(
                          title: Text(item.product.name),
                          subtitle: Text(
                            '${item.product.id}\n'
                            '₹${item.product.price.toStringAsFixed(2)} '
                            '× ${item.quantity} = '
                            '₹${item.total.toStringAsFixed(2)}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  changeQuantity(index, -1);
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                ),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  changeQuantity(index, 1);
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: checkout,
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: scanProduct,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan Product'),
      ),
    );
  }
}
