
import 'package:flutter/material.dart';
import 'package:marketplace_hewan_peliharaan/screens/product_detail.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService.getProduct();
  }

  void refreshProducts() {
    setState(() {
      productsFuture = ApiService.getProduct();
    });
  }

  String formatPrice(double price) {
    final priceString = price.toStringAsFixed(0);
    final result = StringBuffer();

    for (int i = 0; i < priceString.length; i++) {
      result.write(priceString[i]);

      final remaining = priceString.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Hewan Peliharaan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: refreshProducts,
            tooltip: 'Muat ulang produk',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: productsFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: refreshProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data ?? <Product>[];

          // Data kosong
          if (products.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                refreshProducts();
                await productsFuture;
              },
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text('Belum ada produk tersedia.'),
                  ),
                ],
              ),
            );
          }

          // Grid produk
          return RefreshIndicator(
            onRefresh: () async {
              refreshProducts();
              await productsFuture;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = product.image.trim();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            productId: product.id,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Gambar produk
                    Expanded(
                    child: SizedBox(
                    width: double.infinity,
                      child: imageUrl.isEmpty
                          ? const Center(
                        child: Icon(
                          Icons.pets,
                          size: 60,
                          color: Colors.teal,
                        ),
                      )
                          : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.teal,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Informasi produk
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatPrice(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stok: ${product.stock}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
