
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_list_page.dart';
import 'product_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color backgroundColor = const Color(0xFFF5F0E8);
  final Color primaryColor = const Color(0xFF8D6E63);
  final Color darkColor = const Color(0xFF5D4037);
  final Color cardColor = Colors.white;

  List<Kategory> categories = [];
  List<Product> products = [];

  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadHomeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getKategory(),
        ApiService.getProduct(),
      ]);

      if (!mounted) return;

      setState(() {
        categories = results[0] as List<Kategory>;
        products = results[1] as List<Product>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();
  }

  void openCategory(Kategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    );
  }

  void openAllProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(),
      ),
    );
  }

  void openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          productId: product.id,
        ),
      ),
    );
  }

  // Pengganti gambar jika gambar produk gagal dimuat.
  Widget buildPetPlaceholder({
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F0E8),
      alignment: Alignment.center,
      child: Icon(
        Icons.pets,
        size: 48,
        color: primaryColor,
      ),
    );
  }

  // Menampilkan gambar dari API.
  Widget buildNetworkImage(
      String? image, {
        double? width,
        double? height,
        BoxFit fit = BoxFit.contain,
      }) {
    final imageUrl = ApiService.resolveImageUrl(image);

    if (imageUrl.isEmpty) {
      return buildPetPlaceholder(
        width: width,
        height: height,
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return buildPetPlaceholder(
          width: width,
          height: height,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari makanan, aksesoris, hewan...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: primaryColor,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              searchController.clear();
              setState(() {
                searchQuery = '';
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Banner promosi: logo di kanan memakai box.
  Widget buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkColor,
            primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Everything for\nYour Lovely Pets!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temukan kebutuhan hewan kesayanganmu.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: openAllProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: darkColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Belanja Sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // BOX LOGO BANNER BAWAH
          Container(
            width: 115,
            height: 115,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              'images/logo_marketplace.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.pets,
                  size: 60,
                  color: primaryColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(
      String title, {
        VoidCallback? onSeeAll,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: darkColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCategories() {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Belum ada kategori.'),
      );
    }

    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () => openCategory(category),
            child: Container(
              width: 82,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: buildNetworkImage(
                      category.image,
                      width: 65,
                      height: 65,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => openProductDetail(product),
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: 145,
                color: const Color(0xFFF5F0E8),
                child: buildNetworkImage(
                  product.image,
                  width: double.infinity,
                  height: 145,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRupiah(product.price),
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Stok: ${product.stock}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
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

  String formatRupiah(double price) {
    final value = price.toInt().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );

    return 'Rp $formatted';
  }

  Widget buildProducts() {
    final displayedProducts = filteredProducts;

    if (displayedProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          searchQuery.isNotEmpty
              ? 'Produk tidak ditemukan.'
              : 'Belum ada produk.',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return SizedBox(
      height: 245,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: displayedProducts.length,
        itemBuilder: (context, index) {
          return buildProductCard(displayedProducts[index]);
        },
      ),
    );
  }

  Widget buildError() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 45,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              color: darkColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            errorMessage ?? 'Periksa koneksi dan API kamu.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loadHomeData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent() {
    return RefreshIndicator(
      onRefresh: loadHomeData,
      color: primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Pet Lover!',
                        style: TextStyle(
                          color: darkColor,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Apa kebutuhan hewan kesayanganmu?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // LOGO ATAS TANPA BOX
                SizedBox(
                  width: 115,
                  height: 115,
                  child: Image.asset(
                    'images/logo_marketplace.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.pets,
                        size: 60,
                        color: primaryColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          buildSearchBar(),

          const SizedBox(height: 22),
          buildPromoBanner(),

          const SizedBox(height: 25),
          buildSectionTitle('Kategori'),

          const SizedBox(height: 12),
          buildCategories(),

          const SizedBox(height: 20),
          buildSectionTitle(
            searchQuery.isNotEmpty
                ? 'Hasil Pencarian'
                : 'Produk Terbaru',
            onSeeAll: openAllProducts,
          ),

          const SizedBox(height: 10),
          buildProducts(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Pet Marketplace',
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fitur notifikasi belum tersedia.',
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.notifications_none,
              color: darkColor,
            ),
          ),
        ],
      ),

      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : errorMessage != null
          ? buildError()
          : buildHomeContent(),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: darkColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 1) {
            openAllProducts();
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Fitur keranjang belum tersedia.',
                ),
              ),
            );
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Fitur profil belum tersedia.',
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
