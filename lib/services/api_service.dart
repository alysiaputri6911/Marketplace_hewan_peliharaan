
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/product.dart';

class ApiService {
  // Alamat API PHP Native di XAMPP
  static const String baseUrl =
      'http://192.168.1.3/marketplace_api';

  // Mengambil daftar kategori
  static Future<List<Category>> getCategories() async {
    final response = await http
        .get(Uri.parse('$baseUrl/get_kategory.php'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil kategori: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
    jsonDecode(response.body);

    if (result['is_success'] != true) {
      throw Exception(
        result['message'] ?? 'API kategori gagal',
      );
    }

    final List<dynamic> data = result['data'] as List<dynamic>;

    return data
        .map((item) => Category.fromJson(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  // Mengambil daftar produk
  static Future<List<Product>> getProduct() async {
    final response = await http
        .get(Uri.parse('$baseUrl/get_product.php'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil produk: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
    jsonDecode(response.body);

    if (result['is_success'] != true) {
      throw Exception(
        result['message'] ?? 'API produk gagal',
      );
    }

    final List<dynamic> data = result['data'] as List<dynamic>;

    return data
        .map((item) => Product.fromJson(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }


  // Mengambil detail produk berdasarkan ID
  static Future<Product> getProductDetail(int id) async {
    final url = Uri.parse(
      '$baseUrl/get_detail_product.php',
    ).replace(
      queryParameters: {'id': id.toString()},
    );

    final response = await http
        .get(url)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil detail produk: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
    jsonDecode(response.body);

    if (result['is_success'] != true) {
      throw Exception(
        result['message'] ?? 'Detail produk gagal dimuat',
      );
    }

    final data = result['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Format detail produk tidak valid');
    }

    return Product.fromJson(data);
  }

}
