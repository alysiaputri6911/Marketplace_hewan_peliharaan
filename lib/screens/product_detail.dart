
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage> {
  late Future<Product> productFuture;

  @override
  void initState() {
    super.initState();
    productFuture =
        ApiService.getProductDetail(widget.productId);
  }

  void retry() {
    setState(() {
      productFuture =
          ApiService.getProductDetail(widget.productId);
    });
  }

  String formatPrice(double price) {
    final value = price.toStringAsFixed(0);
    final result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      result.write(value[i]);

      final remaining = value.length - i - 1;
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
        title: const Text('Detail Produk'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Product>(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat detail produk',
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
                      onPressed: retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Detail produk tidak ditemukan.',
              ),
            );
          }

          final product = snapshot.data!;
          final imageUrl = product.image.trim();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk: tampilkan seluruh foto.
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 280,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: imageUrl.isEmpty
                        ? const Icon(
                      Icons.pets,
                      size: 70,
                      color: Colors.teal,
                    )
                        : Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                          ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const Center(
                          child:
                          CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Nama produk.
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Harga produk.
                Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Informasi kategori, stok, dan status.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _infoRow(
                          'Kategori',
                          product.categoryName.isEmpty
                              ? '-'
                              : product.categoryName,
                        ),
                        const Divider(),
                        _infoRow(
                          'Stok tersedia',
                          product.stock.toString(),
                        ),
                        const Divider(),
                        _infoRow(
                          'Status',
                          product.status.isEmpty
                              ? '-'
                              : product.status,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  product.description.isEmpty
                      ? 'Belum ada deskripsi produk.'
                      : product.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
