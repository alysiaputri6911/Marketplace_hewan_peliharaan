
import 'package:flutter/material.dart';
import 'package:marketplace_hewan_peliharaan/screens/product_detail.dart';
import '../models/product.dart';
import '../services/api_service.dart';


class ProductListPage extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ProductListPage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> productsFuture;

  String searchQuery = '';
  String stockFilter = 'Semua';

  double minPrice = 0;
  double maxPrice = 0;
  RangeValues selectedPriceRange = const RangeValues(0, 0);

  @override
  void initState() {
    super.initState();
    productsFuture = loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    final allProducts = await ApiService.getProduct();

    List<Product> categoryProducts = allProducts;

    if (widget.categoryId != null) {
      categoryProducts = allProducts
          .where((product) => product.categoryId == widget.categoryId)
          .toList();
    }

    if (categoryProducts.isNotEmpty) {
      final prices = categoryProducts.map((p) => p.price).toList();

      minPrice = prices.reduce((a, b) => a < b ? a : b);
      maxPrice = prices.reduce((a, b) => a > b ? a : b);

      selectedPriceRange = RangeValues(minPrice, maxPrice);
    } else {
      minPrice = 0;
      maxPrice = 0;
      selectedPriceRange = const RangeValues(0, 0);
    }

    return categoryProducts;
  }

  Future<void> refreshProducts() async {
    setState(() {
      productsFuture = loadProducts();
    });

    await productsFuture;
  }

  List<Product> filterProducts(List<Product> products) {
    return products.where((product) {
      // Filter pencarian nama produk
      final name = product.name.toLowerCase();
      final query = searchQuery.trim().toLowerCase();

      final matchesSearch = name.contains(query);

      // Filter harga
      final matchesPrice =
          product.price >= selectedPriceRange.start &&
              product.price <= selectedPriceRange.end;

      // Filter stok
      bool matchesStock = true;

      if (stockFilter == 'Tersedia') {
        matchesStock = product.stock > 0;
      } else if (stockFilter == 'Habis') {
        matchesStock = product.stock <= 0;
      }

      return matchesSearch && matchesPrice && matchesStock;
    }).toList();
  }

  String formatRupiah(double price) {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  Widget buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari produk...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Produk',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Filter stok
        DropdownButtonFormField<String>(
          value: stockFilter,
          decoration: InputDecoration(
            labelText: 'Status Stok',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Semua',
              child: Text('Semua Produk'),
            ),
            DropdownMenuItem(
              value: 'Tersedia',
              child: Text('Stok Tersedia'),
            ),
            DropdownMenuItem(
              value: 'Habis',
              child: Text('Stok Habis'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              stockFilter = value ?? 'Semua';
            });
          },
        ),

        const SizedBox(height: 18),

        const Text(
          'Rentang Harga',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        if (maxPrice > minPrice) ...[
          RangeSlider(
            values: selectedPriceRange,
            min: minPrice,
            max: maxPrice,
            divisions: 100,
            labels: RangeLabels(
              formatRupiah(selectedPriceRange.start),
              formatRupiah(selectedPriceRange.end),
            ),
            onChanged: (values) {
              setState(() {
                selectedPriceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatRupiah(selectedPriceRange.start)),
              Text(formatRupiah(selectedPriceRange.end)),
            ],
          ),
        ] else
          Text(
            formatRupiah(minPrice),
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );
  }

  Widget buildProductCard(Product product) {
    final imageUrl = ApiService.resolveImageUrl(product.image);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.pets,
                      size: 45,
                      color: Colors.grey,
                    ),
                  );
                },
              )
                  : const Center(
                child: Icon(
                  Icons.pets,
                  size: 45,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.stock > 0
                        ? 'Stok: ${product.stock}'
                        : 'Stok habis',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.stock > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? 'Produk Hewan Peliharaan',
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Product>>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat produk'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: refreshProducts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final allProducts = snapshot.data ?? [];
          final products = filterProducts(allProducts);

          return RefreshIndicator(
            onRefresh: refreshProducts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Pencarian
                buildSearchField(),

                const SizedBox(height: 20),

                // Filter
                buildFilterSection(),

                const SizedBox(height: 20),

                // Jumlah hasil
                Text(
                  'Hasil Produk (${products.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Daftar produk
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 45),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 55,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Coba gunakan kata kunci atau filter lain.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      return buildProductCard(products[index]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
