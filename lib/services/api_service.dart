
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.1.13/marketplace_api';

  static const String productEndpoint =
      '$baseUrl/get_product.php';

  static const String categoryEndpoint =
      '$baseUrl/get_kategory.php';

  static const String detailProductEndpoint =
      '$baseUrl/get_detail_product.php';

  static const String loginEndpoint =
      '$baseUrl/login.php';

  static const String registerEndpoint =
      '$baseUrl/register.php';

  // ==========================================
  // MEMPERBAIKI ALAMAT GAMBAR
  // ==========================================

  static String resolveImageUrl(String? image) {
    if (image == null || image.trim().isEmpty) {
      return '';
    }

    String imagePath = image.trim().replaceAll('\\', '/');

    // Jika URL gambar berasal dari server API yang sama,
    // gunakan baseUrl yang sedang dipakai Flutter.
    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      final uri = Uri.tryParse(imagePath);

      if (uri != null &&
          uri.path.contains('/marketplace_api/')) {
        final path = uri.path.split('/marketplace_api/').last;
        return '$baseUrl/$path';
      }

      return imagePath;
    }

    imagePath = imagePath.replaceFirst(RegExp(r'^/+'), '');

    if (imagePath.startsWith('uploads/')) {
      return '$baseUrl/$imagePath';
    }

    return '$baseUrl/uploads/$imagePath';
  }

  // ==========================================
  // MEMBACA RESPONS API
  // ==========================================

  static Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    debugPrint('HTTP status: ${response.statusCode}');
    debugPrint('API response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Server mengembalikan HTTP ${response.statusCode}',
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Respons server bukan JSON yang valid',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Format respons API tidak valid',
      );
    }

    final dynamic success =
        decoded['is_success'] ?? decoded['success'];

    final bool isSuccess =
        success == true ||
            success == 1 ||
            success?.toString().toLowerCase() == 'true' ||
            success?.toString() == '1';

    if (!isSuccess) {
      throw Exception(
        decoded['message']?.toString() ??
            'Permintaan API gagal',
      );
    }

    return decoded;
  }

  // ==========================================
  // MENGAMBIL DAFTAR PRODUK
  // ==========================================

  static Future<List<Product>> getProduct() async {
    try {
      final response = await http
          .get(Uri.parse(productEndpoint))
          .timeout(const Duration(seconds: 20));

      final decoded = _decodeResponse(response);
      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw Exception(
          'Data produk dari API bukan berupa daftar',
        );
      }

      return rawData.map<Product>((item) {
        if (item is! Map) {
          throw Exception(
            'Format salah satu data produk tidak valid',
          );
        }

        final product = Product.fromJson(
          Map<String, dynamic>.from(item),
        );

        final imageUrl = resolveImageUrl(product.image);

        return Product(
          id: product.id,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          name: product.name,
          description: product.description,
          price: product.price,
          stock: product.stock,
          status: product.status,
          image: imageUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getProduct: $e');
      rethrow;
    }
  }

  // ==========================================
  // MENGAMBIL DAFTAR KATEGORI
  // ==========================================

  static Future<List<Kategory>> getKategory() async {
    try {
      final response = await http
          .get(Uri.parse(categoryEndpoint))
          .timeout(const Duration(seconds: 20));

      final decoded = _decodeResponse(response);
      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw Exception(
          'Data kategori dari API bukan berupa daftar',
        );
      }

      return rawData.map<Kategory>((item) {
        if (item is! Map) {
          throw Exception(
            'Format salah satu data kategori tidak valid',
          );
        }

        final category = Kategory.fromJson(
          Map<String, dynamic>.from(item),
        );

        final imageUrl = resolveImageUrl(category.image);

        return Kategory(
          id: category.id,
          name: category.name,
          description: category.description,
          image: imageUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getKategory: $e');
      rethrow;
    }
  }

  // ==========================================
  // MENGAMBIL DETAIL PRODUK
  // ==========================================

  static Future<Product> getProductDetail(
      int productId,
      ) async {
    try {
      final uri = Uri.parse(detailProductEndpoint).replace(
        queryParameters: {
          'id': productId.toString(),
        },
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      final decoded = _decodeResponse(response);
      final dynamic rawData = decoded['data'];

      dynamic item = rawData;

      if (rawData is List) {
        if (rawData.isEmpty) {
          throw Exception(
            'Detail produk tidak ditemukan',
          );
        }

        item = rawData.first;
      }

      if (item is! Map) {
        throw Exception(
          'Format detail produk tidak valid',
        );
      }

      final product = Product.fromJson(
        Map<String, dynamic>.from(item),
      );

      return Product(
        id: product.id,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock,
        status: product.status,
        image: resolveImageUrl(product.image),
      );
    } catch (e) {
      debugPrint('Error getProductDetail: $e');
      rethrow;
    }
  }

  // ==========================================
  // LOGIN
  // ==========================================

  static Future<Map<String, dynamic>> login({
    required String name,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(loginEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name.trim(),
          'password': password,
        },
      )
          .timeout(const Duration(seconds: 20));

      debugPrint('Login HTTP status: ${response.statusCode}');
      debugPrint('Login response: ${response.body}');

      final dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Respons Login bukan JSON yang valid');
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Format respons Login tidak valid');
      }

      final dynamic success =
          decoded['is_success'] ?? decoded['success'];

      final bool isSuccess =
          success == true ||
              success == 1 ||
              success?.toString().toLowerCase() == 'true' ||
              success?.toString() == '1';

      if (response.statusCode != 200 || !isSuccess) {
        throw Exception(
          decoded['message']?.toString() ??
              'Login gagal. Periksa nama dan password.',
        );
      }

      final dynamic userData = decoded['data'];

      if (userData is! Map) {
        throw Exception('Data pengguna tidak valid');
      }

      return Map<String, dynamic>.from(userData);
    } catch (e) {
      debugPrint('Error Login: $e');
      rethrow;
    }
  }

  // ==========================================
  // REGISTER
  // ==========================================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(registerEndpoint),
        headers: {
          'Content-Type':
          'application/x-www-form-urlencoded',
        },
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'phone': phone.trim(),
        },
      )
          .timeout(const Duration(seconds: 20));

      debugPrint(
        'Register HTTP status: ${response.statusCode}',
      );
      debugPrint(
        'Register response: ${response.body}',
      );

      final dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'Respons registrasi bukan JSON yang valid',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Format respons registrasi tidak valid',
        );
      }

      final dynamic success =
          decoded['is_success'] ?? decoded['success'];

      final bool isSuccess =
          success == true ||
              success == 1 ||
              success?.toString().toLowerCase() == 'true' ||
              success?.toString() == '1';

      if (response.statusCode != 200 || !isSuccess) {
        throw Exception(
          decoded['message']?.toString() ??
              'Registrasi gagal',
        );
      }

      return decoded;
    } catch (e) {
      debugPrint('Error Register: $e');
      rethrow;
    }
  }
}
