import 'package:ecommerce/models/shop.dart';
import 'package:ecommerce/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/product.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(product.productName ?? 'Product Details'),
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
              icon: const Icon(Icons.light_mode)),
          Consumer<Shop>(
            builder: (context, shop, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/cart_page'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (shop.cart.isNotEmpty)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${shop.cart.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    "http://ecommerce.raviva.in/productimage/${product.image!}",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.productName!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${product.price}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              product.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Add to cart functionality here
                context.read<Shop>().addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.productName} added to cart!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 18,
                    ),
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
