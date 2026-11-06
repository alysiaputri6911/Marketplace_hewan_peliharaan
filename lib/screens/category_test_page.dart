import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import 'product_list_page.dart';

class CategoryTestPage extends StatefulWidget {
  const CategoryTestPage({super.key});

  @override
  State<CategoryTestPage> createState() => _CategoryTestPageState();
}

class _CategoryTestPageState extends State<CategoryTestPage> {
  late Future<List<Kategory>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = ApiService.getKategory();
  }

  // Memilih gambar kategori dari folder images
  String getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase().trim()) {
      case 'kucing':
        return 'images/kucing.jpg';

      case 'anjing':
        return 'images/anjing.jpg';

      case 'kelinci':
        return 'images/kelinci.png';

      case 'burung':
        return 'images/burung.jpg';

      case 'ikan':
        return 'images/ikan.jpg';

      case 'hamster':
        return 'images/hamster.jpg';

      case 'makanan hewan':
        return 'images/makanan_hewan.jpg';

      case 'perawatan hewan':
        return 'images/perawatan_hewan.png';

      case 'aksesoris hewan':
        return 'images/aksesoris_hewan.png';

      default:
        return '';
    }
  }

  // Menampilkan gambar kategori
  Widget buildCategoryImage(String categoryName) {
    final imagePath = getCategoryImage(categoryName);

    if (imagePath.isEmpty) {
      return const Center(
        child: Icon(
          Icons.pets,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error gambar: $imagePath - $error');

          return const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  // Membuka daftar produk berdasarkan kategori
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),

      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 50),
            const Text(
              'Kategori Hewan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),

      ),

      body: FutureBuilder<List<Kategory>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat kategori'),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        categoriesFuture =
                            ApiService.getKategory();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Kategori belum tersedia'),
            );
          }

          final categories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),

            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                color: Colors.white,
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: InkWell(
                  onTap: () => openCategory(category),

                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Gambar kategori
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: buildCategoryImage(
                            category.name,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Nama kategori
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}