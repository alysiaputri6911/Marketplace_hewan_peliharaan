
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/api_service.dart';

class CategoryTestPage extends StatefulWidget {
  const CategoryTestPage({super.key});

  @override
  State<CategoryTestPage> createState() => _CategoryTestPageState();
}

class _CategoryTestPageState extends State<CategoryTestPage> {
  late Future<List<Category>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = ApiService.getCategories();
  }

  void refreshCategories() {
    setState(() {
      categoriesFuture = ApiService.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Hewan Peliharaan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Category>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          // Menampilkan loading saat data sedang diambil
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Menampilkan pesan jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                      'Gagal memuat kategori',
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
                      onPressed: refreshCategories,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Mengambil data kategori
          final categories = snapshot.data ?? <Category>[];

          if (categories.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                refreshCategories();
                await categoriesFuture;
              },
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text('Belum ada kategori.'),
                  ),
                ],
              ),
            );
          }

          // Menampilkan kategori dalam bentuk grid
          return RefreshIndicator(
            onRefresh: () async {
              refreshCategories();
              await categoriesFuture;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final imageUrl = category.image.trim();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar kategori
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

                      // Nama dan deskripsi kategori
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
